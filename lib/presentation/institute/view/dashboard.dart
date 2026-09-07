import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/data/models/menu_item.dart';
import 'package:tuoora/presentation/institute/controllers/institute_profile_controller.dart';
import 'package:tuoora/presentation/institute/widgets/subscription_banner.dart';
import 'package:tuoora/presentation/institute/widgets/todays_birthday_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class InstituteDashboard extends GetView<InstituteProfileController> {
  const InstituteDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchProfile(),
        color: AppColors.primaryBrand,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopHeader(),
              const SubscriptionBanner(),
              const TodaysBirthdayCard(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: _buildModulesGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final profileController = Get.find<InstituteProfileController>();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(color: AppColors.white),
      child: Row(
        children: [
          Obx(
            () => Expanded(
              child: Text(
                profileController.instituteName.value.isNotEmpty
                    ? profileController.instituteName.value
                    : 'Tuoora',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: AppTextStyles.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.instituteNotifications),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.fieldLabel,
              size: 28,
            ),
          ),
          AppSpacing.h20,
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.instituteProfile),
            child: Obx(
              () => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBrandLight,
                    width: 2,
                  ),
                ),
                child: ClipOval(child: _buildProfileImage(profileController)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(InstituteProfileController profileController) {
    final imagePath = profileController.profileImagePath.value;

    if (imagePath == null ||
        imagePath.isEmpty ||
        !imagePath.startsWith('http')) {
      return Container(
        color: AppColors.primaryBrandLight,
        child: Center(
          child: Text(
            profileController.instituteName.value.isNotEmpty
                ? profileController.instituteName.value[0].toUpperCase()
                : 'T',
            style: AppTextStyles.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBrand,
            ),
          ),
        ),
      );
    }

    return AppNetworkImage(url: imagePath, fit: BoxFit.cover);
  }

  Widget _buildModulesGrid() {
    final modules = [
      ModuleItem(
        'Students',
        () => Get.toNamed(AppRoutes.instituteStudents),
        AppImages.icModuleStaff,
      ),
      ModuleItem(
        'Batches',
        () => Get.toNamed(AppRoutes.instituteBatches),
        AppImages.icModuleBatch,
      ),
      ModuleItem(
        'Fees',
        () => Get.toNamed(AppRoutes.instituteFees),
        AppImages.icModuleFees,
      ),
      ModuleItem(
        'Staffs',
        () => Get.toNamed(AppRoutes.instituteStaffs),
        AppImages.icModuleStaff,
      ),
      ModuleItem(
        'Chats',
        () => Get.toNamed(AppRoutes.instituteChats),
        AppImages.icModuleChat,
      ),
      ModuleItem(
        'Reports',
        () => Get.toNamed(AppRoutes.instituteReports),
        AppImages.icModuleReports,
      ),
      ModuleItem(
        'Leads',
        () => Get.toNamed(AppRoutes.instituteLeads),
        AppImages.icModuleLead,
      ),
      ModuleItem(
        'Notes',
        () => Get.toNamed(AppRoutes.instituteNotes),
        AppImages.icModuleNotes,
      ),
      ModuleItem(
        'Expenses',
        () => Get.toNamed(AppRoutes.instituteExpenses),
        AppImages.icModuleExpense,
      ),
      ModuleItem(
        'Updates',
        () => Get.toNamed(AppRoutes.instituteUpdates),
        AppImages.icModuleUpdates,
      ),
      ModuleItem(
        'Timetable',
        () => Get.toNamed(AppRoutes.instituteBatches),
        AppImages.icBatchTimetable,
      ),
      ModuleItem(
        'Birthdays',
        () => Get.toNamed(AppRoutes.instituteBirthdays),
        AppImages.icBirthdayCake,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final item = modules[index];
        final accent = _accentPalette[index % _accentPalette.length];
        return _buildGridItem(item, accent);
      },
    );
  }

  static const List<Color> _accentPalette = <Color>[
    AppColors.primaryBrand,
    AppColors.successGreen,
    AppColors.bohoRed,
    AppColors.subjectPhysics,
    AppColors.orangeTag,
    AppColors.successGreen,
  ];

  Widget _buildGridItem(ModuleItem item, Color accent) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              item.svgAsset,
              width: 48,
              height: 48,
              theme: SvgTheme(currentColor: accent),
              colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
            ),
            AppSpacing.v12,
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

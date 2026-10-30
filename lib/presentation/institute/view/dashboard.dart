import 'package:tuoora/core/constants/app_permissions.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/data/models/menu_item.dart';
import 'package:tuoora/presentation/institute/controllers/institute_profile_controller.dart';
import 'package:tuoora/presentation/institute/widgets/subscription_banner.dart';
import 'package:tuoora/presentation/institute/controllers/birthday_controller.dart';
import 'package:tuoora/presentation/institute/controllers/chat_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/services/branding_service.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';

class InstituteDashboard extends GetView<InstituteProfileController> {
  const InstituteDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          controller.fetchProfile(),
          if (_auth.canModule(AppPermissions.students))
            Get.find<BirthdayController>().fetchBirthdays(),
          if (_auth.can(AppPermissions.chatAccess))
            Get.find<ChatController>().fetchChats(),
        ]),
        color: AppColors.primaryBrand,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopHeader(),
              // Subscription is owner-only.
              if (!_auth.isSubAccess) const SubscriptionBanner(),
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
                    : (Get.isRegistered<BrandingService>() ? Get.find<BrandingService>().appName : 'Tuoora'),
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
          if (_auth.isSubAccess)
            _buildSubAccessBadge()
          else
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

  AuthService get _auth => Get.find<AuthService>();

  /// Shown instead of the profile avatar for sub-access users (Profile is
  /// owner-only). Tapping it offers Log Out, which lives on Profile otherwise.
  Widget _buildSubAccessBadge() {
    final name = _auth.currentUser?.subAccessName ??
        _auth.currentUser?.name ??
        '';
    return GestureDetector(
      onTap: () => CommonDialog.show(
        title: AppStrings.logout,
        description: 'Signed in as sub-access user $name. Log out now?',
        icon: Icons.logout_rounded,
        iconColor: AppColors.primaryBrand,
        iconBgColor: AppColors.primaryBrandLight,
        confirmText: AppStrings.logout,
        confirmButtonColor: AppColors.primaryBrand,
        onConfirm: () => Get.find<InstituteProfileController>().logout(),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryBrandLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryBrand.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.admin_panel_settings_rounded,
              size: 14,
              color: AppColors.primaryBrand,
            ),
            AppSpacing.h4,
            Flexible(
              child: Text(
                'Sub-Access: $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
          ],
        ),
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
      if (_auth.can(AppPermissions.academicsTimetable))
      ModuleItem(
        'Timetable',
        () => Get.toNamed(AppRoutes.instituteTimetable),
        AppImages.icBatchTimetable,
      ),
      if (_auth.canModule(AppPermissions.students))
      ModuleItem(
        'Students',
        () => Get.toNamed(AppRoutes.instituteStudents),
        AppImages.icModuleStaff,
      ),
      if (_auth.canModule(AppPermissions.batches))
      ModuleItem(
        'Batches',
        () => Get.toNamed(AppRoutes.instituteBatches),
        AppImages.icModuleBatch,
      ),
      if (_auth.canModule(AppPermissions.attendance))
      ModuleItem(
        AppStrings.instAttendanceTitle,
        () => Get.toNamed(AppRoutes.instituteAttendance),
        AppImages.icBatchAttendance,
      ),
      if (_auth.canModule(AppPermissions.fees))
      ModuleItem(
        'Fees',
        () => Get.toNamed(AppRoutes.instituteFees),
        AppImages.icModuleFees,
      ),
      if (_auth.canModule(AppPermissions.staff))
      ModuleItem(
        'Staffs',
        () => Get.toNamed(AppRoutes.instituteStaffs),
        AppImages.icModuleStaff,
      ),
      if (_auth.can(AppPermissions.chatAccess))
      ModuleItem(
        'Chats',
        () => Get.toNamed(AppRoutes.instituteChats),
        AppImages.icModuleChat,
        // Conversations with unread messages (updated live by the socket).
        badgeCount: () => Get.find<ChatController>().chatsList
            .where((c) => c.unreadCount > 0)
            .length,
      ),
      if (_auth.canModule(AppPermissions.reports))
      ModuleItem(
        'Reports',
        () => Get.toNamed(AppRoutes.instituteReports),
        AppImages.icModuleReports,
      ),
      if (!_auth.isSubAccess)
      ModuleItem(
        'Leads',
        () => Get.toNamed(AppRoutes.instituteLeads),
        AppImages.icModuleLead,
      ),
      if (_auth.can(AppPermissions.notesManage))
      ModuleItem(
        'Notes',
        () => Get.toNamed(AppRoutes.instituteNotes),
        AppImages.icModuleNotes,
      ),
      if (_auth.can(AppPermissions.expensesManage))
      ModuleItem(
        'Expenses',
        () => Get.toNamed(AppRoutes.instituteExpenses),
        AppImages.icModuleExpense,
      ),
      if (!_auth.isSubAccess)
      ModuleItem(
        'Updates',
        () => Get.toNamed(AppRoutes.instituteUpdates),
        AppImages.icModuleUpdates,
      ),
      if (_auth.canModule(AppPermissions.students))
      ModuleItem(
        'Birthdays',
        () => Get.toNamed(AppRoutes.instituteBirthdays),
        AppImages.icBirthdayCake,
        // Today's birthdays only.
        badgeCount: () => Get.find<BirthdayController>().today.length,
        badgeColor: () => AppColors.errorRed,
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
    final tile = _buildGridTile(item, accent);
    if (item.badgeCount == null) return tile;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: tile),
        Positioned(
          top: 8,
          right: 8,
          child: Obx(() {
            final count = item.badgeCount!();
            if (count <= 0) return const SizedBox.shrink();
            return IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(minWidth: 22),
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.badgeColor?.call() ?? AppColors.primaryBrand,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGridTile(ModuleItem item, Color accent) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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

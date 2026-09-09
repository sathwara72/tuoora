import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/batch_details_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_bottom_button.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchStudentsScreen extends StatelessWidget {
  const BatchStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BatchModel batch = Get.arguments;
    final BatchDetailsController controller = Get.find<BatchDetailsController>(
      tag: batch.id,
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: AppStrings.batchStudents),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.x16.add(AppSpacing.y16),
                child: Column(
                  children: [
                    _buildEnrolledHeader(controller),
                    AppSpacing.v24,
                    _buildSearchBar(controller),
                    AppSpacing.v24,
                    _buildAssignedStudentList(controller, context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: InstituteBottomButton(
        label: AppStrings.assignStudent,
        icon: Icons.person_add_alt_1_rounded,
        onTap: () => SubscriptionGuard.runAddAction(
          () => Get.toNamed(
            AppRoutes.instituteAssignToBatch,
            arguments: controller.batch,
          ),
        ),
      ),
    );
  }

  Widget _buildEnrolledHeader(BatchDetailsController controller) {
    return Container(
      padding: AppSpacing.all24,
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
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.totalEnrolled,
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1,
                  ),
                ),
                AppSpacing.v4,
                Text(
                  '${controller.assignedStudents.length}',
                  style: AppTextStyles.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            _buildAvatarStack(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(BatchDetailsController controller) {
    return SizedBox(
      height: 40,
      width: 100,
      child: Stack(
        children: [
          ...List.generate(
            controller.assignedStudents.length > 3
                ? 3
                : controller.assignedStudents.length,
            (index) {
              final student = controller.assignedStudents[index].student;
              return Positioned(
                left: index * 25.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: _buildStackAvatar(
                    imageUrl: student.profileImageUrl,
                    name: student.name,
                    fallbackBgColor: [
                      AppColors.warningBg,
                      AppColors.successBg,
                      AppColors.successBg,
                    ][index % 3],
                  ),
                ),
              );
            },
          ),
          if (controller.assignedStudents.length > 3)
            Positioned(
              left: 75,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.borderGrey,
                  child: Text(
                    '+${controller.assignedStudents.length - 3}',
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Small 36 dp circular avatar used inside the stacked-overlap row in the
  // "TOTAL ENROLLED" header. Renders the student's profile photo when one is
  // available, otherwise falls back to the first letter of their name on a
  // soft tinted background.
  Widget _buildStackAvatar({
    required String? imageUrl,
    required String name,
    required Color fallbackBgColor,
  }) {
    final bool hasPhoto =
        imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com');
    if (hasPhoto) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: fallbackBgColor,
        backgroundImage: CachedNetworkImageProvider(imageUrl),
      );
    }
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 18,
      backgroundColor: fallbackBgColor,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textDarkGrey,
        ),
      ),
    );
  }

  Widget _buildSearchBar(BatchDetailsController controller) {
    return AppSearchField(
      hintText: AppStrings.searchEnrolledStudents,
      controller: controller.assignedSearchController,
      onChanged: (val) => controller.assignedSearchQuery.value = val,
    );
  }

  Widget _buildAssignedStudentList(
    BatchDetailsController controller,
    BuildContext context,
  ) {
    return Obx(() {
      final students = controller.filteredAssignedStudents;
      if (students.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              AppStrings.noStudentsFound,
              style: AppTextStyles.outfit(color: AppColors.textMuted),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final bs = students[index];
          return Container(
            margin: AppSpacing.bottom10,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildStudentAvatar(
                  bs.student.profileImageUrl,
                  bs.student.name,
                ),
                AppSpacing.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bs.student.name,
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _getEnrollmentText(bs.student),
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _showRemoveConfirmation(context, controller, bs),
                  icon: const AppActionIcon(
                    asset: AppImages.icDelete,
                    size: 24,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _showRemoveConfirmation(
    BuildContext context,
    BatchDetailsController controller,
    BatchStudent bs,
  ) {
    CommonDialog.showDeleteConfirmation(
      title: AppStrings.removeStudent,
      description:
          'Are you sure you want to remove\n${bs.student.name} from this batch?',
      confirmText: AppStrings.labelRemove,
      onConfirm: () => controller.removeStudentFromBatch(bs.student.id),
    );
  }

  Widget _buildStudentAvatar(String? imageUrl, String name) {
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com')) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryBrandLight,
          shape: BoxShape.circle,
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final names = name.trim().split(' ');
    String initials = '';
    if (names.isNotEmpty) {
      initials += names[0][0].toUpperCase();
      if (names.length > 1) {
        initials += names[names.length - 1][0].toUpperCase();
      }
    }

    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.primaryBrandLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
          ),
        ),
      ),
    );
  }

  String _getEnrollmentText(Student student) {
    final enrollmentId = student.enrollmentID?.toString().trim() ?? '';
    if (enrollmentId.isNotEmpty) {
      return 'Enrollment ID: $enrollmentId';
    }
    if (student.idHash.isNotEmpty) {
      return 'Enrollment ID: ${student.idHash}';
    }
    return 'Enrollment ID: ${student.id}';
  }
}

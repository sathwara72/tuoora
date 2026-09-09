import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/attendance_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_bottom_button.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarkAttendanceScreen extends GetView<AttendanceController> {
  const MarkAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              Column(
                children: [
                  InstituteAppBar(
                    title: AppStrings.markAttendance,
                    onBackTap: () => Get.back(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.x16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBatchHeader(controller, context),
                          AppSpacing.v24,
                          if (controller.isEditable) ...[
                            _buildBulkActionButtons(controller),
                            AppSpacing.v24,
                          ],
                          _buildSearchBar(controller),
                          AppSpacing.v24,
                          CommonStateWidget(
                            isLoading: controller.isLoading.value,
                            isEmpty: controller.filteredStudents.isEmpty,
                            emptyTitle: AppStrings.noStudentsFound,
                            emptySubtitle:
                                AppStrings.thereAreNoStudentsAssignedTo,
                            emptyIcon: Icons.group_off_rounded,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: controller.filteredStudents
                                  .map(
                                    (student) => Padding(
                                      padding: AppSpacing.bottom16,
                                      child: _buildStudentCard(
                                        controller,
                                        student,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => (controller.isEditable && controller.allStudents.isNotEmpty)
            ? InstituteBottomButton(
                label: AppStrings.submitAttendance,
                icon: Icons.check_circle_rounded,
                onTap: () => controller.submitAttendance(),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBatchHeader(
    AttendanceController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.batch.title,
          style: AppTextStyles.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.v12,
        GestureDetector(
          onTap: () => controller.selectDate(context),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                AppSpacing.h12,
                Text(
                  controller.formattedDate,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.h12,
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionButtons(AttendanceController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildBulkButton(
            label: AppStrings.allPresent,
            icon: Icons.done_all_rounded,
            color: AppColors.successGreen,
            onTap: () => controller.markAllPresent(),
          ),
        ),
        AppSpacing.h16,
        Expanded(
          child: _buildBulkButton(
            label: AppStrings.allAbsent,
            icon: Icons.person_off_rounded,
            color: AppColors.bohoRed,
            onTap: () => controller.markAllAbsent(),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        padding: AppSpacing.cardPadding,
        backgroundColor: AppColors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          AppSpacing.h8,
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AttendanceController controller) {
    return AppSearchField(
      hintText: AppStrings.searchStudentByNameOrId,
      onChanged: (value) => controller.searchQuery.value = value,
    );
  }

  Widget _buildStudentCard(
    AttendanceController controller,
    AttendanceStudent student,
  ) {
    return Container(
      padding: AppSpacing.all8,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStudentAvatar(student.profileImageUrl, student.name),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  student.enrollmentId != null &&
                          student.enrollmentId!.trim().isNotEmpty
                      ? 'Enrollment ID: ${student.enrollmentId!.trim()}'
                      : 'ID: ${student.id}',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusToggle(controller, student),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(
    AttendanceController controller,
    AttendanceStudent student,
  ) {
    bool isPresent = student.isPresent;
    final isEditable = controller.isEditable;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleOption(
            label: AppStrings.present,
            isSelected: isPresent,
            color: AppColors.successGreen,
            onTap: isEditable
                ? () => controller.toggleStatus(student, true)
                : null,
          ),
          _buildToggleOption(
            label: AppStrings.absent,
            isSelected: !isPresent,
            color: AppColors.bohoRed,
            onTap: isEditable
                ? () => controller.toggleStatus(student, false)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentAvatar(String? imageUrl, String name) {
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com')) {
      return Container(
        width: 48,
        height: 48,
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primaryBrandLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
          ),
        ),
      ),
    );
  }
}

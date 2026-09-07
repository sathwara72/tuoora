import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/presentation/institute/controllers/staff_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/data/models/staff_model.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffProfileScreen extends GetView<StaffController> {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Obx(() {
              final staff = controller.selectedStaff.value;
              return InstituteAppBar(
                title: AppStrings.staffProfile,
                actions: [
                  if (staff != null) ...[
                    IconButton(
                      onPressed: () {
                        controller.loadStaffForEdit(staff);
                        Get.toNamed(AppRoutes.instituteAddEditStaff);
                      },
                      icon: const AppActionIcon(asset: AppImages.icEdit),
                    ),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(),
                      icon: const AppActionIcon(asset: AppImages.icDelete),
                    ),
                  ],
                ],
              );
            }),
            Expanded(
              child: Obx(() {
                final staff = controller.selectedStaff.value;
                if (staff == null) {
                  return const Center(child: Text(AppStrings.noStaffSelected));
                }
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(staff),
                      const Divider(height: 1, color: AppColors.background),
                      _buildInfoSection(staff),
                      AppSpacing.v24,
                      _buildAccountActions(staff),
                      AppSpacing.v32,
                      _buildActionButtons(),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Staff staff) {
    return Container(
      padding: AppSpacing.all24,
      color: AppColors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBrand.withValues(alpha: 0.1),
              ),
              image: DecorationImage(
                image: staff.profileUrl != null
                    ? CachedNetworkImageProvider(staff.profileUrl!)
                    : CachedNetworkImageProvider(
                        'https://ui-avatars.com/api/?name=Staff&background=00A3A3&color=fff',
                      ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          AppSpacing.h20,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.fullName,
                  style: AppTextStyles.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.v8,
                _buildContactItem(
                  Icons.email,
                  staff.email,
                  AppColors.textPrimary,
                ),
                AppSpacing.v8,
                _buildContactItem(
                  Icons.phone,
                  staff.phone,
                  AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String value, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        AppSpacing.h12,
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Staff staff) {
    return Container(
      padding: AppSpacing.all24,
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildSimpleInfo(
              Icons.business,
              'DEPARTMENT',
              staff.departmentNames,
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.background,
            margin: AppSpacing.x16,
          ),
          Expanded(
            child: _buildSimpleInfo(
              Icons.work,
              'EMPLOYMENT TYPE',
              staff.employmentType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfo(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.fieldLabel),
            AppSpacing.h6,
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        AppSpacing.v8,
        Text(
          value,
          style: AppTextStyles.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: AppSpacing.x16,
      child: Row(
        children: [
          Expanded(
            child: _buildLargeButton(
              Icons.calendar_today,
              'Attendance',
              true,
              onTap: () => Get.toNamed(AppRoutes.instituteStaffAttendance),
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: _buildLargeButton(
              Icons.payments,
              'Salary',
              false,
              onTap: () => Get.toNamed(AppRoutes.instituteSalaryHistory),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeButton(
    IconData icon,
    String label,
    bool isFilled, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isFilled ? AppColors.primaryBrand : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.primaryBrand, width: 1.5),
          boxShadow: isFilled
              ? [
                  BoxShadow(
                    color: AppColors.primaryBrand.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isFilled ? AppColors.white : AppColors.primaryBrand,
              size: 20,
            ),
            AppSpacing.h12,
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFilled ? AppColors.white : AppColors.primaryBrand,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions(Staff staff) {
    return Padding(
      padding: AppSpacing.x16,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppButton(
                    label: 'Email Password',
                    onPressed: controller.isSendingPassword.value
                        ? null
                        : () => controller.sendStaffPassword(),
                    isLoading: controller.isSendingPassword.value,
                    icon: Icons.email_outlined,
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.warningAmber,
                    borderColor: AppColors.warningAmber,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s14,
                    ),
                  ),
                ),
              ),
              AppSpacing.h16,
              Expanded(
                child: AppButton(
                  label: 'Reset Password',
                  onPressed: () => _showResetPasswordDialog(staff),
                  icon: Icons.lock_outline,
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.studentProgressBlue,
                  borderColor: AppColors.studentProgressBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.s14,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v16,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Change Email',
                  onPressed: () => _showChangeEmailDialog(staff),
                  icon: Icons.alternate_email_rounded,
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primaryBrand,
                  borderColor: AppColors.primaryBrand,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.s14,
                  ),
                ),
              ),
              AppSpacing.h16,
              Expanded(
                child: Obx(
                  () => AppButton(
                    label: staff.isLoginBlocked ? 'Unblock Login' : 'Block Login',
                    onPressed: controller.isTogglingBlock.value
                        ? null
                        : () => _showBlockLoginConfirmation(staff),
                    isLoading: controller.isTogglingBlock.value,
                    icon: staff.isLoginBlocked
                        ? Icons.lock_open_rounded
                        : Icons.block_rounded,
                    backgroundColor: AppColors.white,
                    foregroundColor: staff.isLoginBlocked
                        ? AppColors.successGreen
                        : AppColors.bohoRed,
                    borderColor: staff.isLoginBlocked
                        ? AppColors.successGreen
                        : AppColors.bohoRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(Staff staff) {
    final passwordController = TextEditingController();
    final obscurePassword = true.obs;

    CommonDialog.show(
      title: 'Reset Staff Password',
      description:
          'Set a new password for ${staff.fullName} directly. It must be 8-15 characters and include an uppercase letter, a lowercase letter, a number, and a special character.',
      confirmText: 'Save Password',
      confirmButtonColor: AppColors.studentProgressBlue,
      body: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.fieldBorder),
          ),
          child: TextField(
            controller: passwordController,
            obscureText: obscurePassword.value,
            style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter new password',
              hintStyle: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () => obscurePassword.toggle(),
              ),
            ),
          ),
        ),
      ),
      onConfirm: () {
        final password = passwordController.text;
        if (password.isEmpty) {
          AppSnackBar.error('Please enter a new password');
          return;
        }
        controller.resetStaffPassword(password);
      },
    );
  }

  void _showChangeEmailDialog(Staff staff) {
    final emailController = TextEditingController(text: staff.email);

    CommonDialog.show(
      title: 'Change Login Email',
      description:
          'Update the email address ${staff.fullName} uses to log in and receive notifications.',
      confirmText: 'Update Email',
      confirmButtonColor: AppColors.primaryBrand,
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new email',
            hintStyle: AppTextStyles.outfit(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
      onConfirm: () {
        final email = emailController.text.trim();
        final error = ValidationUtils.validateEmail(email);
        if (error != null) {
          AppSnackBar.error(error);
          return;
        }
        controller.changeStaffEmail(email);
      },
    );
  }

  void _showBlockLoginConfirmation(Staff staff) {
    final willBlock = !staff.isLoginBlocked;
    CommonDialog.show(
      title: willBlock ? 'Block Staff Login' : 'Unblock Staff Login',
      description: willBlock
          ? '${staff.fullName} will not be able to log in to the app until unblocked. Any active session will be signed out immediately.'
          : '${staff.fullName} will be able to log in again.',
      confirmText: willBlock ? 'Block Login' : 'Unblock Login',
      confirmButtonColor: willBlock ? AppColors.bohoRed : AppColors.successGreen,
      onConfirm: () => controller.toggleStaffBlock(),
    );
  }

  void _showDeleteConfirmation() {
    final staff = controller.selectedStaff.value;
    if (staff == null) return;

    CommonDialog.showDeleteConfirmation(
      title: AppStrings.deleteStaff,
      description: 'Are you sure you want to delete ${staff.fullName}?',
      onConfirm: () async {
        Get.back(); // Close the dialog
        await controller.deleteStaff(staff.id);
      },
    );
  }
}

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_change_password_controller.dart';
import 'package:get/get.dart';

class TeacherChangePasswordScreen
    extends GetView<TeacherChangePasswordController> {
  const TeacherChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !controller.isForced,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  TeacherAppBar(
                    title: AppStrings.labelChangePassword,
                    hideLeading: controller.isForced,
                  ),
                  if (controller.isForced)
                    Padding(
                      padding: AppSpacing.x16,
                      child: Container(
                        padding: AppSpacing.all16,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrand.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                        ),
                        child: Text(
                          'For your security, please set a new password before continuing.',
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryBrand,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.screenPaddingTop,
                      child: _buildUpdatePasswordCard(),
                    ),
                  ),
                ],
              ),
              Obx(
                () => controller.isLoading.value
                    ? Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const CommonLoading(color: AppColors.white),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatePasswordCard() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, AppSpacing.s10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!controller.isForced) ...[
            Obx(
              () => _buildPasswordField(
                label: AppStrings.instCurrentPasswordLabel,
                hint: AppStrings.hintPasswordDots,
                controller: controller.currentPasswordController,
                isVisible: controller.isCurrentPasswordVisible,
                onToggle: controller.toggleCurrentPasswordVisibility,
                errorText: controller.currentPasswordError.value,
              ),
            ),
            AppSpacing.v24,
          ],
          Obx(
            () => _buildPasswordField(
              label: AppStrings.instNewPasswordLabel,
              hint: AppStrings.hintEnterNewPassword,
              controller: controller.newPasswordController,
              isVisible: controller.isNewPasswordVisible,
              onToggle: controller.toggleNewPasswordVisibility,
              errorText: controller.newPasswordError.value,
            ),
          ),
          AppSpacing.v24,
          Obx(
            () => _buildPasswordField(
              label: AppStrings.instConfirmPasswordLabel,
              hint: AppStrings.confirmNewPassword,
              controller: controller.confirmPasswordController,
              isVisible: controller.isConfirmPasswordVisible,
              onToggle: controller.toggleConfirmPasswordVisibility,
              errorText: controller.confirmPasswordError.value,
            ),
          ),
          AppSpacing.v32,
          AppButton(
            label: AppStrings.instUpdatePasswordBtn,
            icon: Icons.lock_reset_rounded,
            onPressed: () => controller.updatePassword(),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required RxBool isVisible,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDarkGrey,
          ),
        ),
        AppSpacing.v12,
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: errorText != null
                  ? Border.all(color: Colors.redAccent, width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: !isVisible.value,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.fieldLabel,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    isVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.fieldLabel,
                    size: AppSpacing.s20,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: AppTextStyles.outfit(
                fontSize: 12,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

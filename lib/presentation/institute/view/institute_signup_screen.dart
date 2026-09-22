import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/widgets/app_logo.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/widgets/app_back_button.dart';
import 'package:tuoora/core/widgets/brand_backdrop.dart';
import 'package:tuoora/core/widgets/fit_screen.dart';

class InstituteSignupScreen extends GetView<SignupController> {
  const InstituteSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LoginBackdrop(
        image: AppImages.roleInstitute,
        tagline: 'Manage\nGrow\nSucceed',
        quote: '\u201cEmpowering Institutes\nfor a Brighter Tomorrow\u201d',
        child: SafeArea(
          child: FitScreen(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                    child: const AppBackButton(),
                  ),
                ),
                const AppLogo(height: 48),
                const SizedBox(height: 6),
                Text(
                  AppStrings.smartInstituteErp,
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.tagLine,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBrand,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFormCard(),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAnAccount,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.fieldLabel,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        AppStrings.signInButton,
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: AppSpacing.x16,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLabel('Institute Name'),
          AppSpacing.v8,
          Obx(
            () => _buildTextField(
              controller: controller.instituteNameController,
              hint: AppStrings.enterInstituteName,
              prefixIcon: Icons.business_outlined,
              errorText: controller.instituteNameError.value,
              onChanged: (_) {
                if (controller.instituteNameError.value != null) {
                  controller.instituteNameError.value = null;
                }
              },
            ),
          ),
          AppSpacing.v16,
          _buildLabel('Owner Name'),
          AppSpacing.v8,
          Obx(
            () => _buildTextField(
              controller: controller.instituteOwnerNameController,
              hint: AppStrings.enterOwnerName,
              prefixIcon: Icons.person,
              errorText: controller.ownerNameError.value,
              onChanged: (_) {
                if (controller.ownerNameError.value != null) {
                  controller.ownerNameError.value = null;
                }
              },
            ),
          ),
          AppSpacing.v16,
          _buildLabel('Email Address'),
          AppSpacing.v8,
          Obx(
            () => _buildTextField(
              controller: controller.emailController,
              hint: AppStrings.hintEnterEmail,
              prefixIcon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
              errorText: controller.emailError.value,
              onChanged: (_) {
                if (controller.emailError.value != null) {
                  controller.emailError.value = null;
                }
              },
            ),
          ),
          AppSpacing.v16,
          _buildLabel('Password'),
          AppSpacing.v8,
          Obx(
            () => _buildTextField(
              controller: controller.passwordController,
              hint: AppStrings.hintPasswordDots,
              prefixIcon: Icons.lock_outline,
              obscureText: controller.obscurePassword.value,
              errorText: controller.passwordError.value,
              onChanged: (_) {
                if (controller.passwordError.value != null) {
                  controller.passwordError.value = null;
                }
              },
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                  size: AppSpacing.s20,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),
          AppSpacing.v20,
          Obx(
            () => AppButton(
              label: AppStrings.createAccount,
              onPressed: controller.register,
              isLoading: controller.isLoading.value,
              backgroundColor: AppColors.primaryBrand,
              foregroundColor: AppColors.white,
              trailingIcon: Icons.arrow_forward_rounded,
              borderRadius: 14,
              fontSize: 17,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.fieldLabel,
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: hasError ? Colors.redAccent : AppColors.fieldBorder,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
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
              prefixIcon: Icon(
                prefixIcon,
                color: AppColors.fieldLabel,
                size: AppSpacing.s20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: AppSpacing.all16,
            ),
          ),
        ),
        if (hasError) ...[
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

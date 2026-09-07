import 'package:tuoora/core/widgets/app_logo.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/controllers/forgot_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.forgotPassword,
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: AppSpacing.screenPaddingTop,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - AppSpacing.s16,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: AppLogo(height: AppSpacing.s48),
                          ),
                          AppSpacing.v12,
                          Text(
                            AppStrings.enterYourRegisteredEmailAddressAnd,
                            style: AppTextStyles.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryBrand,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.v24,
                          Container(
                            padding: AppSpacing.cardPadding,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.cardRadius,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: AppSpacing.s24,
                                  offset: const Offset(0, AppSpacing.s12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  AppStrings.instEmailAddressLabel,
                                  style: AppTextStyles.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.fieldLabel,
                                    letterSpacing: 1.0,
                                  ),
                                ),
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
                                AppSpacing.v32,
                                Obx(
                                  () => AppButton(
                                    label: AppStrings.sendResetCode,
                                    onPressed: controller.sendOtp,
                                    isLoading: controller.isLoading.value,
                                    backgroundColor: AppColors.primaryBrand,
                                    foregroundColor: AppColors.white,
                                    borderRadius: AppSpacing.cardRadius,
                                    fontSize: 16,
                                    fullWidth: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
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

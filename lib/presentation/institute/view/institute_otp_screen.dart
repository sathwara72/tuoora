import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/widgets/app_logo.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:get/get.dart';

class InstituteOtpScreen extends GetView<SignupController> {
  const InstituteOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppSpacing.v32,
              _buildHeader(),
              AppSpacing.v40,
              Container(
                margin: AppSpacing.x16,
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: AppSpacing.s24,
                      offset: const Offset(0, AppSpacing.s12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Enter Code'),
                    AppSpacing.v16,
                    Obx(() => _buildOtpField()),
                    AppSpacing.v32,
                    Obx(
                      () => AppButton(
                        label: AppStrings.verify,
                        onPressed: controller.verifyOtp,
                        isLoading: controller.isLoading.value,
                        backgroundColor: AppColors.primaryBrand,
                        foregroundColor: AppColors.white,
                        borderRadius: AppSpacing.cardRadius,
                        fontSize: 16,
                        fullWidth: true,
                      ),
                    ),
                    AppSpacing.v24,
                    Obx(
                      () => Center(
                        child: Column(
                          children: [
                            if (!controller.canResend.value)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Didn\'t receive the code? ',
                                    style: AppTextStyles.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '00:${controller.timerSeconds.value.toString().padLeft(2, '0')}',
                                    style: AppTextStyles.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBrand,
                                    ),
                                  ),
                                ],
                              ),
                            if (controller.canResend.value)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Didn\'t receive the code? ',
                                    style: AppTextStyles.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: controller.resendOtp,
                                    child: Text(
                                      AppStrings.resendOtp,
                                      style: AppTextStyles.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBrand,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.v32,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AppLogo(height: AppSpacing.s48),
        AppSpacing.v32,
        Text(
          AppStrings.checkYourEmail,
          style: AppTextStyles.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBrand,
            letterSpacing: 1.5,
          ),
        ),
        AppSpacing.v8,
        Padding(
          padding: AppSpacing.x16,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBrand,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: 'We have sent a 6-digit verification code to: ',
                ),
                TextSpan(
                  text: controller.emailController.text,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandAppBarColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.fieldLabel,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildOtpField() {
    final errorText = controller.otpError.value;
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
            controller: controller.otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            onChanged: (_) {
              if (controller.otpError.value != null) {
                controller.otpError.value = null;
              }
            },
            style: AppTextStyles.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.brandAppBarColor,
              letterSpacing: 8.0,
            ),
            decoration: const InputDecoration(
              counterText: '',
              hintText: AppStrings.xxxxxx,
              hintStyle: TextStyle(
                color: AppColors.fieldLabel,
                letterSpacing: 8.0,
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

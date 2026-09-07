import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/widgets/app_logo.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/shared/controllers/login_controller.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginController get controller => Get.find<LoginController>();
  String _selectedRole = 'STUDENT';

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      _selectedRole = Get.arguments;
    }
  }

  void _handleLogin() {
    controller.login(_selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          GetStorage().remove('last_selected_role');
                          Get.offAllNamed(AppRoutes.roleSelection);
                        },
                      ),
                    ),
                    AppSpacing.v16,
                    AppLogo(height: AppSpacing.s48),
                    AppSpacing.v12,
                    Text(
                      AppStrings.tagLine,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBrand,
                        height: 1.5,
                      ),
                    ),
                    AppSpacing.v32,
                    Container(
                      margin: AppSpacing.x16,
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
                          Obx(() {
                            final err = controller.accountError.value;
                            if (err == null || err.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.s16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s12,
                                vertical: AppSpacing.s10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.errorBg,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.cardRadius,
                                ),
                                border: Border.all(
                                  color: AppColors.bohoRed.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_rounded,
                                    color: AppColors.bohoRed,
                                    size: 18,
                                  ),
                                  AppSpacing.h8,
                                  Expanded(
                                    child: Text(
                                      err,
                                      style: AppTextStyles.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.bohoRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
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
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              errorText: controller.emailError.value,
                              onChanged: (_) {
                                if (controller.emailError.value != null) {
                                  controller.emailError.value = null;
                                }
                              },
                            ),
                          ),
                          AppSpacing.v24,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.password,
                                style: AppTextStyles.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.fieldLabel,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              if (_selectedRole == 'INSTITUTE')
                                TextButton(
                                  onPressed: () {
                                    Get.toNamed(
                                      AppRoutes.instituteForgotPassword,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    AppStrings.loginForgotPassword,
                                    style: AppTextStyles.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBrand,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                            ],
                          ),
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
                          AppSpacing.v24,
                          Obx(
                            () => Row(
                              children: [
                                SizedBox(
                                  width: AppSpacing.s24,
                                  height: AppSpacing.s24,
                                  child: Checkbox(
                                    value: controller.stayAuthenticated.value,
                                    onChanged: (value) =>
                                        controller.toggleStayAuthenticated(),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.s6,
                                      ),
                                    ),
                                    side: BorderSide(
                                      color: AppColors.borderLightGray,
                                      width: 1.5,
                                    ),
                                    activeColor: AppColors.primaryBrand,
                                  ),
                                ),
                                AppSpacing.h12,
                                Text(
                                  AppStrings.rememberMe,
                                  style: AppTextStyles.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.fieldLabel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.v32,
                          Obx(
                            () => AppButton(
                              label: AppStrings.signInButton,
                              onPressed: _handleLogin,
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
                    if (_selectedRole == 'INSTITUTE') ...[
                      AppSpacing.v32,
                      Padding(
                        padding: AppSpacing.x24,
                        child: Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: AppSpacing.x16,
                              child: Text(
                                AppStrings.orExpandYourReach,
                                style: AppTextStyles.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBrand,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                      ),
                      AppSpacing.v32,
                      Padding(
                        padding: AppSpacing.x16,
                        child: AppButton(
                          label: AppStrings.instituteRegistration,
                          onPressed: () =>
                              Get.toNamed(AppRoutes.instituteSignup),
                          icon: Icons.storefront_outlined,
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primaryBrand,
                          borderColor: AppColors.borderGrey,
                          borderRadius: AppSpacing.cardRadius,
                          fontSize: 16,
                          fullWidth: true,
                        ),
                      ),
                    ],
                    AppSpacing.v32,
                  ],
                ),
              ),
            ),
          ),
        ),
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

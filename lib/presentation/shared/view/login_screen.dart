import 'dart:io' show Platform;

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
import 'package:tuoora/core/widgets/app_back_button.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/widgets/brand_backdrop.dart';
import 'package:tuoora/core/widgets/fit_screen.dart';

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

  _RoleTheme get _theme => switch (_selectedRole) {
    'INSTITUTE' => const _RoleTheme(
      image: AppImages.roleInstitute,
      icon: Icons.apartment_rounded,
      color: AppColors.primaryBrand,
      title: 'Institute Login',
      subtitle: 'Manage students, batches, and academic operations.',
      account: 'Institute',
      tagline: 'Manage\nGrow\nSucceed',
      bottomLeft: '',
      heroSubtitle: '',
      quote: '\u201cEmpowering Institutes\nfor a Brighter Tomorrow\u201d',
    ),
    'TEACHER' => const _RoleTheme(
      image: AppImages.roleTeacher,
      icon: Icons.co_present_rounded,
      color: Color(0xFF16A860),
      title: 'Teacher Login',
      subtitle: 'Manage your batches, attendance, and grades.',
      account: 'Teacher',
      tagline: 'Teach\nGuide\nInspire',
      bottomLeft: 'Education\nBuilds\nBetter Futures',
      heroSubtitle: 'Manage your batches, attendance, grades and more.',
      quote: '\u201cInspiring Minds\nfor a Brighter Tomorrow\u201d',
    ),
    _ => const _RoleTheme(
      image: AppImages.roleStudent,
      icon: Icons.school_rounded,
      color: Color(0xFF1D7AF2),
      title: 'Student Login',
      subtitle: 'View your classes, fees, homework and more.',
      account: 'Student',
      tagline: 'Learn\nPractice\nGrow',
      bottomLeft: 'Better\nEducation\nBrighter\nTomorrow',
      heroSubtitle: 'Access your classes, fees, homework and more.',
      quote: '\u201cLearning Today\nfor a Brighter Tomorrow\u201d',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final hasHero = _selectedRole != 'INSTITUTE';
    final content = SafeArea(
      child: FitScreen(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                child: AppBackButton(
                  onTap: () {
                    Get.offAllNamed(AppRoutes.roleSelection);
                  },
                ),
              ),
            ),
            const AppLogo(height: 48),
            if (hasHero) ..._heroHeader(theme) else ..._instituteHeader(theme),
            _buildFormCard(theme, showBanner: !hasHero),
            if (_selectedRole == 'INSTITUTE' && !Platform.isIOS)
              ..._institutionRegistration(),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: hasHero
          ? RoleLoginBackdrop(
              style: _selectedRole == 'TEACHER'
                  ? RoleBackdropStyle.teacher
                  : RoleBackdropStyle.student,
              tagline: theme.tagline,
              bottomLeft: theme.bottomLeft,
              bottomLeftOffset: _selectedRole == 'TEACHER' ? 112 : 44,
              child: content,
            )
          : LoginBackdrop(
              image: theme.image,
              tagline: theme.tagline,
              quote: theme.quote,
              child: content,
            ),
    );
  }

  List<Widget> _instituteHeader(_RoleTheme theme) => [
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
    _orangeTagline(),
    const SizedBox(height: 28),
  ];

  List<Widget> _heroHeader(_RoleTheme theme) => [
    const SizedBox(height: 6),
    _orangeTagline(),
    const SizedBox(height: 22),
    Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        0,
        _selectedRole == 'TEACHER' ? 28 : 12,
        0,
      ),
      child: Row(
        children: [
          Image.asset(
            theme.image,
            width: 104,
            height: 96,
            fit: BoxFit.contain,
            cacheWidth: 320,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.title,
                  style: AppTextStyles.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedRole == 'STUDENT')
            Opacity(
              opacity: 0.4,
              child: Image.asset(
                theme.image,
                width: 60,
                fit: BoxFit.contain,
                cacheWidth: 180,
              ),
            ),
        ],
      ),
    ),
    const SizedBox(height: 12),
  ];

  Widget _orangeTagline() => Text(
    AppStrings.tagLine,
    style: AppTextStyles.outfit(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryBrand,
    ),
  );

  /// Shown for institutes on non-iOS only; App Store builds don't offer
  /// self-registration.
  List<Widget> _institutionRegistration() => [
    const SizedBox(height: 22),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.borderGrey)),
          Padding(
            padding: AppSpacing.x16,
            child: Text(
              AppStrings.orExpandYourReach,
              style: AppTextStyles.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                letterSpacing: 2,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.borderGrey)),
        ],
      ),
    ),
    const SizedBox(height: 18),
    Padding(
      padding: AppSpacing.x16,
      child: AppButton(
        label: AppStrings.instituteRegistration,
        onPressed: () => Get.toNamed(AppRoutes.instituteSignup),
        icon: Icons.storefront_outlined,
        trailingIcon: Icons.arrow_forward_rounded,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryBrand,
        borderColor: AppColors.primaryBrand.withValues(alpha: 0.5),
        borderRadius: 14,
        fontSize: 16,
        fullWidth: true,
        hasShadow: false,
      ),
    ),
  ];

  Widget _buildFormCard(_RoleTheme theme, {required bool showBanner}) {
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
          if (showBanner) ...[_buildRoleBanner(theme), AppSpacing.v16],
          Obx(() {
            final err = controller.accountError.value;
            if (err == null || err.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s16),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s12,
                vertical: AppSpacing.s10,
              ),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(
                  color: AppColors.bohoRed.withValues(alpha: 0.25),
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
          _fieldLabel(AppStrings.instEmailAddressLabel),
          AppSpacing.v8,
          Obx(
            () => _buildTextField(
              controller: controller.emailController,
              hint: AppStrings.hintEnterEmailAddress,
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
          AppSpacing.v16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fieldLabel(AppStrings.password),
              if (_selectedRole == 'INSTITUTE' || _selectedRole == 'TEACHER')
                TextButton(
                  onPressed: () {
                    Get.toNamed(
                      _selectedRole == 'TEACHER'
                          ? AppRoutes.teacherForgotPassword
                          : AppRoutes.instituteForgotPassword,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppStrings.loginForgotPassword,
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.v8,
          Obx(
            () => _buildTextField(
              controller: controller.passwordController,
              hint: AppStrings.hintEnterPassword,
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
          AppSpacing.v16,
          Obx(
            () => Row(
              children: [
                SizedBox(
                  width: AppSpacing.s24,
                  height: AppSpacing.s24,
                  child: Checkbox(
                    value: controller.stayAuthenticated.value,
                    onChanged: (value) => controller.toggleStayAuthenticated(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.s6),
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
          AppSpacing.v20,
          Obx(
            () => AppButton(
              label: AppStrings.signInButton,
              onPressed: _handleLogin,
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

  Widget _fieldLabel(String text) => Text(
    text,
    style: AppTextStyles.outfit(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.fieldLabel,
    ),
  );

  Widget _buildRoleBanner(_RoleTheme theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.12,
              child: SizedBox(
                width: 60,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: List.generate(
                    6,
                    (_) => Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: theme.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Image.asset(
                theme.image,
                width: 72,
                height: 64,
                fit: BoxFit.contain,
                cacheWidth: 220,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.title,
                      style: AppTextStyles.outfit(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      theme.subtitle,
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ],
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

class _RoleTheme {
  final String image;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String account;
  final String tagline;
  final String quote;
  final String bottomLeft;
  final String heroSubtitle;

  const _RoleTheme({
    required this.image,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.account,
    required this.tagline,
    required this.quote,
    required this.bottomLeft,
    required this.heroSubtitle,
  });
}

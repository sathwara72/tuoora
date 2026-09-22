import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_back_button.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_logo.dart';
import 'package:tuoora/core/widgets/fit_screen.dart';
import 'package:tuoora/core/widgets/brand_backdrop.dart' show paintBookSketch;
import 'package:tuoora/core/widgets/reset_password_illustration.dart';

/// Shared "Forgot Password" screen body for the institute and teacher flows.
/// Both controllers expose the same email field, error and loading state.
class ForgotPasswordLayout extends StatelessWidget {
  final TextEditingController emailController;
  final RxnString emailError;
  final RxBool isLoading;
  final VoidCallback onSend;

  const ForgotPasswordLayout({
    super.key,
    required this.emailController,
    required this.emailError,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ForgotBackdrop(
        child: SafeArea(
          child: FitScreen(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(),
                const SizedBox(height: 34),
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
                const SizedBox(height: 18),
                const ResetPasswordIllustration(width: 250),
                const SizedBox(height: 14),
                Text(
                  AppStrings.resetYourPassword,
                  style: AppTextStyles.outfit(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.resetPasswordHint,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _card(),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.borderGrey),
                      ),
                      Padding(
                        padding: AppSpacing.x16,
                        child: Text(
                          AppStrings.rememberYourPassword,
                          style: AppTextStyles.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.borderGrey),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.back(),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: AppColors.primaryBrand,
                  ),
                  label: Text(
                    AppStrings.backToLogin,
                    style: AppTextStyles.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 16),
          Text(
            AppStrings.forgotPassword,
            style: AppTextStyles.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card() {
    return Container(
      margin: AppSpacing.x16,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            AppStrings.instEmailAddressLabel,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.fieldLabel,
            ),
          ),
          AppSpacing.v8,
          Obx(() {
            final error = emailError.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: error != null
                          ? Colors.redAccent
                          : AppColors.fieldBorder,
                      width: error != null ? 1.5 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if (emailError.value != null) emailError.value = null;
                    },
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: AppStrings.hintEnterRegisteredEmail,
                      hintStyle: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.fieldLabel,
                      ),
                      prefixIcon: const Icon(
                        Icons.mail,
                        color: AppColors.fieldLabel,
                        size: AppSpacing.s20,
                      ),
                      border: InputBorder.none,
                      contentPadding: AppSpacing.all16,
                    ),
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      error,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            );
          }),
          AppSpacing.v20,
          Obx(
            () => AppButton(
              label: AppStrings.sendResetCode,
              onPressed: onSend,
              isLoading: isLoading.value,
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
}

/// Backdrop for the forgot-password screens: soft blobs, orange/teal hills,
/// a "Don't worry" note top-right, and the tagline + book along the bottom.
class ForgotBackdrop extends StatelessWidget {
  final Widget child;

  const ForgotBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(child: CustomPaint(painter: _ForgotPainter())),
        ),
        Positioned(
          left: 26,
          bottom: 104,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: -0.28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Education\nBuilds\nBetter Futures',
                    style: GoogleFonts.caveat(
                      fontSize: 17,
                      height: 1.0,
                      color: const Color(0xFF6B7A99),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 56,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
        Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 20, 0),
                child: Transform.rotate(
                  angle: -0.14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Don’t\nWorry\nWe’ve Got You!',
                        textAlign: TextAlign.end,
                        style: GoogleFonts.caveat(
                          fontSize: 16,
                          height: 1.0,
                          color: const Color(0xFF2D3A55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 56,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6B94B),
                          borderRadius: BorderRadius.circular(2),
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
    );
  }
}

class _ForgotPainter extends CustomPainter {
  const _ForgotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void blob(double cx, double cy, double r, Color c) =>
        canvas.drawCircle(Offset(w * cx, h * cy), w * r, Paint()..color = c);

    blob(1.0, 0.02, 0.26, const Color(0xFFFDEFDF));
    blob(-0.02, 0.26, 0.10, const Color(0xFFE8F1FB));
    blob(1.05, 0.90, 0.10, const Color(0xFFE3F4EA));

    final teal = Path()
      ..moveTo(0, h * 0.905)
      ..cubicTo(w * 0.15, h * 0.885, w * 0.30, h * 0.94, w * 0.52, h * 0.985)
      ..lineTo(w * 0.60, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      teal,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8FD8C6), Color(0xFF2BB39A)],
        ).createShader(Rect.fromLTWH(0, h * 0.88, w * 0.6, h * 0.12)),
    );

    final orange = Path()
      ..moveTo(w * 0.22, h)
      ..cubicTo(w * 0.42, h * 0.945, w * 0.68, h * 0.955, w, h * 0.96)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      orange,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFAB35A), Color(0xFFFDE2B8)],
        ).createShader(Rect.fromLTWH(w * 0.2, h * 0.94, w * 0.8, h * 0.06)),
    );

    paintBookSketch(canvas, Offset(w * 0.82, h * 0.885), w * 0.24);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

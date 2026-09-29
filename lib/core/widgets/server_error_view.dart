import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/bug_report_service.dart';
import 'package:tuoora/core/services/server_error_handler.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';

class ServerErrorView extends StatelessWidget {
  final ServerErrorHandler handler;
  final String? message;

  const ServerErrorView({super.key, required this.handler, this.message});

  Future<void> _emailSupport() async {
    final opened = await BugReportService.to.emailSupport();
    if (!opened) {
      AppSnackBar.error(
        'No email app found. Please write to ${BugReportService.supportEmail}.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.all24,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBrandLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 72,
                    color: AppColors.primaryBrand,
                  ),
                ),
                AppSpacing.v32,
                Text(
                  'Server Connection Issue',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.v12,
                Text(
                  message ??
                      "We're having trouble reaching our servers right now. This is usually temporary — please try again in a moment.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.v32,
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: handler.isRetrying.value
                          ? 'Checking...'
                          : 'Try Again',
                      icon: Icons.refresh_rounded,
                      isLoading: handler.isRetrying.value,
                      onPressed: handler.isRetrying.value
                          ? null
                          : handler.retry,
                    ),
                  ),
                ),
                Obx(
                  () => handler.retryFailed.value
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Still unable to reach the server. Please try again shortly.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.outfit(
                              fontSize: 12.5,
                              color: AppColors.errorRed,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                AppSpacing.v16,
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    children: [
                      const TextSpan(
                        text: 'If the problem persists, contact ',
                      ),
                      TextSpan(
                        text: BugReportService.supportEmail,
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBrand,
                        ).copyWith(decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _emailSupport,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.v8,
                Text(
                  'Tap the address to send us the error details.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

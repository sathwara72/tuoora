import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/theme/app_spacing.dart';

class SubscriptionBanner extends StatelessWidget {
  const SubscriptionBanner({super.key});

  void _handleRenewAction() {
    Get.toNamed(AppRoutes.instituteSubscription);
  }

  @override
  Widget build(BuildContext context) {
    // No subscription/renewal screen ships on iOS, so this banner — which
    // exists only to surface subscription status and a renew action — has
    // nothing to show or link to there.
    if (Platform.isIOS) return const SizedBox.shrink();

    final authService = Get.find<AuthService>();

    return Obx(() {
      final subscription = authService.subscription;
      if (subscription == null || subscription.isActive) {
        return const SizedBox.shrink();
      }

      if (subscription.isExpireSoon) {
        final daysLeft = subscription.daysLeft;
        return _buildBanner(
          icon: Icons.warning_amber_rounded,
          accent: AppColors.primaryBrand,
          background: AppColors.primaryBrandLight,
          title: 'Your Plan is Expiring Soon!',
          messageWidget: RichText(
            text: TextSpan(
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textTertiary,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Your subscription has only '),
                TextSpan(
                  text: '$daysLeft ${daysLeft == 1 ? 'Day' : 'Days'} Left',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBrand,
                  ),
                ),
                const TextSpan(
                  text: '. Renew now to prevent any service disruption.',
                ),
              ],
            ),
          ),
          action: 'Renew Subscription Now',
          onAction: _handleRenewAction,
        );
      }

      if (subscription.isPending) {
        return _buildBanner(
          icon: Icons.autorenew_rounded,
          accent: AppColors.warningAmber,
          background: AppColors.warningBg,
          title: 'Renewal Request Pending Review',
          message:
              'We have received your payment proof and transaction reference. Our billing team will verify it shortly.',
        );
      }

      if (subscription.isReject) {
        return _buildBanner(
          icon: Icons.cancel_outlined,
          accent: AppColors.errorRed,
          background: AppColors.errorBg,
          title: 'Renewal Request Rejected',
          message:
              'Your previous renewal request was rejected. Please review your payment details and submit again.',
          action: 'Try Again',
          onAction: _handleRenewAction,
        );
      }

      if (subscription.isCancel) {
        return _buildBanner(
          icon: Icons.do_not_disturb_alt_rounded,
          accent: AppColors.errorRed,
          background: AppColors.errorBg,
          title: 'Subscription Cancelled',
          message:
              'Your subscription has been cancelled. Please renew to restore full functionality to your institute.',
          action: 'Renew Subscription Now',
          onAction: _handleRenewAction,
        );
      }

      // Default to expired for any other non-active states
      return _buildBanner(
        icon: Icons.error_outline_rounded,
        accent: AppColors.errorRed,
        background: AppColors.errorBg,
        title: AppStrings.yourSubscriptionHasBeenExpired,
        message:
            'Primary academic and data management operations are restricted. Renew now to restore full access.',
        action: 'Renew Subscription Now',
        onAction: _handleRenewAction,
      );
    });
  }

  Widget _buildBanner({
    required IconData icon,
    required Color accent,
    required Color background,
    required String title,
    String? message,
    Widget? messageWidget,
    String? action,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        0,
      ),
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSpacing.all8,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.s8),
            ),
            child: Icon(icon, color: accent, size: AppSpacing.s20),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
                AppSpacing.v4,
                ?messageWidget,
                if (message != null)
                  Text(
                    message,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                if (action != null && onAction != null) ...[
                  AppSpacing.v12,
                  GestureDetector(
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                        vertical: AppSpacing.s10,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(AppSpacing.s8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: AppColors.white,
                            size: AppSpacing.s16,
                          ),
                          AppSpacing.h8,
                          Text(
                            action,
                            style: AppTextStyles.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

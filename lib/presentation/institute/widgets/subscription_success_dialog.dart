import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';

class SubscriptionSuccessDialog extends StatelessWidget {
  final String planName;
  final int addedDays;
  final DateTime? expiresAt;

  /// Lifetime plans show "Lifetime access" instead of added days and expiry.
  final bool isLifetime;

  const SubscriptionSuccessDialog({
    super.key,
    required this.planName,
    required this.addedDays,
    this.expiresAt,
    this.isLifetime = false,
  });

  static void show({
    required String planName,
    required int addedDays,
    DateTime? expiresAt,
    bool isLifetime = false,
  }) {
    Get.dialog(
      SubscriptionSuccessDialog(
        planName: planName,
        addedDays: addedDays,
        expiresAt: expiresAt,
        isLifetime: isLifetime,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiryStr = expiresAt != null && !isLifetime
        ? DateFormat('dd MMM yyyy').format(expiresAt!)
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: AppColors.primaryBrandLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryBrand,
                size: 34,
              ),
            ),
            AppSpacing.v16,
            Text(
              'Plan Activated!',
              style: AppTextStyles.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.v4,
            Text(
              planName,
              textAlign: TextAlign.center,
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.v20,
            Divider(color: AppColors.fieldBorder, height: 1),
            AppSpacing.v20,
            Text(
              isLifetime ? 'Lifetime access' : '+$addedDays Days Extended',
              style: AppTextStyles.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBrand,
              ),
            ),
            if (expiryStr != null) ...[
              AppSpacing.v12,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: AppColors.successGreen,
                    ),
                    AppSpacing.h6,
                    Text(
                      'Expires $expiryStr',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            AppSpacing.v24,
            AppButton(onPressed: () => Get.back(), label: 'Got it'),
          ],
        ),
      ),
    );
  }
}

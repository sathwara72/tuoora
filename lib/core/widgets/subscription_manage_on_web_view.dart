import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';

/// Placeholder shown on iOS in place of a purchase/subscription screen.
/// iOS builds expose no purchase flow — native or web — so this carries no
/// link or call to action, just a neutral message.
class SubscriptionManageOnWebView extends StatelessWidget {
  final String message;

  const SubscriptionManageOnWebView({
    super.key,
    this.message = AppStrings.contactAdministrationMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.all24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBrandLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  size: 60,
                  color: AppColors.primaryBrand,
                ),
              ),
              AppSpacing.v24,
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/constants/url_constants.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/url_launcher_utils.dart';
import 'package:tuoora/core/widgets/app_button.dart';

/// Redirects real-money purchases to the external browser on iOS instead of
/// running Razorpay natively — Apple requires digital purchases made inside
/// the app to go through Apple's own IAP, so any Razorpay-backed purchase
/// (subscriptions, the White Label add-on, etc.) sends iOS users to the web
/// to complete payment instead.
class SubscriptionManageOnWebView extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final String url;

  const SubscriptionManageOnWebView({
    super.key,
    this.title = AppStrings.subscriptionManageOnWebTitle,
    this.message = AppStrings.subscriptionManageOnWebMessage,
    this.buttonLabel = AppStrings.subscriptionOpenWebButton,
    this.url = UrlConstants.urlInstituteSubscription,
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
                  Icons.open_in_browser_rounded,
                  size: 60,
                  color: AppColors.primaryBrand,
                ),
              ),
              AppSpacing.v24,
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.v12,
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.v32,
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: buttonLabel,
                  icon: Icons.open_in_new_rounded,
                  onPressed: () => UrlLauncherUtils.openExternal(url),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

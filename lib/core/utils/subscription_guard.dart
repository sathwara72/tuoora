import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/data/models/subscription_model.dart';

/// Gates "add / create" actions for the INSTITUTE role behind an active
/// subscription. When the subscription is expired (or a renewal is still
/// pending review) every add action is blocked and the user is nudged to renew.
/// Edit and delete actions are intentionally NOT gated.
///
/// Student sessions never carry a subscription, so this is inert for them.
class SubscriptionGuard {
  const SubscriptionGuard._();

  static Subscription? get _subscription {
    if (!Get.isRegistered<AuthService>()) return null;
    return Get.find<AuthService>().subscription;
  }

  /// True when add actions must be blocked — there is a subscription and it
  /// isn't active (expired, or pending renewal review). Read at build time to
  /// grey out add affordances (Android/Web) or hide them outright (iOS).
  static bool get blocksAdd {
    final sub = _subscription;
    return sub != null && !(sub.isActive || sub.isExpireSoon);
  }

  /// iOS ships no renewal/purchase screen to send a blocked user to, so the
  /// add affordance itself is hidden rather than shown-and-intercepted.
  /// Screens should skip rendering their add button/FAB entirely when true.
  static bool get hideAddOnIOS => Platform.isIOS && blocksAdd;

  /// Runs [onAllowed] only when adding is permitted. Otherwise shows a prompt
  /// explaining why — on Android/Web, offering to open the renewal screen; on
  /// iOS (reachable only defensively, since [hideAddOnIOS] hides the button
  /// itself) a neutral message with no subscription/purchase wording or
  /// navigation.
  static void runAddAction(VoidCallback onAllowed) {
    final sub = _subscription;
    if (sub == null || sub.isActive || sub.isExpireSoon) {
      onAllowed();
      return;
    }

    if (Platform.isIOS) {
      CommonDialog.show(
        title: AppStrings.contactAdministrationMessage,
        icon: Icons.info_outline_rounded,
        iconColor: AppColors.primaryBrand,
        iconBgColor: AppColors.primaryBrandLight,
        showButtons: false,
        showCloseIcon: true,
        onConfirm: () {},
      );
      return;
    }

    if (sub.isPending) {
      AppSnackBar.warning(
        'Your renewal request is under review. Adding new records will be '
        'enabled once your subscription is reactivated.',
        title: AppStrings.renewalUnderReview,
      );
      return;
    }

    CommonDialog.show(
      title: AppStrings.subscriptionExpired,
      description:
          'Your subscription has expired, so adding new records is disabled. '
          'You can still edit and delete existing records. Renew to add again.',
      icon: Icons.lock_outline_rounded,
      iconColor: AppColors.errorRed,
      iconBgColor: AppColors.errorBg,
      confirmText: AppStrings.renewNow,
      cancelText: AppStrings.labelNotNow,
      confirmButtonColor: AppColors.primaryBrand,
      onConfirm: () => Get.toNamed(AppRoutes.instituteSubscription),
    );
  }
}

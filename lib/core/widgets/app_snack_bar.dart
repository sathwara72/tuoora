import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/app_colors.dart';

class AppSnackBar {
  static const Duration _successDuration = Duration(milliseconds: 1500);
  static const Duration _warningDuration = Duration(milliseconds: 1500);
  static const Duration _errorDuration = Duration(milliseconds: 2000);

  static void success(String message, {String title = 'Success'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.successGreen,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: AppColors.white,
      ),
      duration: _successDuration,
    );
  }

  static void error(String message, {String title = 'Error'}) {
    if (Get.isRegistered<ApiClient>() && Get.find<ApiClient>().isLoggingOut) {
      return;
    }
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.bohoRed,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline_rounded, color: AppColors.white),
      duration: _errorDuration,
    );
  }

  static void info(String message, {String title = 'Info'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.studentProgressBlue,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.info_outline_rounded, color: AppColors.white),
      duration: _successDuration,
    );
  }

  static void warning(String message, {String title = 'Warning'}) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.warningAmber,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.warning_amber_rounded, color: AppColors.white),
      duration: _warningDuration,
    );
  }

  static SnackbarController downloading(
    String message, {
    String title = 'Downloading',
  }) {
    return Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.primaryBrand,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.download_rounded, color: AppColors.white),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: AppColors.white.withValues(alpha: 0.25),
      progressIndicatorValueColor: const AlwaysStoppedAnimation<Color>(
        AppColors.white,
      ),
      duration: const Duration(minutes: 5),
      isDismissible: false,
    );
  }
}

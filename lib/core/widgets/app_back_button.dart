import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/theme/app_spacing.dart';

/// The one back button used across the app: a 40x40 soft rounded square with
/// a left arrow. Defaults to popping the current route.
class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () => Get.back(),
      child: Container(
        width: AppSpacing.s40,
        height: AppSpacing.s40,
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: AppSpacing.s18,
          ),
        ),
      ),
    );
  }
}

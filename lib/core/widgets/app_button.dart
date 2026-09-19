import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final IconData? trailingIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final bool hasShadow;
  final bool fullWidth;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final Color? borderColor;
  final FontWeight? fontWeight;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.hasShadow = true,
    this.fullWidth = true,
    this.borderRadius = 12.0,
    this.padding,
    this.fontSize,
    this.borderColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled =
        isDisabled || isLoading || onPressed == null;
    final Color bgColor = backgroundColor ?? AppColors.primaryBrand;
    final Color contentColor = foregroundColor ?? AppColors.white;

    return GestureDetector(
      onTap: effectivelyDisabled ? null : onPressed,
      child: Container(
        width: width ?? (fullWidth ? double.infinity : null),
        constraints: const BoxConstraints(minHeight: 48),
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: AppSpacing.s18),
        decoration: BoxDecoration(
          color: effectivelyDisabled ? AppColors.textMuted : bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Center(
          child: isLoading
              ? CommonLoading(color: contentColor, size: 20)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: contentColor, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.outfit(
                        fontSize: fontSize ?? 14,
                        fontWeight: fontWeight ?? FontWeight.w800,
                        color: contentColor,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, color: contentColor, size: 20),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonDialog extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? body;
  final IconData? icon;

  /// Path to an SVG asset (e.g. [AppImages.icDelete]). Takes precedence
  /// over [icon] when supplied. Renders via [AppActionIcon] so the SVG
  /// adopts [iconColor] and the standard 32 dp dialog-icon size.
  final String? svgAsset;
  final Color iconColor;
  final Color iconBgColor;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final bool showButtons;

  /// Renders a small X button at the top-right of the dialog. Useful for
  /// info-style dialogs (e.g. View Update Details) where the confirm /
  /// cancel buttons are hidden and the X is the only dismissal cue.
  final bool showCloseIcon;

  const CommonDialog({
    super.key,
    required this.title,
    this.description,
    this.body,
    this.icon,
    this.svgAsset,
    this.iconColor = AppColors.bohoRed,
    this.iconBgColor = AppColors.errorBg,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.showButtons = true,
    this.showCloseIcon = false,
  });

  static void show({
    required String title,
    String? description,
    Widget? body,
    IconData? icon,
    String? svgAsset,
    Color iconColor = AppColors.bohoRed,
    Color iconBgColor = AppColors.errorBg,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    Color? confirmButtonColor,
    bool showButtons = true,
    bool showCloseIcon = false,
  }) {
    Get.dialog(
      CommonDialog(
        title: title,
        description: description,
        body: body,
        icon: icon,
        svgAsset: svgAsset,
        iconColor: iconColor,
        iconBgColor: iconBgColor,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmButtonColor: confirmButtonColor,
        showButtons: showButtons,
        showCloseIcon: showCloseIcon,
      ),
    );
  }

  static void showDeleteConfirmation({
    required String title,
    required String description,
    required VoidCallback onConfirm,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) {
    show(
      title: title,
      description: description,
      svgAsset: AppImages.icDelete,
      iconColor: AppColors.primaryBrand,
      iconBgColor: AppColors.primaryBrandLight,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmButtonColor: AppColors.primaryBrand,
      onConfirm: onConfirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Cap the dialog to the space actually left once the keyboard (and the
    // Dialog's own insetPadding) are accounted for, and let the content
    // scroll within that — otherwise a body with variable-height content
    // (an expandable picker, say) can overflow the Column once it grows
    // past what's available, which silently breaks the dialog rather than
    // just clipping the excess.
    final maxDialogHeight =
        media.size.height - media.viewInsets.bottom - AppSpacing.s24 * 2;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxDialogHeight.clamp(200, double.infinity),
        ),
        child: Container(
          padding: AppSpacing.all16,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: body != null
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.center,
                  children: [
                    if (icon != null || svgAsset != null) ...[
                      Center(
                        child: Container(
                          padding: AppSpacing.all16,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: svgAsset != null
                              ? AppActionIcon(
                                  asset: svgAsset!,
                                  color: iconColor,
                                  size: 32,
                                )
                              : Icon(icon, color: iconColor, size: 32),
                        ),
                      ),
                      AppSpacing.v24,
                    ],
                    Padding(
                      // Reserve right-side space so the title doesn't run
                      // underneath the X close icon when it's shown.
                      padding: showCloseIcon
                          ? const EdgeInsets.only(right: 32)
                          : EdgeInsets.zero,
                      child: Text(
                        title,
                        textAlign: body != null
                            ? TextAlign.left
                            : TextAlign.center,
                        style: AppTextStyles.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (description != null) ...[
                      AppSpacing.v12,
                      Text(
                        description!,
                        textAlign: body != null
                            ? TextAlign.left
                            : TextAlign.center,
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                    if (body != null) ...[AppSpacing.v24, body!],
                    if (showButtons) ...[
                      AppSpacing.v32,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onCancel ?? () => Get.back(),
                              style: OutlinedButton.styleFrom(
                                padding: AppSpacing.y16,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                cancelText,
                                style: AppTextStyles.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.h12,
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (body == null) Get.back();
                                onConfirm();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    confirmButtonColor ??
                                    (icon != null
                                        ? iconColor
                                        : AppColors.primaryBrand),
                                padding: AppSpacing.y16,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                confirmText,
                                style: AppTextStyles.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (showCloseIcon)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

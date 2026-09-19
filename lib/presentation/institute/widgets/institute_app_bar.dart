import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/app_back_button.dart';

class InstituteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool isRoot;
  final bool hideLeading;
  final bool showDefaultActions;
  final VoidCallback? onBackTap;
  final VoidCallback? onMenuTap;
  final List<Widget>? actions;

  const InstituteAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.isRoot = false,
    this.hideLeading = false,
    this.showDefaultActions = true,
    this.onBackTap,
    this.onMenuTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.x16.add(
        const EdgeInsets.only(top: AppSpacing.s16, bottom: AppSpacing.s8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (!hideLeading) _buildLeadingButton(context),
                if (!hideLeading) AppSpacing.h16,
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (actions != null) Row(children: actions!),
          if (isRoot && actions == null && showDefaultActions)
            _buildDefaultRootActions(),
        ],
      ),
    );
  }

  Widget _buildLeadingButton(BuildContext context) {
    if (!isRoot) return AppBackButton(onTap: onBackTap);
    return GestureDetector(
      onTap: isRoot
          ? (onMenuTap ?? () => Scaffold.of(context).openDrawer())
          : (onBackTap ?? () => Get.back()),
      child: Container(
        width: AppSpacing.s40,
        height: AppSpacing.s40,
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Center(
          child: Icon(
            isRoot ? Icons.menu_rounded : Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: isRoot ? AppSpacing.s22 : AppSpacing.s18,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultRootActions() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.instituteChats),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.fieldLabel,
            size: AppSpacing.s24,
          ),
        ),
        AppSpacing.h16,
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.instituteNotifications),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.fieldLabel,
            size: AppSpacing.s26,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

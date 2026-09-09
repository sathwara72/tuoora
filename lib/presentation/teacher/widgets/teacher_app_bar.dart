import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';

class TeacherAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool isRoot;
  final bool hideLeading;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;

  const TeacherAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.isRoot = false,
    this.hideLeading = false,
    this.onBackTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.x16.add(
        const EdgeInsets.only(top: AppSpacing.s16, bottom: AppSpacing.s10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (!hideLeading && !isRoot) _buildLeadingButton(),
                if (!hideLeading && !isRoot) AppSpacing.h16,
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
        ],
      ),
    );
  }

  Widget _buildLeadingButton() {
    return GestureDetector(
      onTap: onBackTap ?? () => Get.back(),
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

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

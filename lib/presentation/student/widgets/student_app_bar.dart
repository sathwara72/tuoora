import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/student/controllers/student_notifications_controller.dart';

class StudentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? leading;
  final bool isRoot;
  final bool hideLeading;
  final bool showDefaultActions;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;

  const StudentAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.leading,
    this.isRoot = false,
    this.hideLeading = false,
    this.showDefaultActions = true,
    this.onBackTap,
    this.actions,
  }) : assert(
         title != null || titleWidget != null,
         'StudentAppBar needs either `title` or `titleWidget`',
       );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s16,
        AppSpacing.s8,
      ),
      child: Row(
        children: [
          ..._buildLeading(),
          Expanded(child: _buildTitle()),
          if (actions != null)
            ...actions!
          else if (showDefaultActions)
            ..._buildDefaultActions(),
        ],
      ),
    );
  }

  List<Widget> _buildLeading() {
    if (leading != null) return [leading!, AppSpacing.h12];
    if (isRoot || hideLeading) return const [];
    return [
      StudentHeaderIconButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: onBackTap ?? () => Get.back(),
      ),
      AppSpacing.h12,
    ];
  }

  Widget _buildTitle() {
    if (titleWidget != null) return titleWidget!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.outfit(
            fontSize: 22,
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
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  List<Widget> _buildDefaultActions() {
    return [
      StudentHeaderIconButton(
        icon: Icons.chat_bubble_outline_rounded,
        onTap: () => Get.toNamed(AppRoutes.studentChat),
      ),
      AppSpacing.h8,
      const _NotificationBellButton(),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        StudentHeaderIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => Get.toNamed(AppRoutes.studentNotifications),
        ),
        if (Get.isRegistered<StudentNotificationsController>())
          Positioned(
            top: 6,
            right: 6,
            child: Obx(() {
              final hasUnread =
                  Get.find<StudentNotificationsController>().hasUnread;
              if (!hasUnread) return const SizedBox.shrink();
              return Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.instBrandOrange,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
              );
            }),
          ),
      ],
    );
  }
}

class StudentHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const StudentHeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSpacing.s40,
        height: AppSpacing.s40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

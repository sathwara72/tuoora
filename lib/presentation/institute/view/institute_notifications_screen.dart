import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/data/models/notification_model.dart';
import 'package:tuoora/presentation/institute/controllers/notification_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InstituteNotificationsScreen extends GetView<NotificationController> {
  const InstituteNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InstituteAppBar(title: AppStrings.notification, isRoot: false),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.notifications.isEmpty) {
                  return const CommonLoading();
                }

                if (controller.errorMessage.isNotEmpty &&
                    controller.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${controller.errorMessage.value}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.outfit(
                            color: AppColors.errorRed,
                          ),
                        ),
                        AppSpacing.v16,
                        ElevatedButton(
                          onPressed: () => controller.fetchNotifications(),
                          child: const Text(AppStrings.labelRetry),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.notifications.isEmpty) {
                  return const AppEmptyView(
                    icon: Icons.notifications_none_rounded,
                    title: AppStrings.noNotificationsYet,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refreshNotifications(),
                  color: AppColors.primaryBrand,
                  child: ListView.separated(
                    padding: AppSpacing.x16.add(AppSpacing.y16),
                    itemCount: controller.notifications.length,
                    separatorBuilder: (context, index) => AppSpacing.v10,
                    itemBuilder: (context, index) {
                      final notification = controller.notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkSlate,
                          height: 1.2,
                        ),
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      _getRelativeTime(notification.createdAt),
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppSpacing.v4,
                Text(
                  notification.message,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (notification.image != null) ...[
                  AppSpacing.v16,
                  AppNetworkImage(
                    url: notification.image ?? "",
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    errorWidget: const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}

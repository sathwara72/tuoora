import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/date_format_utils.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_notifications_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_notification_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

/// Staff notices, salary slips and the daily teaching schedule.
class TeacherNotificationsScreen
    extends GetView<TeacherNotificationsController> {
  const TeacherNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(
              title: 'Notifications',
              actions: [
                Obx(
                  () => controller.unreadCount.value > 0
                      ? TextButton(
                          onPressed: controller.markAllRead,
                          child: Text(
                            'Mark all read',
                            style: AppTextStyles.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBrand,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: controller.fetch,
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.notifications.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBrand,
                      ),
                    );
                  }
                  final items = controller.notifications;
                  if (items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: AppEmptyView(
                            icon: controller.error.value != null
                                ? Icons.cloud_off_rounded
                                : Icons.notifications_none_rounded,
                            title: controller.error.value != null
                                ? 'Could not load'
                                : 'No notifications yet',
                            message:
                                controller.error.value ??
                                'Staff notices, salary slips and your daily schedule appear here.',
                          ),
                        ),
                      ],
                    );
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                        controller.loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSpacing.x16.add(AppSpacing.y8),
                      itemCount: items.length + 1,
                      separatorBuilder: (_, _) => AppSpacing.v10,
                      itemBuilder: (_, i) {
                        if (i == items.length) {
                          return controller.isLoadingMore.value
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 16);
                        }
                        return _buildTile(items[i]);
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ({IconData icon, Color color}) _visualFor(TeacherNotification n) {
    if (n.isSalarySlip) {
      return (icon: Icons.receipt_long_rounded, color: AppColors.greenText);
    }
    if (n.isSchedule) {
      return (
        icon: Icons.calendar_month_rounded,
        color: const Color(0xFF2563EB),
      );
    }
    return (icon: Icons.campaign_rounded, color: AppColors.primaryBrand);
  }

  Widget _buildTile(TeacherNotification n) {
    final v = _visualFor(n);
    final tappable = n.isSalarySlip || n.isSchedule;
    return Material(
      color: n.isRead
          ? AppColors.white
          : AppColors.primaryBrandLight.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: () => controller.open(n),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: AppSpacing.all8,
                decoration: BoxDecoration(
                  color: v.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(v.icon, size: 20, color: v.color),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: AppTextStyles.outfit(
                              fontSize: 14,
                              fontWeight: n.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBrand,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (n.message.isNotEmpty) ...[
                      AppSpacing.v4,
                      Text(
                        n.message,
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                    AppSpacing.v8,
                    Row(
                      children: [
                        Text(
                          DateFormatUtils.relativeTime(n.createdAt),
                          style: AppTextStyles.outfit(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                        if (tappable)
                          Text(
                            n.isSalarySlip ? 'View salary' : 'View schedule',
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBrand,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

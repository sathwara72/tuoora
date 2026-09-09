import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/student/controllers/student_notifications_controller.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class StudentNotificationScreen extends StatefulWidget {
  const StudentNotificationScreen({super.key});

  @override
  State<StudentNotificationScreen> createState() =>
      _StudentNotificationScreenState();
}

class _StudentNotificationScreenState
    extends State<StudentNotificationScreen> {
  late final StudentNotificationsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StudentNotificationsController>();
    // Refresh then clear the unread dot — a fresh load avoids marking
    // items read before we actually know about the latest ones.
    controller.load(isBackground: true).then((_) => controller.markAllAsRead());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: AppStrings.labelNotifications,
              showDefaultActions: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.items.isEmpty) {
                  return const CommonLoading(color: AppColors.primaryBrand);
                }
                final displays = controller.displays;
                if (displays.isEmpty) {
                  return _EmptyState(onRefresh: controller.load);
                }
                return RefreshIndicator(
                  color: AppColors.primaryBrand,
                  onRefresh: controller.load,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.screenPadding,
                    itemCount: displays.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.s10),
                    itemBuilder: (context, index) {
                      final d = displays[index];
                      return _NotificationCard(
                        display: d,
                        onTap: () => controller.openNotification(d.raw),
                      );
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
}

class _NotificationCard extends StatelessWidget {
  final StudentNotificationDisplay display;
  final VoidCallback onTap;

  const _NotificationCard({required this.display, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      display.title,
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (display.showChevron) ...[
                    AppSpacing.h4,
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                display.message,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              if (display.timeAgo.isNotEmpty)
                Text(
                  display.timeAgo,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrand,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    // Wrap AppEmptyView in a scrollable so RefreshIndicator still works when
    // the list is empty (otherwise pull-to-refresh has no scrollable child).
    return RefreshIndicator(
      color: AppColors.primaryBrand,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          AppEmptyView(
            icon: Icons.notifications_none_rounded,
            title: AppStrings.youReAllCaughtUp,
            message: 'New notifications will show up here.',
          ),
        ],
      ),
    );
  }
}

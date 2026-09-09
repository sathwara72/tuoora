import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_self_attendance_controller.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherSelfAttendanceScreen extends GetView<TeacherSelfAttendanceController> {
  const TeacherSelfAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const TeacherAppBar(title: 'My Attendance'),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                final today = controller.today.value;
                final history = controller.history.value;
                return RefreshIndicator(
                  onRefresh: controller.fetchAll,
                  child: ListView(
                    padding: AppSpacing.x16,
                    children: [
                      Container(
                        padding: AppSpacing.cardPadding,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Status",
                              style: AppTextStyles.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            AppSpacing.v8,
                            Text(
                              today?.status ?? 'Not marked yet',
                              style: AppTextStyles.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: today != null
                                    ? AppColors.primaryBrand
                                    : AppColors.textSecondary,
                              ),
                            ),
                            AppSpacing.v16,
                            Wrap(
                              spacing: AppSpacing.s8,
                              runSpacing: AppSpacing.s8,
                              children: TeacherSelfAttendanceController.statuses
                                  .map(
                                    (status) => GestureDetector(
                                      onTap: controller.isMarking.value
                                          ? null
                                          : () => controller.markToday(status),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: today?.status == status
                                              ? AppColors.primaryBrand
                                              : AppColors.fieldBg,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: today?.status == status
                                                ? AppColors.primaryBrand
                                                : AppColors.fieldBorder,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: AppTextStyles.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: today?.status == status
                                                ? AppColors.white
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.v16,
                      if (history != null)
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                'Present',
                                history.totalPresent,
                                AppColors.primaryBrand,
                              ),
                            ),
                            AppSpacing.h12,
                            Expanded(
                              child: _summaryCard(
                                'Absent',
                                history.totalAbsent,
                                AppColors.bohoRed,
                              ),
                            ),
                          ],
                        ),
                      AppSpacing.v16,
                      Text(
                        'History',
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      AppSpacing.v12,
                      ...?history?.items.map(
                        (item) => Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.s8),
                          padding: AppSpacing.all16,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            border: Border.all(color: AppColors.borderGrey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.date,
                                style: AppTextStyles.outfit(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                item.status,
                                style: AppTextStyles.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBrand,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: AppTextStyles.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_details_controller.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherBatchDetailsScreen extends GetView<TeacherBatchDetailsController> {
  const TeacherBatchDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => TeacherAppBar(title: controller.batch.name)),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.detail.value == null) {
                  return const Center(child: CommonLoading());
                }
                final batch = controller.batch;
                final studentsCount =
                    controller.detail.value?.students.length ?? batch.studentsCount ?? 0;
                return RefreshIndicator(
                  onRefresh: controller.fetchDetail,
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
                            if (batch.subject != null && batch.subject!.isNotEmpty)
                              Text(
                                batch.subject!,
                                style: AppTextStyles.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBrand,
                                ),
                              ),
                            AppSpacing.v4,
                            Text(
                              '$studentsCount students'
                              '${batch.classroom != null ? ' · Room ${batch.classroom}' : ''}',
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.v24,
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.s12,
                        crossAxisSpacing: AppSpacing.s12,
                        childAspectRatio: 1.3,
                        children: [
                          _FeatureTile(
                            icon: Icons.checklist_rounded,
                            label: 'Attendance',
                            onTap: () => Get.toNamed(
                              AppRoutes.teacherMarkAttendance,
                              arguments: batch,
                            ),
                          ),
                          _FeatureTile(
                            icon: Icons.assignment_rounded,
                            label: 'Homework',
                            onTap: () => Get.toNamed(
                              AppRoutes.teacherBatchHomework,
                              arguments: batch,
                            ),
                          ),
                          _FeatureTile(
                            icon: Icons.quiz_rounded,
                            label: 'Exams',
                            onTap: () => Get.toNamed(
                              AppRoutes.teacherBatchExams,
                              arguments: batch,
                            ),
                          ),
                          _FeatureTile(
                            icon: Icons.schedule_rounded,
                            label: 'Timetable',
                            onTap: () => Get.toNamed(
                              AppRoutes.teacherBatchTimetable,
                              arguments: batch,
                            ),
                          ),
                          if (batch.teacherCanViewFees)
                            _FeatureTile(
                              icon: Icons.currency_rupee_rounded,
                              label: 'Fees',
                              onTap: () => Get.toNamed(
                                AppRoutes.teacherFees,
                                arguments: batch,
                              ),
                            ),
                        ],
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
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.s48,
              height: AppSpacing.s48,
              decoration: BoxDecoration(
                color: AppColors.primaryBrand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryBrand, size: 24),
            ),
            AppSpacing.v8,
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

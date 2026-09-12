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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (batch.subject != null && batch.subject!.isNotEmpty) ...[
                              Text(
                                batch.subject!,
                                style: AppTextStyles.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBrand,
                                ),
                              ),
                              AppSpacing.v4,
                            ],
                            Text(
                              '$studentsCount students'
                              '${batch.classroom != null ? ' · Room ${batch.classroom}' : ''}',
                              style: AppTextStyles.outfit(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.v16,
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.s12,
                        crossAxisSpacing: AppSpacing.s12,
                        childAspectRatio: 1.35,
                        children: [
                          _FeatureTile(
                            icon: Icons.groups_outlined,
                            label: 'Students',
                            subtitle: 'MANAGE ENROLLMENTS',
                            accent: const Color(0xFFF97316),
                            bgColor: const Color(0xFFFFF7ED),
                            onTap: () async {
                              await Get.toNamed(
                                AppRoutes.teacherBatchStudents,
                                arguments: batch,
                              );
                              controller.fetchDetail();
                            },
                          ),
                          _FeatureTile(
                            icon: Icons.account_circle_outlined,
                            label: 'Attendance',
                            subtitle: 'TRACK STUDENT PRESENCE',
                            accent: const Color(0xFFB45309),
                            bgColor: const Color(0xFFFFFBEB),
                            onTap: () => Get.toNamed(
                              AppRoutes.teacherMarkAttendance,
                              arguments: batch,
                            ),
                          ),
                          _FeatureTile(
                            icon: Icons.menu_book_outlined,
                            label: 'Homework',
                            subtitle: 'MANAGE ASSIGNMENTS',
                            accent: const Color(0xFF0D9488),
                            bgColor: const Color(0xFFF0FDF4),
                            onTap: () => Get.toNamed(
                              AppRoutes.teacherBatchHomework,
                              arguments: batch,
                            ),
                          ),
                          _FeatureTile(
                            icon: Icons.assignment_turned_in_outlined,
                            label: 'Exams',
                            subtitle: 'TESTS & MARKS ENTRY',
                            accent: const Color(0xFF6366F1),
                            bgColor: const Color(0xFFEEF2FF),
                            onTap: () => Get.toNamed(
                              AppRoutes.teacherBatchExams,
                              arguments: batch,
                            ),
                          ),
                          _FeatureTile(
                            icon: Icons.calendar_today_outlined,
                            label: 'TimeTable',
                            subtitle: 'SCHEDULE & LECTURES',
                            accent: const Color(0xFF2563EB),
                            bgColor: const Color(0xFFEFF6FF),
                            onTap: () => Get.toNamed(
                              AppRoutes.teacherBatchTimetable,
                              arguments: batch,
                            ),
                          ),
                          _FeatureTile(
                            icon: Icons.folder_outlined,
                            label: 'Materials',
                            subtitle: 'MATERIALS AND DOCUMENTS',
                            accent: const Color(0xFF10B981),
                            bgColor: const Color(0xFFECFDF5),
                            onTap: () => Get.toNamed(
                              AppRoutes.teacherBatchResources,
                              arguments: batch,
                            ),
                          ),
                          if (batch.teacherCanViewFees)
                            _FeatureTile(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Fees',
                              subtitle: 'FEES & COLLECTIONS',
                              accent: const Color(0xFF059669),
                              bgColor: const Color(0xFFECFDF5),
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
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;
  final Color bgColor;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.accent,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 20,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.outfit(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

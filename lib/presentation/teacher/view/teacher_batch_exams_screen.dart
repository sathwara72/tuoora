import 'package:flutter/material.dart';
import 'package:tuoora/core/utils/pull_refresh.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_exams_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_exam_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherBatchExamsScreen extends GetView<TeacherBatchExamsController> {
  const TeacherBatchExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(
              title: 'Exams · ${controller.batch.name}',
              actions: [
                GestureDetector(
                  onTap: controller.addExam,
                  child: Container(
                    width: AppSpacing.s40,
                    height: AppSpacing.s40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: AppSearchField(
                hintText: 'Search exams or subjects...',
                onChanged: (v) => controller.searchQuery.value = v,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Obx(
                () => Row(
                  children: [
                    _chip('All Exams', 'all'),
                    AppSpacing.h8,
                    _chip('Scheduled', 'scheduled'),
                    AppSpacing.h8,
                    _chip('Completed', 'completed'),
                    const Spacer(),
                    Text(
                      '${controller.total.value} total',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && !PullRefresh.active.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.exams.isEmpty) {
                  return Center(
                    child: Text(
                      'No exams found.',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                final count = controller.exams.length;
                return RefreshIndicator(
                  onRefresh: () => PullRefresh.run(controller.fetchExams),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: count + (controller.hasMore ? 1 : 0),
                    separatorBuilder: (_, _) => AppSpacing.v12,
                    itemBuilder: (context, index) {
                      if (index == count) {
                        return Center(
                          child: TextButton(
                            onPressed: controller.isLoadingMore.value
                                ? null
                                : controller.loadMore,
                            child: controller.isLoadingMore.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Load more'),
                          ),
                        );
                      }
                      final exam = controller.exams[index];
                      return _ExamCard(
                        exam: exam,
                        onEdit: () => controller.editExam(exam),
                        onDelete: () => controller.confirmDeleteExam(exam),
                        onMarks: () => controller.openMarks(exam),
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

  Widget _chip(String label, String key) {
    final selected = controller.filter.value == key;
    return GestureDetector(
      onTap: () => controller.setFilter(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBrand : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primaryBrand : AppColors.fieldBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final TeacherExam exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarks;

  const _ExamCard({
    required this.exam,
    required this.onEdit,
    required this.onDelete,
    required this.onMarks,
  });

  ({String label, Color color}) get _badge {
    final s = exam.status.toLowerCase();
    if (s == 'completed')
      return (label: 'Completed', color: AppColors.successGreen);
    if (s == 'cancelled')
      return (label: 'Cancelled', color: AppColors.textTertiary);
    if (exam.isToday) return (label: 'Today', color: Colors.amber.shade800);
    if (exam.isPendingMarks)
      return (label: 'Pending Marks', color: AppColors.primaryBrand);
    return (label: 'Scheduled', color: const Color(0xFF2563EB));
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badge;
    final stats = exam.stats;
    final entered = stats?.marksEnteredCount ?? 0;
    final locked = exam.isFutureScheduled && entered == 0;
    final time = exam.timeRangeText;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exam.title,
                  style: AppTextStyles.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge.label,
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badge.color,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v4,
          Text(
            [
              exam.formattedDate ?? exam.examDate,
              ?time,
              if (exam.subject != null && exam.subject!.isNotEmpty)
                exam.subject!,
            ].join(' · '),
            style: AppTextStyles.outfit(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            '${exam.totalMarks.toStringAsFixed(0)} marks (Pass: ${exam.passingMarks.toStringAsFixed(0)})',
            style: AppTextStyles.outfit(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          if (stats != null) ...[
            AppSpacing.v12,
            Row(
              children: [
                _stat(
                  'Entered',
                  '${stats.marksEnteredCount}/${stats.totalStudents}',
                  AppColors.textPrimary,
                ),
                AppSpacing.h8,
                _stat('Passed', '${stats.passedCount}', AppColors.successGreen),
                AppSpacing.h8,
                _stat(
                  'Avg',
                  stats.averageMarks.toStringAsFixed(1),
                  const Color(0xFF4F46E5),
                ),
              ],
            ),
          ],
          AppSpacing.v12,
          Row(
            children: [
              Expanded(
                child: locked
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.fieldBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.fieldBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 15,
                              color: AppColors.textTertiary,
                            ),
                            AppSpacing.h6,
                            Text(
                              exam.opensOnText,
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: onMarks,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBrand.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.edit_note_rounded,
                                size: 16,
                                color: AppColors.primaryBrand,
                              ),
                              AppSpacing.h4,
                              Text(
                                entered > 0
                                    ? 'View / Edit Marks'
                                    : 'Enter Marks',
                                style: AppTextStyles.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBrand,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              AppSpacing.h8,
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.fieldBorder),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AppSpacing.h8,
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.bohoRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.bohoRed.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: AppColors.bohoRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: AppTextStyles.outfit(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

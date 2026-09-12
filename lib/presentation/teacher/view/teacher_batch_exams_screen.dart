import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
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
                    child: const Icon(Icons.add_rounded, color: AppColors.white),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.exams.isEmpty) {
                  return Center(
                    child: Text(
                      'No exams scheduled yet.',
                      style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchExams,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: controller.exams.length,
                    separatorBuilder: (_, _) => AppSpacing.v12,
                    itemBuilder: (context, index) {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = exam.status == 'completed'
        ? AppColors.primaryBrand
        : exam.status == 'cancelled'
            ? AppColors.bohoRed
            : Colors.amber.shade700;
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
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  exam.status,
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v4,
          Text(
            '${exam.formattedDate ?? exam.examDate}'
            '${exam.subject != null && exam.subject!.isNotEmpty ? ' · ${exam.subject}' : ''}'
            ' · ${exam.totalMarks.toStringAsFixed(0)} marks',
            style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
          ),
          AppSpacing.v12,
          Row(
            children: [
              Expanded(
                child: exam.isScheduled
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
                            color: AppColors.primaryBrand.withValues(alpha: 0.1),
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
                                'Enter Marks',
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
}

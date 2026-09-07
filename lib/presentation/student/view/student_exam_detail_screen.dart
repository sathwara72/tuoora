import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/student/controllers/student_exams_controller.dart';
import 'package:tuoora/presentation/student/models/student_exam_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class StudentExamDetailScreen extends GetView<StudentExamsController> {
  const StudentExamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: 'Exam Details',
              showDefaultActions: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isDetailLoading.value ||
                    controller.selectedExam.value == null) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBrand,
                    ),
                  );
                }

                final exam = controller.selectedExam.value!;
                return SingleChildScrollView(
                  padding: AppSpacing.x16.add(AppSpacing.y16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(exam),
                      AppSpacing.v24,
                      if (exam.isCompleted) _buildResultCard(exam),
                      if (exam.isCompleted) AppSpacing.v24,
                      if (exam.isCompleted) _buildClassStatsCard(exam),
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

  Widget _buildHeader(StudentExamDetail exam) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (exam.subject ?? exam.examTypeLabel).toUpperCase(),
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBrandLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                exam.examTypeLabel.toUpperCase(),
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.v8,
        Text(
          exam.title,
          style: AppTextStyles.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.v8,
        Text(
          '${exam.formattedDate ?? ''} · Total ${exam.totalMarks.toStringAsFixed(0)} · Pass ${exam.passingMarks.toStringAsFixed(0)}',
          style: AppTextStyles.outfit(
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
        ),
        if (!exam.isCompleted) ...[
          AppSpacing.v24,
          Container(
            padding: AppSpacing.all20,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.hourglass_empty_rounded,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.h12,
                Expanded(
                  child: Text(
                    'Results will appear here once the exam is graded.',
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultCard(StudentExamDetail exam) {
    final result = exam.result;
    if (!result.hasResult) {
      return Container(
        padding: AppSpacing.all20,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Text(
          'Marks have not been entered for this exam yet.',
          style: AppTextStyles.outfit(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    if (result.isAbsent) {
      return Container(
        padding: AppSpacing.all20,
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_busy_rounded, color: AppColors.error),
            AppSpacing.h12,
            Text(
              'Marked absent for this exam',
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    final isPass = result.isPass ?? false;
    return Container(
      padding: AppSpacing.all20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPass
              ? [AppColors.successGreen, AppColors.primaryBrand]
              : [AppColors.error, AppColors.bohoRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPass ? 'PASSED' : 'FAILED',
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
              letterSpacing: 1,
            ),
          ),
          AppSpacing.v12,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                result.marksObtained!.toStringAsFixed(0),
                style: AppTextStyles.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  '/ ${exam.totalMarks.toStringAsFixed(0)}',
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
              const Spacer(),
              if (result.grade != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    result.grade!,
                    style: AppTextStyles.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
          if (result.percentage != null) ...[
            AppSpacing.v8,
            Text(
              '${result.percentage!.toStringAsFixed(1)}%',
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
          if (result.remarks != null && result.remarks!.trim().isNotEmpty) ...[
            AppSpacing.v16,
            Divider(color: AppColors.white.withValues(alpha: 0.3), height: 1),
            AppSpacing.v12,
            Text(
              result.remarks!,
              style: AppTextStyles.outfit(fontSize: 13, color: AppColors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClassStatsCard(StudentExamDetail exam) {
    final stats = exam.classStats;
    return Container(
      padding: AppSpacing.all20,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successBg),
      ),
      child: Row(
        children: [
          _statTile(
            stats.highestMarks?.toStringAsFixed(0) ?? '—',
            'Highest',
          ),
          _statTile(stats.averageMarks.toStringAsFixed(1), 'Class Average'),
          _statTile('${stats.passPercentage.toStringAsFixed(0)}%', 'Pass %'),
        ],
      ),
    );
  }

  Widget _statTile(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.v4,
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

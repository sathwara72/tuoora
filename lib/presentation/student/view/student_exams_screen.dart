import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/presentation/student/controllers/student_exams_controller.dart';
import 'package:tuoora/presentation/student/models/student_exam_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class StudentExamsScreen extends GetView<StudentExamsController> {
  const StudentExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: AppStrings.labelExams,
              showDefaultActions: false,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: controller.loadExams,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBrand,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.x16.add(AppSpacing.y16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (controller.overallStats.value != null) ...[
                          _buildStatsCard(controller.overallStats.value!),
                          AppSpacing.v24,
                        ],
                        _buildTabPills(),
                        AppSpacing.v20,
                        if (controller.activeItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: AppEmptyView(
                              icon: Icons.fact_check_outlined,
                              title: 'No exams here yet',
                            ),
                          )
                        else
                          Column(
                            children: controller.activeItems
                                .map((exam) => _buildExamCard(exam))
                                .toList(),
                          ),
                      ],
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

  Widget _buildStatsCard(StudentExamOverallStats stats) {
    return Container(
      padding: AppSpacing.all20,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.successBg),
      ),
      child: Row(
        children: [
          _statTile('${stats.totalExams}', 'Total'),
          _statTile('${stats.attendedExams}', 'Attended'),
          _statTile('${stats.passedExams}', 'Passed'),
          _statTile('${stats.averagePercentage.toStringAsFixed(0)}%', 'Average'),
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

  Widget _buildTabPills() {
    return Obx(
      () => Container(
        padding: AppSpacing.all6,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.s20),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabPill('Upcoming', 0)),
            Expanded(child: _buildTabPill('Results', 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    final isSelected = controller.activeTab.value == index;
    return GestureDetector(
      onTap: () => controller.selectTab(index),
      child: Container(
        padding: AppSpacing.y12,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.textPrimary : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard(StudentExamListItem exam) {
    return GestureDetector(
      onTap: () => controller.openExam(exam),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: AppSpacing.all16,
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
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBrandLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                color: AppColors.primaryBrand,
              ),
            ),
            AppSpacing.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: AppTextStyles.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.v4,
                  Text(
                    '${exam.examTypeLabel} · ${exam.formattedDate ?? ''}',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            _resultBadge(exam),
          ],
        ),
      ),
    );
  }

  Widget _resultBadge(StudentExamListItem exam) {
    if (exam.isScheduled) {
      return const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      );
    }
    if (exam.isAbsent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'ABSENT',
          style: AppTextStyles.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
      );
    }
    if (exam.marksObtained == null) {
      return const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textMuted,
      );
    }
    final isPass = exam.isPass ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isPass ? AppColors.successBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${exam.marksObtained!.toStringAsFixed(0)}/${exam.totalMarks.toStringAsFixed(0)}',
        style: AppTextStyles.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isPass ? AppColors.greenText : AppColors.error,
        ),
      ),
    );
  }
}

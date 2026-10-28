import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/subject_performance_view.dart';
import 'package:tuoora/data/models/subject_performance_model.dart';
import 'package:tuoora/presentation/student/controllers/student_subject_performance_controller.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

/// Weak, average and strong subjects with average %, trend, latest score
/// and absences.
class StudentSubjectPerformanceScreen
    extends GetView<StudentSubjectPerformanceController> {
  const StudentSubjectPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: 'Subject Performance',
              showDefaultActions: false,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: controller.load,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBrand,
                      ),
                    );
                  }
                  final data = controller.performance.value;
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.x16.add(AppSpacing.y16),
                    children: [
                      if (controller.error.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: AppEmptyView(
                            icon: Icons.cloud_off_rounded,
                            title: 'Could not load',
                            message: controller.error.value,
                          ),
                        )
                      else if (data.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: AppEmptyView(
                            icon: Icons.insights_outlined,
                            title: 'No results yet',
                            message:
                                'Your subject performance appears after your first exam results.',
                          ),
                        )
                      else ...[
                        _buildSummary(data),
                        AppSpacing.v16,
                        SubjectPerformanceView(performance: data),
                      ],
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(SubjectPerformance data) {
    int count(String level) =>
        data.subjects.where((s) => s.level == level).length;
    return Row(
      children: [
        _summaryTile(
          'Weak',
          count('weak'),
          AppColors.bohoRed,
          AppColors.errorBg,
        ),
        AppSpacing.h8,
        _summaryTile(
          'Average',
          count('average'),
          AppColors.warningAmber,
          AppColors.warningBg,
        ),
        AppSpacing.h8,
        _summaryTile(
          'Strong',
          count('strong'),
          AppColors.greenText,
          AppColors.successBg,
        ),
      ],
    );
  }

  Widget _summaryTile(String label, int value, Color fg, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: AppTextStyles.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

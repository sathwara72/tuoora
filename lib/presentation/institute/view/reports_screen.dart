import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/reports_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAllReports();
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: AppStrings.labelReports, isRoot: false),
            Expanded(
              child: ListView(
                padding: AppSpacing.all16,
                children: [
                  _buildReportCard(
                    title: AppStrings.attendanceReports,
                    subtitle:
                        AppStrings.comprehensiveAnalysisOfDailyWeeklyAnd,
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.primaryBrand,
                    onTap: () {
                      Get.toNamed(AppRoutes.instituteAttendanceReport);
                    },
                  ),
                  AppSpacing.v10,
                  _buildReportCard(
                    title: AppStrings.labelFeeCollectionReport,
                    subtitle:
                        AppStrings.deepDiveIntoExaminationResultsAssignment,
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.primaryBrand,
                    onTap: () {
                      Get.toNamed(AppRoutes.instituteFeeReport);
                    },
                  ),
                  AppSpacing.v10,
                  _buildReportCard(
                    title: AppStrings.studentPerformanceReports,
                    subtitle:
                        AppStrings.academicProgressAverageGradesAndPerformance,
                    icon: Icons.insights_rounded,
                    color: AppColors.primaryBrand,
                    onTap: () {
                      Get.toNamed(AppRoutes.institutePerformanceReport);
                    },
                  ),
                  AppSpacing.v10,
                  _buildReportCard(
                    title: AppStrings.labelBusinessAnalytics,
                    subtitle: AppStrings.revenueFeeCollectionAndDropoutTrends,
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.primaryBrand,
                    onTap: () {
                      Get.toNamed(AppRoutes.instituteAnalytics);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.all16,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            AppSpacing.h20,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.v4,
                  Text(
                    subtitle,
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.h12,
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

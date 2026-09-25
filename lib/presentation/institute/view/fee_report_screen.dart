import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/reports_controller.dart';
import 'package:tuoora/presentation/institute/models/report_models.dart';
import 'package:tuoora/presentation/institute/widgets/export_report.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/presentation/institute/widgets/report_widgets.dart';

class FeeReportScreen extends StatefulWidget {
  const FeeReportScreen({super.key});

  @override
  State<FeeReportScreen> createState() => _FeeReportScreenState();
}

class _FeeReportScreenState extends State<FeeReportScreen> {
  int _selectedView = 0; // 0: Student Log, 1: Batch Summaries

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportsController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(
              title: AppStrings.labelFeeCollectionReport,
              isRoot: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isFeeLoading.value) {
                  return const CommonLoading();
                }

                final report = controller.feeReport.value;
                if (report == null) {
                  return const AppEmptyView(
                    icon: Icons.account_balance_wallet_outlined,
                    title: AppStrings.noReportDataAvailable,
                  );
                }

                return SingleChildScrollView(
                  padding: AppSpacing.all16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReportSummaryCard(
                        title: AppStrings.totalCollectionAcrossBatches,
                        value:
                            '₹',
                      ),
                      AppSpacing.v20,
                      _buildViewToggle(report),
                      AppSpacing.v20,
                      _buildSectionHeader(
                        _selectedView == 0
                            ? 'Student Collection Log'
                            : 'Batch Summaries',
                        controller,
                      ),
                      AppSpacing.v16,
                      if (_selectedView == 0)
                        _buildStudentLog(report.students)
                      else
                        _buildBatchSummaries(report.batches),
                      AppSpacing.v32,
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

  Widget _buildViewToggle(FeeReportResponse report) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.background),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedView = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedView == 0
                      ? AppColors.primaryBrand
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Student Log ()',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _selectedView == 0
                        ? AppColors.white
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedView = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedView == 1
                      ? AppColors.primaryBrand
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Batch Summary ()',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _selectedView == 1
                        ? AppColors.white
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentLog(List<FeeReportStudent> students) {
    if (students.isEmpty) {
      return const AppEmptyView(
        icon: Icons.people_outline,
        title: 'No student fee records found',
      );
    }

    return Column(
      children: students.map((stu) {
        final isDue = stu.dueAmount > 0;
        final statusColor = switch (stu.status.toLowerCase()) {
          'paid' => AppColors.success,
          'partial' => Colors.amber.shade700,
          'no fee' => AppColors.textTertiary,
          _ => AppColors.error,
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s12),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                color: isDue
                    ? AppColors.error.withValues(alpha: 0.25)
                    : AppColors.background,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stu.name,
                            style: AppTextStyles.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ' • ',
                            style: AppTextStyles.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        stu.status.toUpperCase(),
                        style: AppTextStyles.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.v12,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAmtCol('Total', '₹', AppColors.textPrimary),
                      _buildAmtCol('Paid', '₹', AppColors.success),
                      _buildAmtCol(
                        'Due',
                        '₹',
                        isDue ? AppColors.error : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
                if (stu.lastPaymentDate.isNotEmpty && stu.lastPaymentDate != 'N/A') ...[
                  const SizedBox(height: 6),
                  Text(
                    'Last payment: ',
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmtCol(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBatchSummaries(List<FeeReportBatch> batches) {
    return Column(
      children: batches.map(
        (batch) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s12),
          child: ReportBatchItemCard(
            name: batch.batchName,
            strength: batch.studentsCount,
            metricLabel: 'Total Collected',
            metricValue: '₹',
            progress: batch.batchFees > 0
                ? batch.totalCollected / batch.batchFees
                : 0.0,
            onTap: () {
              Get.toNamed(
                AppRoutes.instituteBatchReportDetail,
                arguments: {
                  'batchId': batch.batchId,
                  'batchName': batch.batchName,
                  'reportType': 'Fee',
                },
              );
            },
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildSectionHeader(String title, ReportsController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AppSpacing.h16,
        ExportReport(onTap: () => controller.exportReport('Fee')),
      ],
    );
  }
}

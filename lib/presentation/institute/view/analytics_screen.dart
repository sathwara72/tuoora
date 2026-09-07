import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/presentation/institute/controllers/reports_controller.dart';
import 'package:tuoora/presentation/institute/models/report_models.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/report_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAnalytics();
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(
              title: 'Business Analytics',
              isRoot: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isAnalyticsLoading.value &&
                    controller.analytics.value == null) {
                  return const CommonLoading();
                }

                final data = controller.analytics.value;
                if (data == null) {
                  return const AppEmptyView(
                    icon: Icons.insights_rounded,
                    title: AppStrings.noReportDataAvailable,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.loadAnalytics(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.all16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMonthsSelector(controller),
                        AppSpacing.v16,
                        _buildStatsGrid(data),
                        AppSpacing.v32,
                        _buildSectionHeader('Revenue Trend'),
                        AppSpacing.v16,
                        _buildRevenueChart(data.revenue.monthlyTrend),
                        AppSpacing.v32,
                        _buildSectionHeader('Fee Collection %'),
                        AppSpacing.v16,
                        _buildCollectionChart(data.feeCollection.monthlyTrend),
                        AppSpacing.v32,
                        _buildSectionHeader('Batch-wise Attendance Trend'),
                        AppSpacing.v16,
                        ...data.attendance.batches.map(
                          (batch) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                            child: _buildAttendanceBatchCard(batch),
                          ),
                        ),
                        if (data.attendance.batches.isEmpty)
                          _buildEmptyRow('No batches yet'),
                        AppSpacing.v16,
                        _buildSectionHeader('Batch-wise Dropout'),
                        AppSpacing.v16,
                        ...data.dropout.batches.map(
                          (batch) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                            child: _buildDropoutBatchCard(batch),
                          ),
                        ),
                        if (data.dropout.batches.isEmpty)
                          _buildEmptyRow('No batches yet'),
                        AppSpacing.v32,
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthsSelector(ReportsController controller) {
    return Obx(() {
      final selected = controller.analyticsMonths.value;
      return Row(
        children: [3, 6, 12].map((m) {
          final isSelected = selected == m;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s8),
            child: GestureDetector(
              onTap: () => controller.loadAnalytics(months: m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBrand : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBrand : AppColors.background,
                  ),
                ),
                child: Text(
                  'Last $m mo',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.white : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildStatsGrid(AnalyticsResponse data) {
    final growth = data.revenue.growthPercent;
    final growthUp = growth >= 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.s12,
      mainAxisSpacing: AppSpacing.s12,
      childAspectRatio: 1.5,
      children: [
        AnalyticsStatCard(
          title: 'This Month Revenue',
          value: '₹${data.revenue.currentMonthTotal.toStringAsFixed(0)}',
          trailingLabel:
              '${growthUp ? '▲' : '▼'} ${growth.abs().toStringAsFixed(1)}% vs last month',
          trailingColor: growthUp ? Colors.green : Colors.red,
        ),
        AnalyticsStatCard(
          title: 'Fee Collection Rate',
          value: '${data.feeCollection.overallPercent.toStringAsFixed(1)}%',
          valueColor: Colors.green,
          trailingLabel: 'All-time',
        ),
        AnalyticsStatCard(
          title: 'Attendance This Month',
          value:
              '${data.attendance.overallPercentThisMonth.toStringAsFixed(1)}%',
          trailingLabel: 'Across all batches',
        ),
        AnalyticsStatCard(
          title: 'Dropout Rate',
          value: '${data.dropout.overallRate.toStringAsFixed(1)}%',
          valueColor: Colors.red,
          trailingLabel:
              '${data.dropout.totalInactive} of ${data.dropout.totalActive + data.dropout.totalInactive} students',
        ),
      ],
    );
  }

  Widget _buildRevenueChart(List<RevenueMonthPoint> trend) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TrendBarChart(
        labels: trend.map((t) => t.month.split(' ').first).toList(),
        values: trend.map((t) => t.totalRevenue).toList(),
        barColor: AppColors.primaryBrand,
        valueFormatter: (v) => v >= 1000
            ? '₹${(v / 1000).toStringAsFixed(1)}k'
            : '₹${v.toStringAsFixed(0)}',
      ),
    );
  }

  Widget _buildCollectionChart(List<CollectionMonthPoint> trend) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TrendBarChart(
        labels: trend.map((t) => t.month.split(' ').first).toList(),
        values: trend.map((t) => t.percent).toList(),
        barColor: Colors.green,
        valueFormatter: (v) => '${v.toStringAsFixed(0)}%',
      ),
    );
  }

  Widget _buildAttendanceBatchCard(AnalyticsAttendanceBatch batch) {
    final latest = batch.trend.isNotEmpty ? batch.trend.last.percent : null;
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                batch.batchName,
                style: AppTextStyles.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                latest != null ? '${latest.toStringAsFixed(1)}%' : '—',
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBrand,
                ),
              ),
            ],
          ),
          AppSpacing.v16,
          TrendBarChart(
            labels: batch.trend.map((t) => t.month).toList(),
            values: batch.trend.map((t) => t.percent).toList(),
            barColor: AppColors.primaryBrand,
            height: 110,
            valueFormatter: (v) => '${v.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildDropoutBatchCard(AnalyticsDropoutBatch batch) {
    final progress = batch.total > 0 ? batch.inactiveCount / batch.total : 0.0;
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.background),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                batch.batchName,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${batch.dropoutRate.toStringAsFixed(1)}% dropout',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          AppSpacing.v8,
          Text(
            '${batch.activeCount} active · ${batch.inactiveCount} inactive of ${batch.total}',
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
          AppSpacing.v8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.green.withValues(alpha: 0.15),
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
      child: Text(
        text,
        style: AppTextStyles.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

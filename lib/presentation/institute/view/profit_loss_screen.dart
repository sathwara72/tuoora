import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/period_filter_bar.dart';
import 'package:tuoora/presentation/institute/controllers/profit_loss_controller.dart';
import 'package:tuoora/presentation/institute/models/profit_loss_model.dart';
import 'package:tuoora/presentation/institute/widgets/expense_widgets.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class ProfitLossScreen extends GetView<ProfitLossController> {
  const ProfitLossScreen({super.key});

  static const _income = AppColors.successGreen;
  static const _expense = AppColors.errorRed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: 'Profit & Loss',
              isRoot: false,
              actions: [
                IconButton(
                  tooltip: 'Download PDF',
                  onPressed: controller.exportPdf,
                  icon: const Icon(
                    Icons.download_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Obx(
                () => PeriodFilterBar(
                  period: controller.period.value,
                  onChanged: controller.setPeriod,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                final report = controller.report.value;
                if (controller.isLoading.value && report == null) {
                  return const CommonLoading();
                }
                return RefreshIndicator(
                  onRefresh: controller.load,
                  color: AppColors.primaryBrand,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: _buildBody(report),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(ProfitLossReport? report) {
    final error = controller.error.value;
    if (report == null) {
      return [
        const SizedBox(height: 60),
        AppEmptyView(
          icon: Icons.error_outline_rounded,
          title: 'Could not load Profit & Loss',
          message: error ?? 'Pull down to try again.',
        ),
      ];
    }
    return [
      _buildHero(report),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _totalTile(
              'Income',
              report.totalIncome,
              Icons.south_west_rounded,
              _income,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _totalTile(
              'Expenses',
              report.totalExpense,
              Icons.north_east_rounded,
              _expense,
            ),
          ),
        ],
      ),
      if (report.isEmpty) ...[
        const SizedBox(height: 40),
        const AppEmptyView(
          icon: Icons.account_balance_outlined,
          title: 'Nothing recorded in this period',
          message: 'Fee payments and expenses will show up here.',
        ),
      ] else ...[
        if (report.monthlyTrend.length > 1) ...[
          _sectionTitle('Monthly Trend'),
          _buildTrend(report.monthlyTrend),
        ],
        _sectionTitle('Expense Breakdown'),
        _buildExpenseBreakdown(report),
        _sectionTitle('Income Breakdown'),
        _buildIncomeBreakdown(report),
        if (report.topBatches.isNotEmpty) ...[
          _sectionTitle('Top Batches by Collection'),
          _buildTopBatches(report.topBatches),
        ],
      ],
    ];
  }

  Widget _buildHero(ProfitLossReport r) {
    final color = r.isProfit ? _income : _expense;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.isProfit ? 'Net Profit' : 'Net Loss',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              if (r.periodLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.periodLabel,
                    style: AppTextStyles.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatInr(r.netProfit.abs()),
              style: AppTextStyles.outfit(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (r.profitMarginPercent != null)
                'Margin ${r.profitMarginPercent!.toStringAsFixed(1)}%',
              r.includeSalaryInExpenses
                  ? 'Includes staff salaries'
                  : 'Staff salaries not included',
            ].join(' • '),
            style: AppTextStyles.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalTile(String label, double amount, IconData icon, Color color) {
    return _card(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatInr(amount),
                    style: AppTextStyles.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Paired income / expense bars per month, scrolling sideways for long
  /// custom ranges.
  Widget _buildTrend(List<ProfitLossMonth> months) {
    final peak = months.fold<double>(
      0,
      (m, e) => math.max(m, math.max(e.income, e.expense)),
    );
    const barMax = 110.0;
    double h(double v) => peak <= 0 ? 0 : math.max(2, v / peak * barMax);

    return _card(
      child: Column(
        children: [
          Row(
            children: [
              _legend('Income', _income),
              const SizedBox(width: 14),
              _legend('Expenses', _expense),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final m in months)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: barMax,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _bar(h(m.income), _income),
                              const SizedBox(width: 3),
                              _bar(h(m.expense), _expense),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          m.shortName,
                          style: AppTextStyles.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          formatInr(m.profit),
                          style: AppTextStyles.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: m.profit >= 0 ? _income : _expense,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double height, Color color) => Container(
    width: 10,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
    ),
  );

  Widget _legend(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: AppTextStyles.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    ],
  );

  Widget _buildExpenseBreakdown(ProfitLossReport r) {
    if (r.expenseBreakdown.isEmpty) {
      return _card(child: _muted('No expenses in this period.'));
    }
    return _card(
      child: Column(
        children: [
          for (var i = 0; i < r.expenseBreakdown.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _categoryRow(r.expenseBreakdown[i]),
          ],
        ],
      ),
    );
  }

  Widget _categoryRow(ProfitLossCategory c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                c.categoryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatInr(c.amount),
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (c.percentage / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceBg,
                  color: c.isSalary ? AppColors.primaryBrand : _expense,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 92,
              child: Text(
                '${c.percentage.toStringAsFixed(1)}% • ${c.count} '
                '${c.count == 1 ? 'txn' : 'txns'}',
                textAlign: TextAlign.right,
                style: AppTextStyles.outfit(
                  fontSize: 10.5,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeBreakdown(ProfitLossReport r) {
    if (r.totalIncome <= 0) {
      return _card(child: _muted('No fee payments in this period.'));
    }
    return _card(
      child: Column(
        children: [
          for (var i = 0; i < r.incomeByMethod.length; i++) ...[
            if (i > 0) const Divider(height: 18),
            _kv(
              r.incomeByMethod[i].method,
              '${r.incomeByMethod[i].count} '
              '${r.incomeByMethod[i].count == 1 ? 'payment' : 'payments'}',
              r.incomeByMethod[i].amount,
            ),
          ],
          if (r.incomeByMethod.isEmpty) ...[
            _kv('Cash', null, r.cashIncome),
            const Divider(height: 18),
            _kv('Online', null, r.onlineIncome),
          ],
        ],
      ),
    );
  }

  Widget _buildTopBatches(List<ProfitLossBatch> batches) {
    return _card(
      child: Column(
        children: [
          for (var i = 0; i < batches.length; i++) ...[
            if (i > 0) const Divider(height: 18),
            _kv(batches[i].batchName, null, batches[i].amount),
          ],
        ],
      ),
    );
  }

  Widget _kv(String label, String? sub, double amount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (sub != null)
                Text(
                  sub,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatInr(amount),
          style: AppTextStyles.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _income,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(
      title,
      style: AppTextStyles.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
  );

  Widget _muted(String text) => Text(
    text,
    style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderGrey),
    ),
    child: child,
  );
}

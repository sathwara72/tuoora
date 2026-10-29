import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/data/models/financial_period.dart';

/// Financial Year / Current Year / Custom filter used by Expenses and
/// Profit & Loss. Tapping Financial Year again picks an earlier year.
class PeriodFilterBar extends StatelessWidget {
  final FinancialPeriod period;
  final ValueChanged<FinancialPeriod> onChanged;

  const PeriodFilterBar({
    super.key,
    required this.period,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _chip(
                label: period.type == FinancialPeriodType.financialYear
                    ? period.label
                    : 'Financial Year',
                selected: period.type == FinancialPeriodType.financialYear,
                trailing: Icons.keyboard_arrow_down_rounded,
                onTap: () {
                  if (period.type == FinancialPeriodType.financialYear) {
                    _pickFinancialYear();
                  } else {
                    onChanged(FinancialPeriod.financialYear());
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _chip(
                label: 'Current Year',
                selected: period.type == FinancialPeriodType.currentYear,
                onTap: () => onChanged(FinancialPeriod.currentYear()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _chip(
                label: 'Custom',
                selected: period.type == FinancialPeriodType.custom,
                trailing: Icons.date_range_rounded,
                onTap: () => _pickCustom(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (period.type == FinancialPeriodType.custom) {
              _pickCustom(context);
            } else if (period.type == FinancialPeriodType.financialYear) {
              _pickFinancialYear();
            }
          },
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  period.rangeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBrand : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primaryBrand : AppColors.borderGrey,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 2),
              Icon(
                trailing,
                size: 15,
                color: selected ? AppColors.white : AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _pickFinancialYear() {
    final current = FinancialPeriod.currentFyStartYear();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Financial Year',
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              for (var y = current; y > current - 5; y--)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    FinancialPeriod.fyLabel(y),
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    FinancialPeriod.financialYear(y).rangeLabel,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  trailing: y == period.fyStartYear
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryBrand,
                        )
                      : null,
                  onTap: () {
                    Get.back();
                    onChanged(FinancialPeriod.financialYear(y));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCustom(BuildContext context) async {
    final now = DateTime.now();
    final range = await AppPickers.dateRange(
      context,
      initialRange: period.type == FinancialPeriodType.custom
          ? DateTimeRange(start: period.start, end: period.end)
          : DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Select date range',
    );
    if (range != null) {
      onChanged(FinancialPeriod.custom(range.start, range.end));
    }
  }
}

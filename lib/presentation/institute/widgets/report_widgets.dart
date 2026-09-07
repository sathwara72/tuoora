import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';

class ReportSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const ReportSummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.v8,
          Text(
            value,
            style: AppTextStyles.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.primaryBrand,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportBatchItemCard extends StatelessWidget {
  final String name;
  final int strength;
  final String metricLabel;
  final String metricValue;
  final double progress;
  final VoidCallback onTap;

  const ReportBatchItemCard({
    super.key,
    required this.name,
    required this.strength,
    required this.metricLabel,
    required this.metricValue,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = strength <= 0;

    final card = Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: isDisabled
            ? null
            : [
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
          Text(
            name,
            style: AppTextStyles.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Batch Strength: $strength Students',
            style: AppTextStyles.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
          AppSpacing.v20,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metricLabel,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                metricValue,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
            ],
          ),
          AppSpacing.v8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.background,
              color: AppColors.primaryBrand,
            ),
          ),
        ],
      ),
    );

    if (isDisabled) {
      return Opacity(opacity: 0.7, child: card);
    }

    return GestureDetector(onTap: onTap, child: card);
  }
}

class AnalyticsStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? trailingLabel;
  final Color? trailingColor;
  final Color? valueColor;

  const AnalyticsStatCard({
    super.key,
    required this.title,
    required this.value,
    this.trailingLabel,
    this.trailingColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            title,
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
          AppSpacing.v8,
          Text(
            value,
            style: AppTextStyles.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.primaryBrand,
            ),
          ),
          if (trailingLabel != null) ...[
            AppSpacing.v4,
            Text(
              trailingLabel!,
              style: AppTextStyles.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: trailingColor ?? AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A minimal, dependency-free bar trend chart: one bar per value, scaled to
/// the tallest value in the series, with a label underneath each bar.
class TrendBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double?> values;
  final Color barColor;
  final double height;
  final String Function(double)? valueFormatter;

  const TrendBarChart({
    super.key,
    required this.labels,
    required this.values,
    this.barColor = AppColors.primaryBrand,
    this.height = 140,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values
        .whereType<double>()
        .fold<double>(0, (max, v) => v > max ? v : max);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(labels.length, (index) {
          final value = index < values.length ? values[index] : null;
          final ratio = (maxValue > 0 && value != null)
              ? (value / maxValue).clamp(0.0, 1.0)
              : 0.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (value != null)
                    Text(
                      valueFormatter != null
                          ? valueFormatter!(value)
                          : value.toStringAsFixed(0),
                      style: AppTextStyles.outfit(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  AppSpacing.v4,
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    child: Container(
                      height: (height - 40) * ratio + (value != null ? 4 : 0),
                      color: value != null
                          ? barColor
                          : AppColors.background,
                    ),
                  ),
                  AppSpacing.v6,
                  Text(
                    labels[index],
                    style: AppTextStyles.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ReportStudentItemCard extends StatelessWidget {
  final String name;
  final String metric;
  final String? subtitle;
  final Color metricColor;

  const ReportStudentItemCard({
    super.key,
    required this.name,
    required this.metric,
    this.subtitle,
    required this.metricColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.background),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  AppSpacing.v4,
                  Text(
                    subtitle!,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: metricColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              metric,
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: metricColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

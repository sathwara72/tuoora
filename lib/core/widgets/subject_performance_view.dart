import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/data/models/subject_performance_model.dart';

/// "Needs attention in: ..." alert plus one card per subject (level,
/// average %, trend, latest score, exams taken and absences).
class SubjectPerformanceView extends StatelessWidget {
  final SubjectPerformance performance;

  const SubjectPerformanceView({super.key, required this.performance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (performance.weak.isNotEmpty) ...[
          SubjectAttentionAlert(subjects: performance.weak),
          AppSpacing.v12,
        ],
        ...performance.subjects.map(
          (s) => Padding(
            padding: AppSpacing.bottom10,
            child: SubjectPerformanceCard(item: s),
          ),
        ),
      ],
    );
  }
}

class SubjectAttentionAlert extends StatelessWidget {
  final List<String> subjects;

  const SubjectAttentionAlert({super.key, required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.all12,
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.bohoRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          AppSpacing.h8,
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Needs attention in: ',
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bohoRed,
                    ),
                  ),
                  TextSpan(
                    text: subjects.join(', '),
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectPerformanceCard extends StatelessWidget {
  final SubjectPerformanceItem item;

  const SubjectPerformanceCard({super.key, required this.item});

  ({String label, Color fg, Color bg}) get _level {
    switch (item.level) {
      case 'weak':
        return (label: 'Weak', fg: AppColors.bohoRed, bg: AppColors.errorBg);
      case 'strong':
        return (
          label: 'Strong',
          fg: AppColors.greenText,
          bg: AppColors.successBg,
        );
      case 'average':
        return (
          label: 'Average',
          fg: AppColors.warningAmber,
          bg: AppColors.warningBg,
        );
      default:
        return (
          label: 'No data',
          fg: AppColors.textSecondary,
          bg: AppColors.fieldBg,
        );
    }
  }

  ({IconData icon, String label, Color color}) get _trend {
    switch (item.trend) {
      case 'improving':
        return (
          icon: Icons.trending_up_rounded,
          label: 'Improving',
          color: AppColors.greenText,
        );
      case 'declining':
        return (
          icon: Icons.trending_down_rounded,
          label: 'Declining',
          color: AppColors.bohoRed,
        );
      default:
        return (
          icon: Icons.trending_flat_rounded,
          label: 'Steady',
          color: AppColors.textSecondary,
        );
    }
  }

  String _pct(double? v) {
    if (v == null) return '—';
    return v == v.roundToDouble()
        ? '${v.toStringAsFixed(0)}%'
        : '${v.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final level = _level;
    final trend = _trend;
    final avg = item.averagePercentage;
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border(left: BorderSide(color: level.fg, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: level.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level.label,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: level.fg,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v12,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _pct(avg),
                style: AppTextStyles.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: level.fg,
                ),
              ),
              AppSpacing.h4,
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'average',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Spacer(),
              Icon(trend.icon, size: 18, color: trend.color),
              AppSpacing.h4,
              Text(
                trend.label,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: trend.color,
                ),
              ),
            ],
          ),
          AppSpacing.v8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ((avg ?? 0) / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.fieldBg,
              color: level.fg,
            ),
          ),
          AppSpacing.v12,
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _stat(
                'Latest',
                _pct(item.latestPercentage),
                highlight: item.failedLatest,
              ),
              _stat('Exams taken', '${item.examsTaken}'),
              _stat(
                'Absent',
                '${item.examsAbsent}',
                highlight: item.examsAbsent > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {bool highlight = false}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: AppTextStyles.outfit(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          TextSpan(
            text: value,
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.bohoRed : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

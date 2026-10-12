import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/student/controllers/student_exams_controller.dart';
import 'package:tuoora/presentation/student/models/student_exam_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';
import 'package:tuoora/presentation/student/widgets/student_description_card.dart';
import 'package:tuoora/presentation/student/widgets/student_info_tile.dart';
import 'package:tuoora/presentation/student/widgets/student_status_badge.dart';

class StudentExamDetailScreen extends GetView<StudentExamsController> {
  const StudentExamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
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
                  return const CommonLoading(color: AppColors.primaryBrand);
                }

                final exam = controller.selectedExam.value!;
                return _DetailBody(exam: exam);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final StudentExamDetail exam;

  const _DetailBody({required this.exam});

  @override
  Widget build(BuildContext context) {
    final result = exam.result;
    final showResultCard =
        exam.isCompleted && result.hasResult && !result.isAbsent;
    final description = exam.description?.trim();

    return SingleChildScrollView(
      padding: AppSpacing.screenPaddingTop,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ExamHeaderCard(exam: exam),
          const SizedBox(height: AppSpacing.s12),
          _InfoGridSection(exam: exam),
          if (exam.isCompleted) ...[
            const SizedBox(height: AppSpacing.s12),
            if (!result.hasResult)
              const _PlainNoticeCard(
                icon: Icons.hourglass_empty_rounded,
                text: 'Marks have not been entered for this exam yet.',
              )
            else if (result.isAbsent)
              const _AbsentBanner()
            else
              _StatsCard(exam: exam, result: result),
          ] else ...[
            const SizedBox(height: AppSpacing.s12),
            const _PlainNoticeCard(
              icon: Icons.hourglass_empty_rounded,
              text: 'Results will appear here once the exam is graded.',
            ),
          ],
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s12),
            StudentDescriptionCard(title: 'DESCRIPTION', text: description),
          ],
          if (showResultCard) ...[
            const SizedBox(height: AppSpacing.s16),
            _ResultBanner(exam: exam, result: result),
          ],
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}

class _ExamHeaderCard extends StatelessWidget {
  final StudentExamDetail exam;

  const _ExamHeaderCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSpacing.s44,
            height: AppSpacing.s44,
            decoration: BoxDecoration(
              color: AppColors.violetSoft,
              borderRadius: BorderRadius.circular(AppSpacing.s12),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: AppColors.violet,
              size: 22,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exam.title,
                  style: AppTextStyles.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exam.subject != null
                      ? '${exam.subject} · ${exam.examTypeLabel}'
                      : exam.examTypeLabel,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.h8,
          if (exam.isCompleted)
            const StudentStatusBadge(
              icon: Icons.check_circle_rounded,
              label: 'Completed',
              background: AppColors.successBg,
              foreground: AppColors.successGreen,
            )
          else
            const StudentStatusBadge(
              icon: Icons.schedule_rounded,
              label: 'Upcoming',
              background: AppColors.studentUpdateIconBg,
              foreground: AppColors.studentUpdateIconColor,
            ),
        ],
      ),
    );
  }
}

class _InfoGridSection extends StatelessWidget {
  final StudentExamDetail exam;

  const _InfoGridSection({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StudentInfoTile(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: exam.formattedDate ?? '—',
              ),
            ),
            AppSpacing.h10,
            Expanded(
              child: StudentInfoTile(
                icon: Icons.access_time_rounded,
                label: 'Time',
                value: exam.timeRangeLabel ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s10),
        Row(
          children: [
            Expanded(
              child: StudentInfoTile(
                icon: Icons.menu_book_outlined,
                label: 'Subject',
                value: exam.subject ?? '—',
              ),
            ),
            AppSpacing.h10,
            Expanded(
              child: StudentInfoTile(
                icon: Icons.assignment_outlined,
                label: 'Exam Type',
                value: exam.examTypeLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final StudentExamDetail exam;
  final StudentExamResult result;

  const _StatsCard({required this.exam, required this.result});

  @override
  Widget build(BuildContext context) {
    final isPass = result.isPass ?? true;
    final scoreColor = isPass ? AppColors.textPrimary : AppColors.bohoRed;

    final avg = exam.classStats.averageMarks;
    final avgPct = exam.totalMarks > 0 ? (avg / exam.totalMarks) * 100 : 0;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _statColumn(
              label: 'Score',
              value: Column(
                children: [
                  Text(
                    '${result.marksObtained!.toStringAsFixed(0)}/${exam.totalMarks.toStringAsFixed(0)}',
                    style: AppTextStyles.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                  if (result.percentage != null)
                    Text(
                      '${result.percentage!.toStringAsFixed(0)}%',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          _divider(),
          Expanded(
            child: _statColumn(
              label: 'Rank',
              value: Column(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.warningAmber,
                    size: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.rank != null ? 'Rank ${result.rank}' : '—',
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
          _divider(),
          Expanded(
            child: _statColumn(
              label: 'Class Average',
              value: Column(
                children: [
                  Text(
                    '${avg.toStringAsFixed(0)}/${exam.totalMarks.toStringAsFixed(0)}',
                    style: AppTextStyles.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${avgPct.toStringAsFixed(0)}%',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: AppColors.textTertiary,
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

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      color: AppColors.borderGrey,
    );
  }

  Widget _statColumn({required String label, required Widget value}) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        value,
      ],
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final StudentExamDetail exam;
  final StudentExamResult result;

  const _ResultBanner({required this.exam, required this.result});

  @override
  Widget build(BuildContext context) {
    final isPass = result.isPass ?? true;
    final bg = isPass ? AppColors.warningBg : AppColors.errorBg;
    final iconBg = isPass ? AppColors.warningAmber : AppColors.bohoRed;
    final textColor = isPass ? AppColors.textPrimary : AppColors.bohoRed;
    final title = isPass ? 'Excellent!' : 'Keep Trying!';

    final buffer = StringBuffer(
      'You scored ${result.marksObtained!.toStringAsFixed(0)}/${exam.totalMarks.toStringAsFixed(0)}.',
    );
    if (isPass && result.rank != null) {
      buffer.write(' You secured Rank ${result.rank} in your class!');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s24,
        horizontal: AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            title,
            style: AppTextStyles.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            buffer.toString(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AbsentBanner extends StatelessWidget {
  const _AbsentBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_busy_rounded, color: AppColors.bohoRed),
          AppSpacing.h12,
          Text(
            'Marked absent for this exam',
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.bohoRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainNoticeCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PlainNoticeCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary),
          AppSpacing.h12,
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.outfit(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/url_launcher_utils.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_homework_grading_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_homework_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherHomeworkGradingScreen extends GetView<TeacherHomeworkGradingController> {
  const TeacherHomeworkGradingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(title: 'Grade · ${controller.homework.title}'),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.submissions.isEmpty) {
                  return Center(
                    child: Text(
                      'No students in this batch.',
                      style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  );
                }
                final list = controller.filteredSubmissions;
                return ListView(
                  padding: AppSpacing.x16.add(const EdgeInsets.only(bottom: AppSpacing.s16)),
                  children: [
                    _ProgressCard(controller: controller),
                    AppSpacing.v12,
                    if (controller.homeworkClosed) ...[
                      const _ClosedBanner(),
                      AppSpacing.v12,
                    ],
                    if (list.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No students match this status.',
                            style: AppTextStyles.outfit(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final s in list) ...[
                        _SubmissionRow(submission: s, controller: controller),
                        AppSpacing.v12,
                      ],
                  ],
                );
              }),
            ),
            Obx(() {
              if (controller.isLoading.value || controller.homeworkClosed) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: AppSpacing.x16.add(const EdgeInsets.only(bottom: AppSpacing.s16)),
                child: AppButton(
                  label: 'Publish Grades',
                  onPressed: controller.submitGrades,
                  isLoading: controller.isSaving.value,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final TeacherHomeworkGradingController controller;

  const _ProgressCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final pct = (controller.completion * 100).toStringAsFixed(0);
    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${controller.submittedCount}',
                        style: AppTextStyles.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${controller.totalCount} submitted',
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '$pct% complete',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBrand,
                ),
              ),
            ],
          ),
          AppSpacing.v8,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: controller.completion,
              minHeight: 6,
              backgroundColor: AppColors.borderGrey,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryBrand),
            ),
          ),
          AppSpacing.v12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('All', controller.totalCount, 'all'),
              _chip('Submitted', controller.awaitingReviewCount, 'submitted'),
              _chip('Pending', controller.pendingCount, 'pending'),
              _chip('Reviewed', controller.reviewedCount, 'reviewed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, int count, String key) {
    final selected = controller.filter.value == key;
    return GestureDetector(
      onTap: () => controller.filter.value = key,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBrand : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primaryBrand : AppColors.fieldBorder,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: AppTextStyles.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: Colors.amber.shade900),
          AppSpacing.h8,
          Expanded(
            child: Text(
              'This homework is closed. Grades can no longer be changed.',
              style: AppTextStyles.outfit(fontSize: 12, color: Colors.amber.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  final TeacherHomeworkSubmission submission;
  final TeacherHomeworkGradingController controller;

  const _SubmissionRow({required this.submission, required this.controller});

  @override
  Widget build(BuildContext context) {
    final canGrade = controller.canGrade(submission);
    final hasAttachment =
        submission.attachmentUrl != null && submission.attachmentUrl!.isNotEmpty;
    final subtitle = submission.enrollmentId?.isNotEmpty == true
        ? submission.enrollmentId!
        : 'ID: #ST-${submission.studentId.toString().padLeft(4, '0')}';

    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: submission.status),
            ],
          ),
          if (submission.note != null && submission.note!.isNotEmpty) ...[
            AppSpacing.v8,
            Text(
              submission.note!,
              style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          if (hasAttachment) ...[
            AppSpacing.v8,
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => UrlLauncherUtils.openExternal(submission.attachmentUrl!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrandLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryBrand.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file_rounded, size: 15, color: AppColors.primaryBrand),
                      AppSpacing.h6,
                      Text(
                        'View File',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          AppSpacing.v12,
          Row(
            children: [
              Text(
                'Rating (out of ${TeacherHomeworkGradingController.maxScore})',
                style: AppTextStyles.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fieldLabel,
                ),
              ),
              const Spacer(),
              _stepButton(Icons.remove_rounded, canGrade, () => controller.changeScore(submission, -1)),
              SizedBox(
                width: 44,
                child: Text(
                  '${(submission.score ?? 0).round()}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: canGrade ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
              ),
              _stepButton(Icons.add_rounded, canGrade, () => controller.changeScore(submission, 1)),
            ],
          ),
          if (!canGrade && !controller.homeworkClosed) ...[
            AppSpacing.v8,
            Text(
              'Rating is available once the student submits.',
              style: AppTextStyles.outfit(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryBrand.withValues(alpha: 0.1) : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primaryBrand : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final Color color;
    final String label;
    switch (s) {
      case 'reviewed':
        color = AppColors.successGreen;
        label = 'Reviewed';
      case 'submitted':
        color = AppColors.primaryBrand;
        label = 'Submitted';
      case 'late':
        color = Colors.amber.shade800;
        label = 'Late';
      default:
        color = AppColors.textTertiary;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/student/controllers/assignments_controller.dart';
import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';
import 'package:tuoora/presentation/student/widgets/student_section_header.dart';

class StudentAssignmentDetailScreen extends GetView<AssignmentsController> {
  const StudentAssignmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isDetailLoading.value) {
            return const CommonLoading(color: AppColors.primaryBrand);
          }
          final assignment = controller.selectedAssignment.value;
          if (assignment == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.s24),
                child: Text(AppStrings.noAssignmentSelected),
              ),
            );
          }
          return _DetailBody(assignment: assignment);
        }),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Assignment assignment;

  const _DetailBody({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StudentAppBar(
          title: AppStrings.studentAssignmentDetailTitle,
          showDefaultActions: false,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPaddingTop,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AssignmentHeaderCard(assignment: assignment),
                const SizedBox(height: AppSpacing.s12),
                _MetaInfoRow(assignment: assignment),
                const SizedBox(height: AppSpacing.s12),
                _DescriptionCard(assignment: assignment),
                if (assignment.instructionLines.length > 1) ...[
                  const SizedBox(height: AppSpacing.s12),
                  _InstructionsListCard(assignment: assignment),
                ],
                if (assignment.attachments.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s20),
                  const StudentSectionHeader(
                    title: AppStrings.studentAssignmentDetailAttachments,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  ..._interleave(
                    assignment.attachments.map(
                      (a) => _AttachmentTile(
                        attachment: a,
                        onTap: () =>
                            Get.find<AssignmentsController>().openAttachment(a),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                  ),
                ],
                const SizedBox(height: AppSpacing.s16),
                _StatusBanner(assignment: assignment),
                if (assignment.isCompleted && assignment.score != null) ...[
                  const SizedBox(height: AppSpacing.s16),
                  _ResultCard(score: assignment.score!),
                ],
                const SizedBox(height: AppSpacing.s16),
                _SubmitAssignmentButton(assignment: assignment),
                const SizedBox(height: AppSpacing.s16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static List<Widget> _interleave(Iterable<Widget> items, Widget separator) {
    final list = items.toList();
    if (list.length <= 1) return list;
    final out = <Widget>[];
    for (var i = 0; i < list.length; i++) {
      if (i > 0) out.add(separator);
      out.add(list[i]);
    }
    return out;
  }
}

class _AssignmentHeaderCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentHeaderCard({required this.assignment});

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
              color: assignment.iconBg,
              borderRadius: BorderRadius.circular(AppSpacing.s12),
            ),
            child: Icon(assignment.icon, color: assignment.iconColor, size: 22),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  assignment.title,
                  style: AppTextStyles.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assignment.assignedBy != null
                      ? '${assignment.subjectLabel} · ${assignment.assignedBy}'
                      : assignment.subjectLabel,
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
          _DetailDuePill(assignment: assignment),
        ],
      ),
    );
  }
}

class _DetailDuePill extends StatelessWidget {
  final Assignment assignment;

  const _DetailDuePill({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final bg = assignment.isCompleted
        ? AppColors.successBg
        : assignment.isOverdue
        ? AppColors.errorBg
        : AppColors.primaryBrandLight;
    final fg = assignment.isCompleted
        ? AppColors.successGreen
        : assignment.isOverdue
        ? AppColors.bohoRed
        : AppColors.primaryBrand;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.s8),
      ),
      child: Text(
        assignment.isCompleted
            ? AppStrings.studentDonePill
            : (assignment.dueDateFullText ?? assignment.dueLabel),
        style: AppTextStyles.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _MetaInfoRow extends StatelessWidget {
  final Assignment assignment;

  const _MetaInfoRow({required this.assignment});

  @override
  Widget build(BuildContext context) {
    String publishedLabel = '—';
    final createdAt = assignment.createdAt;
    if (createdAt != null) {
      publishedLabel = DateFormat('d MMM yyyy').format(createdAt);
    }

    final statusLabel = assignment.isCompleted
        ? 'Submitted'
        : assignment.isOverdue
        ? 'Overdue'
        : 'Pending';

    return Row(
      children: [
        Expanded(
          child: _MetaInfoTile(
            icon: Icons.event_available_outlined,
            label: 'Published On',
            value: publishedLabel,
          ),
        ),
        AppSpacing.h10,
        Expanded(
          child: _MetaInfoTile(
            icon: Icons.flag_outlined,
            label: 'Status',
            value: statusLabel,
          ),
        ),
        AppSpacing.h10,
        Expanded(
          child: _MetaInfoTile(
            icon: Icons.attach_file_rounded,
            label: 'Attachments',
            value: '${assignment.attachments.length}',
          ),
        ),
      ],
    );
  }
}

class _MetaInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s12,
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBrand),
          const SizedBox(height: AppSpacing.s8),
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final Assignment assignment;

  const _DescriptionCard({required this.assignment});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.studentAssignmentDetailDescription,
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.orangeTag,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            assignment.instructions ?? '—',
            style: AppTextStyles.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsListCard extends StatelessWidget {
  final Assignment assignment;

  const _InstructionsListCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final lines = assignment.instructionLines;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${AppStrings.studentAssignmentDetailInstructions} (${lines.length})',
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.orangeTag,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          ...List.generate(lines.length, (i) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: i == lines.length - 1 ? 0 : AppSpacing.s10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.fieldBg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  AppSpacing.h10,
                  Expanded(
                    child: Text(
                      lines[i],
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final AssignmentAttachment attachment;
  final VoidCallback? onTap;

  const _AttachmentTile({required this.attachment, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.s12),
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
              _AttachmentIcon(kind: attachment.kind),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      attachment.name,
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_kindLabel(attachment.kind)} · ${attachment.sizeLabel}',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: AppSpacing.s32,
                height: AppSpacing.s32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(AppSpacing.s10),
                ),
                child: const Icon(
                  Icons.download_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _kindLabel(AssignmentAttachmentKind kind) {
    switch (kind) {
      case AssignmentAttachmentKind.document:
        return AppStrings.studentAssignmentAttachmentDocument;
      case AssignmentAttachmentKind.image:
        return AppStrings.studentAssignmentAttachmentImage;
      case AssignmentAttachmentKind.video:
        return AppStrings.studentAssignmentAttachmentVideo;
      case AssignmentAttachmentKind.audio:
        return AppStrings.studentAssignmentAttachmentAudio;
    }
  }
}

class _AttachmentIcon extends StatelessWidget {
  final AssignmentAttachmentKind kind;

  const _AttachmentIcon({required this.kind});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    switch (kind) {
      case AssignmentAttachmentKind.document:
        bg = AppColors.successBg;
        fg = AppColors.successGreen;
        icon = Icons.description_rounded;
        break;
      case AssignmentAttachmentKind.image:
        bg = AppColors.primaryBrandLight;
        fg = AppColors.orangeTag;
        icon = Icons.image_rounded;
        break;
      case AssignmentAttachmentKind.video:
        bg = AppColors.primaryBrandLight;
        fg = AppColors.orangeTag;
        icon = Icons.videocam_rounded;
        break;
      case AssignmentAttachmentKind.audio:
        bg = AppColors.primaryBrandLight;
        fg = AppColors.orangeTag;
        icon = Icons.audiotrack_rounded;
        break;
    }
    return Container(
      width: AppSpacing.s40,
      height: AppSpacing.s40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.s12),
      ),
      child: Icon(icon, color: fg, size: 20),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Assignment assignment;

  const _StatusBanner({required this.assignment});

  @override
  Widget build(BuildContext context) {
    if (assignment.isCompleted) {
      return _CompletedBanner(assignment: assignment);
    }
    return _PendingBanner(assignment: assignment);
  }
}

class _SubmitAssignmentButton extends StatelessWidget {
  final Assignment assignment;

  const _SubmitAssignmentButton({required this.assignment});

  @override
  Widget build(BuildContext context) {
    if (assignment.dueDatePassed) {
      return _StaticButton(
        backgroundColor: AppColors.textTertiary,
        icon: Icons.lock_outline_rounded,
        label: AppStrings.overdueCannotSubmit,
      );
    }

    return _SubmissionForm(assignment: assignment);
  }
}

/// Note + optional file attachment, editable any number of times up until
/// the due date — including after a first submission, so a student can fix
/// a mistake without waiting on the institute.
class _SubmissionForm extends StatelessWidget {
  final Assignment assignment;

  const _SubmissionForm({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AssignmentsController>();
    final alreadySubmitted = assignment.isCompleted;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alreadySubmitted ? 'Edit Your Submission' : 'Submit Your Work',
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.v12,
          TextField(
            controller: controller.noteController,
            maxLines: 4,
            minLines: 3,
            style: AppTextStyles.outfit(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Add a note (optional if you attach a file)',
              hintStyle: AppTextStyles.outfit(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceBg,
              contentPadding: AppSpacing.all12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.s12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          AppSpacing.v12,
          Obx(() {
            final newPath = controller.newAttachmentLocalPath.value;
            return _AttachmentPicker(
              assignment: assignment,
              controller: controller,
              newPath: newPath,
            );
          }),
          AppSpacing.v16,
          Obx(() {
            final submitting = controller.isSubmitting.value;
            return Material(
              color: submitting
                  ? AppColors.primaryBrand.withValues(alpha: 0.6)
                  : AppColors.primaryBrand,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: InkWell(
                onTap: submitting ? null : controller.submitCurrentAssignment,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (submitting)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                      else
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: AppColors.white,
                        ),
                      AppSpacing.h12,
                      Text(
                        submitting
                            ? 'Submitting...'
                            : (alreadySubmitted
                                  ? 'Resubmit Assignment'
                                  : 'Submit Assignment'),
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AttachmentPicker extends StatelessWidget {
  final Assignment assignment;
  final AssignmentsController controller;
  final String? newPath;

  const _AttachmentPicker({
    required this.assignment,
    required this.controller,
    required this.newPath,
  });

  @override
  Widget build(BuildContext context) {
    final newPath = this.newPath;
    final existingUrl = assignment.submissionAttachmentUrl;

    String? displayName;
    if (newPath != null) {
      displayName = newPath.split('/').last;
    } else if (existingUrl != null && existingUrl.isNotEmpty) {
      displayName = existingUrl.split('/').last;
    }

    return InkWell(
      onTap: controller.pickSubmissionAttachment,
      borderRadius: BorderRadius.circular(AppSpacing.s12),
      child: Container(
        padding: AppSpacing.all12,
        decoration: BoxDecoration(
          color: AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(AppSpacing.s12),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Icon(
              displayName != null
                  ? Icons.attach_file_rounded
                  : Icons.attach_file_outlined,
              size: 18,
              color: AppColors.primaryBrand,
            ),
            AppSpacing.h12,
            Expanded(
              child: Text(
                displayName ?? 'Attach a file (optional)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: displayName != null
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: displayName != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
            if (newPath != null)
              IconButton(
                onPressed: controller.removeNewSubmissionAttachment,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              )
            else
              Text(
                existingUrl != null && existingUrl.isNotEmpty
                    ? 'Replace'
                    : 'Add',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StaticButton extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final String label;

  const _StaticButton({
    required this.backgroundColor,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.white),
          AppSpacing.h12,
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingBanner extends StatelessWidget {
  final Assignment assignment;

  const _PendingBanner({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.notifications_active_outlined,
              size: 20,
              color: AppColors.bohoRed,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.studentAssignmentsTabPending,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bohoRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assignment.pendingNote ?? '',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.bohoRed,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  final Assignment assignment;

  const _CompletedBanner({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_rounded,
              size: 20,
              color: AppColors.successGreen,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  assignment.completedNote ?? '',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final num score;
  const _ResultCard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s24,
        horizontal: AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.warningAmber,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Well Done!',
            style: AppTextStyles.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You scored $score on this assignment.',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }
}

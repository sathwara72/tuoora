import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/student_bottom_nav.dart';
import 'package:tuoora/presentation/student/controllers/assignments_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_exams_controller.dart';
import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/presentation/student/models/student_exam_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

/// Merged "Tasks" tab — Homework and Exams side by side under one segmented
/// control, reusing [AssignmentsController] and [StudentExamsController]
/// directly rather than duplicating their loading/state logic.
class StudentTasksScreen extends GetView<AssignmentsController> {
  final bool showBottomNav;

  const StudentTasksScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<StudentExamsController>()) {
      Get.put(StudentExamsController());
    }
    final examsController = Get.find<StudentExamsController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StudentAppBar(title: AppStrings.homeTasksTitle, isRoot: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                0,
                AppSpacing.s16,
                AppSpacing.s12,
              ),
              child: Obx(
                () => _TopTabs(
                  activeIndex: controller.taskTopTab.value,
                  homeworkCount:
                      controller.pending.length + controller.completed.length,
                  examsCount:
                      examsController.upcoming.length +
                      examsController.results.length,
                  onChange: controller.selectTaskTopTab,
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                return controller.taskTopTab.value == 0
                    ? _HomeworkTab(controller: controller)
                    : _ExamsTab(controller: examsController);
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? const StudentBottomNav(currentIndex: 1)
          : null,
    );
  }
}

List<Widget> _interleave(Iterable<Widget> items, Widget separator) {
  final list = items.toList();
  if (list.length <= 1) return list;
  final out = <Widget>[];
  for (var i = 0; i < list.length; i++) {
    if (i > 0) out.add(separator);
    out.add(list[i]);
  }
  return out;
}

// ─────────────────────────────────────────────────────────────── Top tabs

class _TopTabs extends StatelessWidget {
  final int activeIndex;
  final int homeworkCount;
  final int examsCount;
  final ValueChanged<int> onChange;

  const _TopTabs({
    required this.activeIndex,
    required this.homeworkCount,
    required this.examsCount,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TopTabButton(
            icon: Icons.assignment_rounded,
            label: 'Homework ($homeworkCount)',
            isActive: activeIndex == 0,
            activeColor: AppColors.primaryBrand,
            onTap: () => onChange(0),
          ),
        ),
        AppSpacing.h10,
        Expanded(
          child: _TopTabButton(
            icon: Icons.event_note_rounded,
            label: 'Exams ($examsCount)',
            isActive: activeIndex == 1,
            activeColor: AppColors.violet,
            onTap: () => onChange(1),
          ),
        ),
      ],
    );
  }
}

class _TopTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _TopTabButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        decoration: BoxDecoration(
          color: isActive ? activeColor : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.white : AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppColors.white : AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── Homework tab

class _HomeworkTab extends StatelessWidget {
  final AssignmentsController controller;
  const _HomeworkTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryBrand,
      onRefresh: controller.loadAssignments,
      child: Obx(() {
        if (controller.isLoading.value) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 120),
              CommonLoading(color: AppColors.primaryBrand),
            ],
          );
        }

        final pending = controller.pending;
        final completed = controller.completed;

        if (pending.isEmpty && completed.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.x16,
            children: const [
              SizedBox(height: 40),
              AppEmptyView(
                icon: Icons.task_alt_rounded,
                title: 'No homework yet',
                message: 'New homework from your tutors will show up here.',
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.x16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s4),
              _ProgressRingCard(
                remaining: pending.length,
                total: pending.length + completed.length,
              ),
              const SizedBox(height: AppSpacing.s20),
              if (pending.isNotEmpty) ...[
                _ListSectionHeader(
                  title: 'Pending Homework',
                  count: pending.length,
                  accentColor: AppColors.primaryBrand,
                ),
                const SizedBox(height: AppSpacing.s12),
                ..._interleave(
                  pending.map(
                    (a) => _PendingHomeworkCard(
                      item: a,
                      onTap: () => controller.openAssignment(a),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ),
                const SizedBox(height: AppSpacing.s20),
              ],
              if (completed.isNotEmpty) ...[
                _ListSectionHeader(
                  title: 'Completed Homework',
                  count: completed.length,
                  accentColor: AppColors.successGreen,
                ),
                const SizedBox(height: AppSpacing.s12),
                ..._interleave(
                  completed.map(
                    (a) => _CompletedHomeworkCard(
                      item: a,
                      onTap: () => controller.openAssignment(a),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ),
              ],
              const SizedBox(height: AppSpacing.s8),
            ],
          ),
        );
      }),
    );
  }
}

class _ProgressRingCard extends StatelessWidget {
  final int remaining;
  final int total;

  const _ProgressRingCard({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (total - remaining) / total;

    late final String title;
    late final String subtitle;
    if (total == 0) {
      title = 'No Homework Yet';
      subtitle = 'New homework will appear here.';
    } else if (remaining == 0) {
      title = 'All Caught Up!';
      subtitle = "You've completed all your homework.";
    } else {
      title = 'Stay on Track!';
      subtitle = 'Complete your pending homework.';
    }

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: total == 0 ? 0 : progress,
                    strokeWidth: 7,
                    backgroundColor: AppColors.primaryBrandLight,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.primaryBrand,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$remaining/$total',
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pending',
                      style: AppTextStyles.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color accentColor;

  const _ListSectionHeader({
    required this.title,
    required this.count,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AppSpacing.h8,
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _PendingHomeworkCard extends StatelessWidget {
  final Assignment item;
  final VoidCallback? onTap;

  const _PendingHomeworkCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dimmed = item.isOverdue;
    final card = Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSpacing.s40,
                    height: AppSpacing.s40,
                    decoration: BoxDecoration(
                      color: item.iconBg,
                      borderRadius: BorderRadius.circular(AppSpacing.s12),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 20),
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subjectLabel,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h8,
                  _DueInPill(item: item),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.attach_file_rounded,
                    label: item.attachments.length == 1
                        ? '1 File'
                        : '${item.attachments.length} Files',
                  ),
                  AppSpacing.h12,
                  _MetaChip(
                    icon: Icons.checklist_rounded,
                    label: item.instructionLines.length == 1
                        ? '1 Instruction'
                        : '${item.instructionLines.length} Instructions',
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand,
                      borderRadius: BorderRadius.circular(AppSpacing.s10),
                    ),
                    child: Text(
                      'View',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return dimmed ? Opacity(opacity: 0.7, child: card) : card;
  }
}

class _CompletedHomeworkCard extends StatelessWidget {
  final Assignment item;
  final VoidCallback? onTap;

  const _CompletedHomeworkCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSpacing.s40,
                    height: AppSpacing.s40,
                    decoration: BoxDecoration(
                      color: item.iconBg,
                      borderRadius: BorderRadius.circular(AppSpacing.s12),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 20),
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subjectLabel,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h8,
                  if (item.score != null)
                    _ScoreChip(score: item.score!)
                  else
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  _MetaChip(
                    icon: Icons.attach_file_rounded,
                    label: item.attachments.length == 1
                        ? '1 File'
                        : '${item.attachments.length} Files',
                  ),
                  AppSpacing.h12,
                  _MetaChip(
                    icon: Icons.checklist_rounded,
                    label: item.instructionLines.length == 1
                        ? '1 Instruction'
                        : '${item.instructionLines.length} Instructions',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final num score;
  const _ScoreChip({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(AppSpacing.s8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_rounded,
            size: 12,
            color: AppColors.successGreen,
          ),
          const SizedBox(width: 4),
          Text(
            'Score $score',
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _DueInPill extends StatelessWidget {
  final Assignment item;

  const _DueInPill({required this.item});

  @override
  Widget build(BuildContext context) {
    final label = _dueInLabel(item);
    final dateLabel = _dueDateLabel(item);
    final bg = item.isOverdue ? AppColors.errorBg : AppColors.primaryBrandLight;
    final fg = item.isOverdue ? AppColors.bohoRed : AppColors.primaryBrand;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.s8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          if (dateLabel != null) ...[
            const SizedBox(height: 1),
            Text(
              dateLabel,
              style: AppTextStyles.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: fg.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _dueInLabel(Assignment item) {
    final diff = _diffDays(item);
    if (diff == null) return item.dueLabel;
    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due in 1 day';
    return 'Due in $diff days';
  }

  static String? _dueDateLabel(Assignment item) {
    final raw = item.dueDateFullText;
    if (raw == null || raw.isEmpty) return null;
    try {
      final due = DateTime.parse(raw);
      return DateFormat('d MMM yyyy').format(due);
    } catch (_) {
      return null;
    }
  }

  static int? _diffDays(Assignment item) {
    final raw = item.dueDateFullText;
    if (raw == null || raw.isEmpty) return null;
    try {
      final due = DateTime.parse(raw);
      final today = DateTime.now();
      final todayD = DateTime(today.year, today.month, today.day);
      final dueD = DateTime(due.year, due.month, due.day);
      return dueD.difference(todayD).inDays;
    } catch (_) {
      return null;
    }
  }
}

// ────────────────────────────────────────────────────────────────ExamsTab

class _ExamsTab extends StatelessWidget {
  final StudentExamsController controller;
  const _ExamsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.violet,
      onRefresh: controller.loadExams,
      child: Obx(() {
        if (controller.isLoading.value) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 120),
              CommonLoading(color: AppColors.violet),
            ],
          );
        }

        final upcoming = controller.upcoming;
        final results = controller.results;

        if (upcoming.isEmpty && results.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.x16,
            children: const [
              SizedBox(height: 40),
              AppEmptyView(
                icon: Icons.event_note_outlined,
                title: 'No exams yet',
                message: 'Exams scheduled by your institute will show up here.',
              ),
            ],
          );
        }

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.x16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.s4),
              if (upcoming.isNotEmpty) ...[
                _ListSectionHeader(
                  title: 'Upcoming Exams',
                  count: upcoming.length,
                  accentColor: AppColors.violet,
                ),
                const SizedBox(height: AppSpacing.s12),
                ..._interleave(
                  upcoming.map(
                    (e) => _UpcomingExamCard(
                      exam: e,
                      onTap: () => controller.openExam(e),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ),
                const SizedBox(height: AppSpacing.s20),
              ],
              if (results.isNotEmpty) ...[
                _ListSectionHeader(
                  title: 'Completed Exams',
                  count: results.length,
                  accentColor: AppColors.successGreen,
                ),
                const SizedBox(height: AppSpacing.s12),
                ..._interleave(
                  results.map(
                    (e) => _CompletedExamCard(
                      exam: e,
                      onTap: () => controller.openExam(e),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ),
              ],
              const SizedBox(height: AppSpacing.s8),
            ],
          ),
        );
      }),
    );
  }
}

class _UpcomingExamCard extends StatelessWidget {
  final StudentExamListItem exam;
  final VoidCallback? onTap;

  const _UpcomingExamCard({required this.exam, this.onTap});

  @override
  Widget build(BuildContext context) {
    final metaParts = <String>[
      exam.examTypeLabel,
      if ((exam.formattedDate ?? '').isNotEmpty) exam.formattedDate!,
    ];

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.s40,
                height: AppSpacing.s40,
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.s12),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.violet,
                  size: 20,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metaParts.join('  •  '),
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.h8,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.s8),
                ),
                child: Text(
                  'Upcoming',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedExamCard extends StatelessWidget {
  final StudentExamListItem exam;
  final VoidCallback? onTap;

  const _CompletedExamCard({required this.exam, this.onTap});

  @override
  Widget build(BuildContext context) {
    final metaParts = <String>[
      exam.examTypeLabel,
      if ((exam.formattedDate ?? '').isNotEmpty) exam.formattedDate!,
    ];

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.s40,
                height: AppSpacing.s40,
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.s12),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.violet,
                  size: 20,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metaParts.join('  •  '),
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.h8,
              _ExamResultBadge(exam: exam),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamResultBadge extends StatelessWidget {
  final StudentExamListItem exam;
  const _ExamResultBadge({required this.exam});

  @override
  Widget build(BuildContext context) {
    if (exam.isAbsent) {
      return _pill('Absent', AppColors.errorBg, AppColors.bohoRed);
    }
    if (exam.marksObtained == null) {
      return _pill('Pending Result', AppColors.fieldBg, AppColors.textTertiary);
    }
    final pass = exam.isPass ?? true;
    final bg = pass ? AppColors.successBg : AppColors.errorBg;
    final fg = pass ? AppColors.successGreen : AppColors.bohoRed;
    final marks =
        '${_trimZero(exam.marksObtained!)}/${_trimZero(exam.totalMarks)}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.s8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            marks,
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          if (exam.percentage != null) ...[
            const SizedBox(height: 1),
            Text(
              '${exam.percentage!.round()}%',
              style: AppTextStyles.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: fg.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(String label, Color bg, Color fg) {
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
        label,
        style: AppTextStyles.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  static String _trimZero(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

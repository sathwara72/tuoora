import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/student_bottom_nav.dart';
import 'package:tuoora/presentation/student/controllers/student_controller.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';
import 'package:tuoora/presentation/student/widgets/student_section_header.dart';
import 'package:tuoora/presentation/student/controllers/assignments_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_dashboard_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_exams_controller.dart';
import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/presentation/student/models/student_exam_model.dart';
import 'package:tuoora/presentation/student/models/student_timetable_model.dart';
import 'package:tuoora/data/models/student_resource_model.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends GetView<StudentDashboardController> {
  final bool showBottomNav;
  const StudentDashboard({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CommonLoading(color: AppColors.primaryBrand);
          }
          final data = controller.dashboardData.value;
          if (data == null) {
            return Column(
              children: [
                StudentAppBar(
                  isRoot: true,
                  titleWidget: _GreetingTitle(
                    firstName: controller.studentFirstName,
                    initials: controller.studentInitials,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryBrand,
                    onRefresh: controller.fetchDashboard,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        AppEmptyView(
                          icon: Icons.dashboard_outlined,
                          title: AppStrings.nothingToShowYet,
                          message:
                              'We couldn\'t load your dashboard right now. Pull to refresh.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final assignmentItems = controller.dashboardAssignments;
          final examItems = controller.dashboardUpcomingExams;
          final classes = controller.classesForSelectedDate;

          return Column(
            children: [
              StudentAppBar(
                isRoot: true,
                titleWidget: _GreetingTitle(
                  firstName: controller.studentFirstName,
                  initials: controller.studentInitials,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryBrand,
                  onRefresh: controller.fetchDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.screenPaddingTop,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWeekCalendar(),
                        const SizedBox(height: AppSpacing.s12),
                        if (classes.isEmpty)
                          const AppEmptyView(
                            icon: Icons.event_busy_outlined,
                            title: 'No Classes',
                            message: 'No classes scheduled for this date.',
                          )
                        else
                          ...classes.map((cls) => _buildClassCard(cls)),
                        const SizedBox(height: AppSpacing.s24),
                        if (assignmentItems.isNotEmpty) ...[
                          StudentSectionHeader(
                            title: AppStrings.assignments,
                            showSeeAll: true,
                            onActionTap: _openAssignmentsTab,
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          ...assignmentItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s8,
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    _openAssignmentDetail(item.assignment),
                                child: _AssignmentTile(item: item),
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.s16),
                        ],
                        if (examItems.isNotEmpty) ...[
                          StudentSectionHeader(
                            title: AppStrings.upcomingExams,
                            showSeeAll: true,
                            onActionTap: () =>
                                Get.toNamed(AppRoutes.studentExams),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          ...examItems.map((exam) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s8,
                              ),
                              child: GestureDetector(
                                onTap: () => _openExamDetail(exam),
                                child: _ExamTile(exam: exam),
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.s16),
                        ],
                        const StudentSectionHeader(
                          title: AppStrings.todaySAttendance,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        GestureDetector(
                          onTap: _openAttendanceTab,
                          child: _AttendanceCard(
                            status: data.todayAttendance.status,
                            detail: data.todayAttendance.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        if (data.studyMaterials.isNotEmpty) ...[
                          StudentSectionHeader(
                            title: AppStrings.studyMaterialThisWeek,
                            showSeeAll: true,
                            onActionTap: () =>
                                Get.toNamed(AppRoutes.studentStudyMaterial),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          ...data.studyMaterials.take(2).map((material) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s8,
                              ),
                              child: GestureDetector(
                                onTap: () => _openStudyMaterialDetail(material),
                                child: _StudyMaterialTile(
                                  title: material.title,
                                  meta:
                                      "${material.subject} • ${material.timeLabel}",
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: AppSpacing.s16),
                        ],
                        if (data.pendingFees.isNotEmpty) ...[
                          StudentSectionHeader(
                            title: AppStrings.pendingFees,
                            actionLabel: 'History',
                            onActionTap: _openFeesTab,
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          ...data.pendingFees.take(2).map((fee) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s8,
                              ),
                              child: GestureDetector(
                                onTap: _openFeesTab,
                                child: _PendingFeeTile(
                                  date: fee.monthYear,
                                  dueAmount: fee.dueAmount.toString(),
                                  status: fee.status,
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: showBottomNav
          ? const StudentBottomNav(currentIndex: 0)
          : null,
    );
  }

  Widget _buildWeekCalendar() {
    final now = DateTime.now();
    final dates = List.generate(7, (index) => now.add(Duration(days: index)));

    return Row(
      children: List.generate(dates.length, (index) {
        final date = dates[index];
        final isSelected = controller.selectedDate.value.year == date.year &&
            controller.selectedDate.value.month == date.month &&
            controller.selectedDate.value.day == date.day;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < dates.length - 1 ? 6 : 0,
            ),
            child: GestureDetector(
              onTap: () => controller.selectDate(date),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBrand : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBrand : AppColors.borderGrey,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBrand.withValues(alpha: 0.28),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        DateFormat('E').format(date).toUpperCase(),
                        maxLines: 1,
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.white : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        date.day.toString(),
                        maxLines: 1,
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildClassCard(StudentTimetableSlot cls) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 72,
                decoration: const BoxDecoration(color: AppColors.primaryBrand),
                padding: AppSpacing.cardPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cls.formattedStartTime ?? cls.startTime,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.subject,
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (cls.staffName != null && cls.staffName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Teacher: ${cls.staffName}',
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (cls.roomNo != null && cls.roomNo!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Room: ${cls.roomNo}',
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _openAssignmentsTab() {
    if (Get.isRegistered<StudentController>()) {
      Get.find<StudentController>().changePage(1);
    } else {
      Get.toNamed(AppRoutes.studentHomework);
    }
  }

  static void _openAssignmentDetail(Assignment assignment) {
    if (!Get.isRegistered<AssignmentsController>()) {
      Get.put(AssignmentsController());
    }
    final ctrl = Get.find<AssignmentsController>();
    ctrl.openAssignment(assignment);
  }

  static void _openExamDetail(StudentExamListItem exam) {
    if (!Get.isRegistered<StudentExamsController>()) {
      Get.put(StudentExamsController());
    }
    Get.find<StudentExamsController>().openExam(exam);
  }

  static void _openAttendanceTab() {
    if (Get.isRegistered<StudentController>()) {
      Get.find<StudentController>().changePage(3);
    }
  }

  static void _openStudyMaterialDetail(StudentResourceModel material) {
    Get.toNamed(AppRoutes.studentStudyMaterialDetail, arguments: material);
  }

  static void _openFeesTab() {
    if (Get.isRegistered<StudentController>()) {
      Get.find<StudentController>().changePage(2);
    }
  }
}

class _GreetingTitle extends StatelessWidget {
  final String firstName;
  final String initials;
  const _GreetingTitle({required this.firstName, required this.initials});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (Get.isRegistered<StudentController>()) {
          Get.find<StudentController>().changePage(4);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSpacing.s18,
            backgroundColor: AppColors.primaryBrandLight,
            child: Text(
              initials,
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBrand,
              ),
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Text(
              'Hi, $firstName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _AssignmentTile extends StatelessWidget {
  final DashboardAssignmentDisplay item;
  const _AssignmentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final pillBg = item.isSubmitted
        ? AppColors.successGreen
        : AppColors.bohoRed;
    const pillText = AppColors.white;

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
          Container(
            width: AppSpacing.s40,
            height: AppSpacing.s40,
            decoration: BoxDecoration(
              color: AppColors.primaryBrandLight,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppColors.primaryBrand,
              size: 20,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.dueLabel.isEmpty
                      ? item.subject
                      : '${item.subject}  •  ${item.dueLabel}',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
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
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s4,
            ),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Text(
              item.status,
              style: AppTextStyles.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: pillText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  final StudentExamListItem exam;
  const _ExamTile({required this.exam});

  @override
  Widget build(BuildContext context) {
    final metaParts = <String>[
      if ((exam.subject ?? '').isNotEmpty) exam.subject!,
      exam.examTypeLabel,
      if ((exam.formattedDate ?? '').isNotEmpty) exam.formattedDate!,
    ];

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
          Container(
            width: AppSpacing.s40,
            height: AppSpacing.s40,
            decoration: BoxDecoration(
              color: AppColors.primaryBrandLight,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: AppColors.primaryBrand,
              size: 20,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  metaParts.join('  •  '),
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final String status;
  final String detail;
  const _AttendanceCard({required this.status, required this.detail});

  @override
  Widget build(BuildContext context) {
    final isNotMarked = status == 'Absent';
    final bgColor = isNotMarked ? AppColors.primaryBrand : AppColors.successBg;
    final iconColor = isNotMarked ? AppColors.white : AppColors.successGreen;
    final textColor = isNotMarked
        ? AppColors.textPrimary
        : AppColors.successGreen;
    final icon = isNotMarked ? Icons.close_rounded : Icons.check_rounded;

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
          Container(
            width: AppSpacing.s40,
            height: AppSpacing.s40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _StudyMaterialTile extends StatelessWidget {
  final String title;
  final String meta;
  const _StudyMaterialTile({required this.title, required this.meta});

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
          Container(
            width: AppSpacing.s40,
            height: AppSpacing.s40,
            decoration: BoxDecoration(
              color: AppColors.primaryBrandLight,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              color: AppColors.primaryBrand,
              size: 20,
            ),
          ),
          AppSpacing.h12,
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _PendingFeeTile extends StatelessWidget {
  final String date;
  final String dueAmount;
  final String status;

  const _PendingFeeTile({
    required this.date,
    required this.dueAmount,
    required this.status,
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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.s40,
            height: AppSpacing.s40,
            decoration: BoxDecoration(
              color: AppColors.primaryBrandLight,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Icon(
              Icons.currency_rupee_rounded,
              color: AppColors.primaryBrand,
              size: 20,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$dueAmount • $status",
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.h8,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s4,
            ),
            decoration: BoxDecoration(
              color: AppColors.bohoRed,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Text(
              AppStrings.studentAssignmentsTabPending,
              style: AppTextStyles.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/utils/pull_refresh.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/student_bottom_nav.dart';
import 'package:tuoora/presentation/student/controllers/student_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_profile_controller.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';
import 'package:tuoora/presentation/student/controllers/assignments_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_dashboard_controller.dart';
import 'package:tuoora/presentation/student/models/assignment_model.dart';
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
          if (controller.isLoading.value && !PullRefresh.active.value) {
            return const CommonLoading(color: AppColors.primaryBrand);
          }
          final data = controller.dashboardData.value;
          if (data == null) {
            return Column(
              children: [
                StudentAppBar(
                  isRoot: true,
                  titleWidget: _GreetingHeader(
                    firstName: controller.studentFirstName,
                    initials: controller.studentInitials,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryBrand,
                    onRefresh: () => PullRefresh.run(controller.fetchDashboard),
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
          final classes = controller.classesForSelectedDate;
          final selectedDate = controller.selectedDate.value;
          final classRows = _resolveClassRows(classes, selectedDate);

          return Column(
            children: [
              StudentAppBar(
                isRoot: true,
                titleWidget: _GreetingHeader(
                  firstName: controller.studentFirstName,
                  initials: controller.studentInitials,
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryBrand,
                  onRefresh: () => PullRefresh.run(controller.fetchDashboard),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.screenPaddingTop,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildWeekCalendar(),
                        const SizedBox(height: AppSpacing.s16),
                        if (classRows.isEmpty)
                          const AppEmptyView(
                            icon: Icons.event_busy_outlined,
                            title: 'No Classes',
                            message: 'No classes scheduled for this date.',
                          )
                        else
                          ...classRows.map(
                            (row) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s10,
                              ),
                              child: _ClassListItem(data: row),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.s6),
                        _AttendanceHeroCard(
                          status: data.todayAttendance.status,
                          detail: data.todayAttendance.text,
                          onTap: _openAttendanceTab,
                        ),
                        if (assignmentItems.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s16),
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
                        ],
                        const SizedBox(height: AppSpacing.s16),
                        _buildQuickActionsGrid(),
                        const SizedBox(height: AppSpacing.s20),
                        if (data.studyMaterials.isNotEmpty ||
                            data.pendingFees.isNotEmpty) ...[
                          _buildSummaryTilesRow(data),
                          const SizedBox(height: AppSpacing.s16),
                        ],
                        if (data.studyMaterials.isNotEmpty) ...[
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
        final isSelected =
            controller.selectedDate.value.year == date.year &&
            controller.selectedDate.value.month == date.month &&
            controller.selectedDate.value.day == date.day;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < dates.length - 1 ? 6 : 0),
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
                    color: isSelected
                        ? AppColors.primaryBrand
                        : AppColors.borderGrey,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBrand.withValues(
                              alpha: 0.28,
                            ),
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
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textTertiary,
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
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
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

  Widget _buildQuickActionsGrid() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionItem(
            icon: Icons.assignment_rounded,
            label: AppStrings.homeTasksTitle,
            outerBg: AppColors.primaryBrandLight,
            accentColor: AppColors.primaryBrand,
            badgeCount: controller.pendingAssignmentsCount,
            onTap: _openAssignmentsTab,
          ),
        ),
        AppSpacing.h8,
        Expanded(
          child: _QuickActionItem(
            icon: Icons.calendar_month_rounded,
            label: AppStrings.labelTimetable,
            outerBg: AppColors.violetSoft,
            accentColor: AppColors.violet,
            onTap: () => Get.toNamed(AppRoutes.studentTimetable),
          ),
        ),
        AppSpacing.h8,
        Expanded(
          child: _QuickActionItem(
            icon: Icons.check_circle_rounded,
            label: AppStrings.instAttendanceTitle,
            outerBg: AppColors.successBg,
            accentColor: AppColors.successGreen,
            onTap: _openAttendanceTab,
          ),
        ),
        AppSpacing.h8,
        Expanded(
          child: _QuickActionItem(
            icon: Icons.currency_rupee_rounded,
            label: AppStrings.instNavFees,
            outerBg: AppColors.studentUpdateIconBg,
            accentColor: AppColors.studentUpdateIconColor,
            onTap: _openFeesTab,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTilesRow(dynamic data) {
    final hasMaterial = data.studyMaterials.isNotEmpty;
    final hasDueFee = data.pendingFees.isNotEmpty;
    // stretch needs a bounded height; inside the scroll view it is not.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasMaterial)
            Expanded(
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.studentStudyMaterial),
                child: _SummaryTile(
                  icon: Icons.menu_book_rounded,
                  iconBg: AppColors.violetSoft,
                  iconColor: AppColors.violet,
                  title: AppStrings.homeStudyMaterialCardTitle,
                  subtitle: data.studyMaterials.first.title,
                ),
              ),
            ),
          if (hasMaterial && hasDueFee) AppSpacing.h12,
          if (hasDueFee)
            Expanded(
              child: GestureDetector(
                onTap: _openFeesTab,
                child: _SummaryTile(
                  icon: Icons.currency_rupee_rounded,
                  iconBg: AppColors.successBg,
                  iconColor: AppColors.successGreen,
                  title: AppStrings.homeFeeReminderCardTitle,
                  subtitle: 'Your ₹${data.dueFees} fee is pending.',
                ),
              ),
            ),
        ],
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

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

enum _ClassStatus { ongoing, next, none }

class _ClassRowData {
  final StudentTimetableSlot slot;
  final _ClassStatus status;
  const _ClassRowData(this.slot, this.status);
}

/// Tags each of today's slots as "ongoing" (now falls within its time
/// window), the single "next" one still to come, or plain — by comparing
/// real start/end times against the clock. Non-today selections never get a
/// status, since "ongoing"/"next" only means something for today.
List<_ClassRowData> _resolveClassRows(
  List<StudentTimetableSlot> slots,
  DateTime selectedDate,
) {
  final now = DateTime.now();
  if (!_isSameDay(selectedDate, now)) {
    return slots.map((s) => _ClassRowData(s, _ClassStatus.none)).toList();
  }

  StudentTimetableSlot? ongoing;
  StudentTimetableSlot? next;
  for (final s in slots) {
    final start =
        _parseClockTime(s.formattedStartTime, now) ??
        _parseClockTime(s.startTime, now);
    final end = _parseClockTime(s.formattedEndTime, now);
    if (start != null && end != null) {
      if (!now.isBefore(start) && now.isBefore(end)) {
        ongoing = s;
      } else if (next == null && now.isBefore(start)) {
        next = s;
      }
    }
  }

  return slots.map((s) {
    if (ongoing != null && s.id == ongoing.id) {
      return _ClassRowData(s, _ClassStatus.ongoing);
    }
    if (next != null && s.id == next.id) {
      return _ClassRowData(s, _ClassStatus.next);
    }
    return _ClassRowData(s, _ClassStatus.none);
  }).toList();
}

class _SubjectStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  const _SubjectStyle(this.bg, this.fg, this.icon);
}

/// Picks an icon + color for a subject from real subject text — keyword
/// matches for common subjects, falling back to a stable hash-based pick
/// from a small palette so different subjects still look visually distinct.
_SubjectStyle _subjectStyle(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('science') ||
      s.contains('chemistry') ||
      s.contains('physic')) {
    return const _SubjectStyle(
      AppColors.violetSoft,
      AppColors.violet,
      Icons.science_rounded,
    );
  }
  if (s.contains('math')) {
    return const _SubjectStyle(
      AppColors.studentUpdateIconBg,
      AppColors.studentUpdateIconColor,
      Icons.calculate_rounded,
    );
  }
  if (s.contains('english') || s.contains('literature')) {
    return const _SubjectStyle(
      AppColors.primaryBrandLight,
      AppColors.primaryBrand,
      Icons.menu_book_rounded,
    );
  }
  if (s.contains('computer') || s.contains(' it')) {
    return const _SubjectStyle(
      AppColors.subjectPhysicsSoft,
      AppColors.subjectPhysics,
      Icons.computer_rounded,
    );
  }
  if (s.contains('history') || s.contains('social') || s.contains('geograph')) {
    return const _SubjectStyle(
      AppColors.successBg,
      AppColors.successGreen,
      Icons.public_rounded,
    );
  }
  if (s.contains('art') || s.contains('draw')) {
    return const _SubjectStyle(
      AppColors.warningBg,
      AppColors.warningAmber,
      Icons.palette_rounded,
    );
  }
  if (s.contains('sport') || s.contains('physical') || s.contains(' pe')) {
    return const _SubjectStyle(
      AppColors.errorBg,
      AppColors.bohoRed,
      Icons.sports_soccer_rounded,
    );
  }
  const palette = [
    _SubjectStyle(
      AppColors.primaryBrandLight,
      AppColors.primaryBrand,
      Icons.menu_book_rounded,
    ),
    _SubjectStyle(
      AppColors.violetSoft,
      AppColors.violet,
      Icons.auto_stories_rounded,
    ),
    _SubjectStyle(
      AppColors.studentUpdateIconBg,
      AppColors.studentUpdateIconColor,
      Icons.school_rounded,
    ),
    _SubjectStyle(
      AppColors.successBg,
      AppColors.successGreen,
      Icons.menu_book_rounded,
    ),
  ];
  return palette[subject.hashCode.abs() % palette.length];
}

DateTime? _parseClockTime(String? raw, DateTime referenceDate) {
  if (raw == null || raw.trim().isEmpty) return null;
  final s = raw.trim();
  for (final pattern in ['h:mm a', 'HH:mm:ss', 'HH:mm']) {
    try {
      final t = DateFormat(pattern).parse(s);
      return DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
        t.hour,
        t.minute,
      );
    } catch (_) {}
  }
  return null;
}

class _GreetingHeader extends StatelessWidget {
  final String firstName;
  final String initials;
  const _GreetingHeader({required this.firstName, required this.initials});

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
          _buildAvatar(),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hi, $firstName 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.homeGreetingSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Obx(() {
      String localPath = '';
      String remoteUrl = '';

      if (Get.isRegistered<StudentProfileController>()) {
        final profileCtrl = Get.find<StudentProfileController>();
        localPath = profileCtrl.profileImagePath.value;
        remoteUrl = profileCtrl.profileData.value?.header.avatarUrl ?? '';
      }

      if (remoteUrl.isEmpty && Get.isRegistered<StudentDashboardController>()) {
        final dashCtrl = Get.find<StudentDashboardController>();
        remoteUrl = dashCtrl.userAvatarUrl.value;
        if (remoteUrl.isEmpty) {
          remoteUrl = dashCtrl.dashboardData.value?.avatarUrl ?? '';
        }
      }

      if (remoteUrl.isEmpty && Get.isRegistered<AuthService>()) {
        remoteUrl = Get.find<AuthService>().currentUser?.profileImage ?? '';
      }

      final hasLocal = localPath.isNotEmpty && File(localPath).existsSync();
      final hasRemote = remoteUrl.isNotEmpty && remoteUrl.startsWith('http');

      Widget avatarChild;
      if (hasLocal) {
        avatarChild = Image.file(
          File(localPath),
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          errorBuilder: (_, _, _) => _initialsWidget(),
        );
      } else if (hasRemote) {
        avatarChild = AppNetworkImage(
          url: remoteUrl,
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          placeholder: _initialsWidget(),
          errorWidget: _initialsWidget(),
        );
      } else {
        avatarChild = _initialsWidget();
      }

      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryBrandLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBrand.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: avatarChild,
          ),
        ),
      );
    });
  }

  Widget _initialsWidget() {
    return Container(
      color: AppColors.primaryBrandLight,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBrand,
        ),
      ),
    );
  }
}

class _ClassListItem extends StatelessWidget {
  final _ClassRowData data;

  const _ClassListItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final slot = data.slot;
    final isOngoing = data.status == _ClassStatus.ongoing;
    final style = _subjectStyle(slot.subject);
    final startTime = slot.formattedStartTime ?? slot.startTime;
    final endTime = slot.formattedEndTime;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.studentTimetable),
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          decoration: BoxDecoration(
            color: isOngoing ? AppColors.primaryBrandLight : AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // stretch needs a bounded height; the list scrolls, so it has none.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isOngoing)
                  Container(width: 4, color: AppColors.primaryBrand),
                Expanded(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 58,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                startTime,
                                style: AppTextStyles.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (endTime != null && endTime.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  endTime,
                                  style: AppTextStyles.outfit(
                                    fontSize: 11,
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
                        AppSpacing.h10,
                        Container(
                          width: AppSpacing.s44,
                          height: AppSpacing.s44,
                          decoration: BoxDecoration(
                            color: style.bg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(style.icon, color: style.fg, size: 20),
                        ),
                        AppSpacing.h12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                slot.subject,
                                style: AppTextStyles.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (slot.staffName != null &&
                                  slot.staffName!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Teacher: ${slot.staffName}',
                                  style: AppTextStyles.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (slot.roomNo != null &&
                                  slot.roomNo!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 12,
                                      color: AppColors.textTertiary,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Room ${slot.roomNo}',
                                      style: AppTextStyles.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textTertiary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        AppSpacing.h8,
                        if (data.status != _ClassStatus.none) ...[
                          _ClassStatusPill(status: data.status),
                          const SizedBox(width: 4),
                        ],
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassStatusPill extends StatelessWidget {
  final _ClassStatus status;
  const _ClassStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isOngoing = status == _ClassStatus.ongoing;
    final bg = isOngoing ? AppColors.white : AppColors.studentUpdateIconBg;
    final fg = isOngoing
        ? AppColors.primaryBrand
        : AppColors.studentUpdateIconColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOngoing) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            isOngoing ? 'Ongoing' : 'Next',
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color outerBg;
  final Color accentColor;
  final VoidCallback onTap;
  final int badgeCount;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.outerBg,
    required this.accentColor,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
        decoration: BoxDecoration(
          color: outerBg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: AppSpacing.s40,
                  height: AppSpacing.s40,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(AppSpacing.s12),
                  ),
                  child: Icon(icon, color: AppColors.white, size: 20),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bohoRed,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: AppTextStyles.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _SummaryTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: iconColor, size: 18),
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
    final pillBg = item.isSubmitted ? AppColors.successBg : AppColors.errorBg;
    final pillFg = item.isSubmitted
        ? AppColors.successGreen
        : AppColors.bohoRed;

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
                color: pillFg,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _AttendanceHeroCard extends StatelessWidget {
  final String status;
  final String detail;
  final VoidCallback onTap;

  const _AttendanceHeroCard({
    required this.status,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color statusColor;
    late final IconData icon;
    switch (status) {
      case 'Present':
        bg = AppColors.successBg;
        statusColor = AppColors.successGreen;
        icon = Icons.check_circle_rounded;
        break;
      case 'Absent':
        bg = AppColors.errorBg;
        statusColor = AppColors.bohoRed;
        icon = Icons.cancel_rounded;
        break;
      case 'Late':
        bg = AppColors.warningBg;
        statusColor = AppColors.warningAmber;
        icon = Icons.schedule_rounded;
        break;
      default:
        bg = AppColors.primaryBrandLight;
        statusColor = AppColors.orangeTag;
        icon = Icons.schedule_outlined;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(color: bg),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -16,
                bottom: -18,
                child: Icon(
                  Icons.apartment_rounded,
                  size: 84,
                  color: statusColor.withValues(alpha: 0.12),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: statusColor, size: 24),
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.homeTodaysAttendance,
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status,
                          style: AppTextStyles.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detail,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: statusColor,
                    size: 20,
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

import 'dart:math' as math;
import 'dart:ui';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/student_bottom_nav.dart';
import 'package:tuoora/presentation/student/controllers/attendance_history_controller.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';
import 'package:tuoora/presentation/student/widgets/student_section_header.dart';
import 'package:shimmer/shimmer.dart';

class AttendanceScreen extends GetView<AttendanceHistoryController> {
  final bool showBottomNav;
  const AttendanceScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const StudentAppBar(
              title: 'Attendance',
              isRoot: true,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchAttendance,
                color: AppColors.primaryBrand,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.screenPaddingTop,
                  child: Obx(() {
                    if (!controller.isLoading.value &&
                        controller.attendanceData.value == null) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: AppEmptyView(
                          icon: Icons.event_busy_outlined,
                          title: AppStrings.noAttendanceRecords,
                          message:
                              'Your attendance will appear here once your institute starts marking it.',
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: AppSpacing.s20),
                        _buildMonthCard(),
                        const SizedBox(height: AppSpacing.s20),
                        StudentSectionHeader(title: AppStrings.monthlySummary),
                        const SizedBox(height: AppSpacing.s12),
                        _buildSummaryCard(),
                        const SizedBox(height: AppSpacing.s8),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? const StudentBottomNav(currentIndex: 3)
          : null,
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBrandLight, AppColors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.4)),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildTodayCardShimmer();
        }

        final data = controller.attendanceData.value?.today;
        if (data == null) return const SizedBox();

        final todayLabel = DateFormat('d MMM yyyy').format(DateTime.now());
        final statusLower = data.status.trim().toLowerCase();

        final Color statusBg;
        final Color statusFg;
        final IconData statusIcon;
        final Border? statusBorder;

        if (statusLower.contains('present') || statusLower == 'p') {
          statusBg = AppColors.successBg;
          statusFg = AppColors.greenText;
          statusIcon = Icons.check_circle_rounded;
          statusBorder = null;
        } else if (statusLower.contains('absent') || statusLower == 'a') {
          statusBg = AppColors.errorBg;
          statusFg = AppColors.bohoRed;
          statusIcon = Icons.cancel_rounded;
          statusBorder = null;
        } else if (statusLower.contains('holiday') || statusLower == 'h') {
          statusBg = AppColors.warningBg;
          statusFg = AppColors.warningAmber;
          statusIcon = Icons.calendar_month_rounded;
          statusBorder = null;
        } else {
          statusBg = AppColors.fieldBg;
          statusFg = AppColors.textSecondary;
          statusIcon = Icons.schedule_rounded;
          statusBorder = Border.all(color: AppColors.borderGrey);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBrand,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Today, $todayLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: statusBorder,
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusFg, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          data.status,
                          style: AppTextStyles.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: statusFg,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.text,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMonthCard() {
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
        children: [
          _buildMonthHeader(),
          const SizedBox(height: AppSpacing.s16),
          _buildGoToTodayButton(),
          const SizedBox(height: AppSpacing.s16),
          _buildCalendarGrid(),
          const SizedBox(height: AppSpacing.s24),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Prev arrow disables once the user reaches the batch-assignment
        // month — months before they enrolled have no attendance to show.
        Obx(
          () => _buildCircleNavButton(
            Icons.chevron_left,
            controller.prevMonth,
            enabled: controller.canGoPrev,
          ),
        ),
        Obx(
          () => Text(
            '${controller.currentMonthName} ${controller.currentYear}',
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // Next arrow disables itself when the user is already on the
        // current month — there's no future-month attendance to view.
        Obx(
          () => _buildCircleNavButton(
            Icons.chevron_right,
            controller.nextMonth,
            enabled: controller.canGoNext,
          ),
        ),
      ],
    );
  }

  Widget _buildCircleNavButton(
    IconData icon,
    VoidCallback onTap, {
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: AppSpacing.s36,
        height: AppSpacing.s36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryBrand
              : AppColors.primaryBrand.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Icon(icon, color: AppColors.white, size: 24),
      ),
    );
  }

  Widget _buildGoToTodayButton() {
    return GestureDetector(
      onTap: controller.goToToday,
      child: CustomPaint(
        painter: _DashedRectPainter(color: AppColors.orangeTag),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s10,
            horizontal: AppSpacing.s12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.radio_button_checked,
                    size: 16,
                    color: AppColors.orangeTag,
                  ),
                  AppSpacing.h8,
                  Obx(() {
                    final data = controller.attendanceData.value;
                    final todayStr = data?.calendar.todayLabel ?? 'TODAY';
                    return Text(
                      todayStr,
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.orangeTag,
                      ),
                    );
                  }),
                ],
              ),
              Row(
                children: [
                  Text(
                    AppStrings.goToToday,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.orangeTag,
                    ),
                  ),
                  AppSpacing.h4,
                  Icon(
                    Icons.arrow_right_alt,
                    size: 16,
                    color: AppColors.orangeTag,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildCalendarGridShimmer();
      }

      final calendarData = controller.attendanceData.value?.calendar;
      final Map<int, String> statusDays = calendarData?.days ?? {};

      final viewDate = controller.viewDate.value;
      final now = DateTime.now();
      final isCurrentMonth =
          viewDate.year == now.year && viewDate.month == now.month;

      int daysInMonth = DateTime(viewDate.year, viewDate.month + 1, 0).day;
      int firstWeekday = DateTime(viewDate.year, viewDate.month, 1).weekday;

      int startOffset = firstWeekday == 7 ? 0 : firstWeekday;

      List<Widget> rows = [];

      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: AppTextStyles.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
      rows.add(const SizedBox(height: AppSpacing.s12));

      List<Widget> currentRow = [];

      int prevDaysInMonth = DateTime(viewDate.year, viewDate.month, 0).day;
      for (int i = 0; i < startOffset; i++) {
        int d = prevDaysInMonth - startOffset + i + 1;
        currentRow.add(Expanded(child: _buildDateBubble('$d', 'p_dashed')));
      }

      for (int day = 1; day <= daysInMonth; day++) {
        String type = statusDays[day] ?? 'no_class';
        final isToday = isCurrentMonth && day == now.day;

        currentRow.add(
          Expanded(child: _buildDateBubble('$day', type, isToday: isToday)),
        );

        if (currentRow.length == 7) {
          rows.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: currentRow,
            ),
          );
          if (day < daysInMonth) {
            rows.add(const SizedBox(height: AppSpacing.s8));
          }
          currentRow = [];
        }
      }

      if (currentRow.isNotEmpty) {
        while (currentRow.length < 7) {
          currentRow.add(const Expanded(child: SizedBox()));
        }
        rows.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: currentRow,
          ),
        );
      }

      return Column(children: rows);
    });
  }

  Widget _buildDateBubble(String day, String type, {bool isToday = false}) {
    // Dashed sibling-month placeholder is a separate render path.
    if (type == 'p_dashed') {
      return Center(
        child: CustomPaint(
          painter: _DashedRectPainter(color: AppColors.borderLightGray),
          child: SizedBox(
            width: AppSpacing.s36,
            height: AppSpacing.s36,
            child: Center(
              child: Text(
                day,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Each state gets its own bg + fg pair so the four statuses are
    // visually distinct at a glance. Holiday used to share Absent's red,
    // which was the main source of confusion — it now reads as amber
    // ("special day off") instead of as a missed attendance.
    ({Color bg, Color fg}) palette = switch (type) {
      'present' || 'p' => (bg: AppColors.successBg, fg: AppColors.greenText),
      'absent' || 'a' => (bg: AppColors.errorBg, fg: AppColors.bohoRed),
      'holiday' || 'h' => (bg: AppColors.warningBg, fg: AppColors.warningAmber),
      _ => (bg: AppColors.fieldBg, fg: AppColors.textMuted),
    };

    final isNoClass =
        type != 'present' &&
        type != 'p' &&
        type != 'absent' &&
        type != 'a' &&
        type != 'holiday' &&
        type != 'h';

    if (isToday) {
      palette = (bg: AppColors.primaryBrand, fg: AppColors.white);
    }

    return Center(
      child: Container(
        width: AppSpacing.s36,
        height: AppSpacing.s36,
        decoration: BoxDecoration(
          color: palette.bg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: isToday
              ? Border.all(color: AppColors.instBrandOrange, width: 2)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Faint × behind the date number on no-class days, so the cell
            // visually reads as "nothing scheduled" without losing the date.
            if (isNoClass && !isToday)
              Icon(
                Icons.close_rounded,
                size: 28,
                color: AppColors.textMuted.withValues(alpha: 0.20),
              ),
            Text(
              day,
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.fg,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.s12,
      runSpacing: AppSpacing.s8,
      children: [
        _legendItem(AppColors.successBg, AppColors.greenText, 'Present'),
        _legendItem(AppColors.errorBg, AppColors.bohoRed, 'Absent'),
        _legendItem(AppColors.warningBg, AppColors.warningAmber, 'Holiday'),
        _legendItem(
          AppColors.fieldBg,
          AppColors.textMuted,
          'No class',
          icon: Icons.close_rounded,
        ),
        _legendItem(AppColors.primaryBrand, AppColors.white, 'Today'),
      ],
    );
  }

  /// Each legend chip is a miniature of the cell it represents (same bg,
  /// same fg ring, optional × for the no-class entry) so a student can map
  /// chip ↔ calendar day without translation.
  Widget _legendItem(Color bg, Color fg, String label, {IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: fg.withValues(alpha: 0.45)),
          ),
          child: icon == null
              ? null
              : Icon(icon, size: 10, color: fg.withValues(alpha: 0.7)),
        ),
        AppSpacing.h6,
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
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
      child: Obx(() {
        if (controller.isLoading.value) {
          return _buildSummaryCardShimmer();
        }

        final data = controller.attendanceData.value;
        if (data == null) return const SizedBox();

        final summary = data.summary;
        final percent = summary.pct;

        final calendarDays = data.calendar.days;
        final viewDate = controller.viewDate.value;
        final daysInMonth = DateTime(viewDate.year, viewDate.month + 1, 0).day;
        int presentCount = 0, absentCount = 0, holidayCount = 0;
        for (final v in calendarDays.values) {
          switch (v) {
            case 'present':
            case 'p':
              presentCount++;
            case 'absent':
            case 'a':
              absentCount++;
            case 'holiday':
            case 'h':
              holidayCount++;
          }
        }
        final noClassCount =
            (daysInMonth - presentCount - absentCount - holidayCount).clamp(
              0,
              daysInMonth,
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CustomPaint(
                    painter: _SummaryRingPainter(percent: percent),
                    child: Center(
                      child: Text(
                        '$percent%',
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ),
                  ),
                ),
                AppSpacing.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.label,
                        style: AppTextStyles.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$percent%',
                        style: AppTextStyles.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${summary.present} present - ${summary.absent} absent',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            Row(
              children: [
                Expanded(
                  child: _miniStat(
                    icon: Icons.check_circle_rounded,
                    bg: AppColors.successBg,
                    fg: AppColors.greenText,
                    count: presentCount,
                    label: 'Present',
                  ),
                ),
                AppSpacing.h8,
                Expanded(
                  child: _miniStat(
                    icon: Icons.cancel_rounded,
                    bg: AppColors.errorBg,
                    fg: AppColors.bohoRed,
                    count: absentCount,
                    label: 'Absent',
                  ),
                ),
                AppSpacing.h8,
                Expanded(
                  child: _miniStat(
                    icon: Icons.calendar_month_rounded,
                    bg: AppColors.warningBg,
                    fg: AppColors.warningAmber,
                    count: holidayCount,
                    label: 'Holidays',
                  ),
                ),
                AppSpacing.h8,
                Expanded(
                  child: _miniStat(
                    icon: Icons.cancel_rounded,
                    bg: AppColors.fieldBg,
                    fg: AppColors.textMuted,
                    count: noClassCount,
                    label: 'No Class',
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _miniStat({
    required IconData icon,
    required Color bg,
    required Color fg,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.s12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: AppTextStyles.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTodayCardShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.s8),
          ),
        ),
        AppSpacing.h16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 100, height: 16, color: AppColors.white),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 12,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSummaryCardShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
        AppSpacing.h16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 80, height: 12, color: AppColors.white),
              const SizedBox(height: 8),
              Container(width: 60, height: 24, color: AppColors.white),
              const SizedBox(height: 8),
              Container(width: 150, height: 12, color: AppColors.white),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildCalendarGridShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Column(
      children: List.generate(
        6,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (i) => Container(
                width: AppSpacing.s36,
                height: AppSpacing.s36,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.s8),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _SummaryRingPainter extends CustomPainter {
  final int percent;

  _SummaryRingPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 6.0;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - stroke) / 2,
    );
    final track = Paint()
      ..color = AppColors.successBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    if (percent <= 0) return;
    final progress = Paint()
      ..color = AppColors.successGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final sweep = (percent.clamp(0, 100) / 100) * 2 * math.pi;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, progress);
  }

  @override
  bool shouldRepaint(covariant _SummaryRingPainter old) =>
      old.percent != percent;
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double dashWidth = 4;
    final double dashSpace = 4;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );

    Path path = Path()..addRRect(rrect);
    PathMetrics pathMetrics = path.computeMetrics();

    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final length = math.min(dashWidth, pathMetric.length - distance);
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + length),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) => old.color != color;
}

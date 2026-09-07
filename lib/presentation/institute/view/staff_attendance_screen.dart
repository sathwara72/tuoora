import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/staff_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StaffAttendanceScreen extends GetView<StaffController> {
  const StaffAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final staffName =
        controller.selectedStaff.value?.fullName ?? 'Staff Member';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.instAttendanceTitle,
              subtitle: staffName,
              actions: [_buildAddAttendanceButton()],
            ),
            Expanded(
              child: Obx(() {
                return CommonStateWidget(
                  isLoading:
                      controller.isLoadingAttendance.value &&
                      controller.attendanceList.isEmpty,
                  isEmpty: false,
                  emptyTitle: AppStrings.noAttendanceData,
                  emptySubtitle: AppStrings.noAttendanceRecordsFoundForThis,
                  emptyIcon: Icons.calendar_today_outlined,
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPaddingTop,
                    child: Column(
                      children: [
                        _buildSummaryCard(),
                        AppSpacing.v24,
                        _buildCalendarCard(),
                        AppSpacing.v24,
                        _buildRemarksCard(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAttendanceButton() {
    return GestureDetector(
      onTap: () {
        final staff = controller.selectedStaff.value;
        if (staff == null) return;
        controller.selectLogStaffById(staff.id);
        Get.toNamed(AppRoutes.instituteLogStaffAttendance);
      },
      child: Container(
        width: AppSpacing.s40,
        height: AppSpacing.s40,
        decoration: BoxDecoration(
          color: AppColors.primaryBrand,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.white,
          size: AppSpacing.s22,
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              Icons.check_circle,
              controller.totalPresent.value.toString().padLeft(2, '0'),
              'PRESENT',
              AppColors.successGreen,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.background),
          Expanded(
            child: _buildSummaryItem(
              Icons.cancel,
              controller.totalAbsent.value.toString().padLeft(2, '0'),
              'ABSENT',
              AppColors.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.6), size: 24),
            AppSpacing.h12,
            Text(
              count,
              style: AppTextStyles.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => _buildCircleNavButton(
                  Icons.chevron_left,
                  () => controller.previousMonth(),
                  enabled: controller.canGoToPrevStaffAttendanceMonth,
                ),
              ),
              Obx(
                () => Text(
                  DateFormat(
                    'MMMM yyyy',
                  ).format(controller.selectedAttendanceMonth.value),
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Obx(
                () => _buildCircleNavButton(
                  Icons.chevron_right,
                  () => controller.nextMonth(),
                  enabled: controller.canGoToNextStaffAttendanceMonth,
                ),
              ),
            ],
          ),
          AppSpacing.v24,
          const Divider(height: 1, color: AppColors.background),
          AppSpacing.v24,
          _buildCalendarGrid(controller.selectedAttendanceMonth.value),
          AppSpacing.v24,
          const Divider(height: 1, color: AppColors.background),
          AppSpacing.v24,
          _buildLegend(),
        ],
      ),
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

  Widget _buildCalendarGrid(DateTime currentMonth) {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> rows = [];
    List<String> currentDates = [];
    List<int> currentStatuses = [];

    // Map attendance data for easy lookup
    final attendanceMap = <int, String>{};
    for (var a in controller.attendanceList) {
      try {
        final day = DateTime.parse(a.date).day;
        attendanceMap[day] = a.status;
      } catch (_) {}
    }

    for (int i = 0; i < startWeekday; i++) {
      currentDates.add('');
      currentStatuses.add(-1);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      currentDates.add(day.toString());

      final statusStr = attendanceMap[day];
      int status = 0; // Default off/no data
      if (statusStr == 'Present') {
        status = 1;
      } else if (statusStr == 'Absent') {
        status = 2;
      }

      currentStatuses.add(status);

      if (currentDates.length == 7) {
        rows.add(
          _buildCalendarRow(
            List.from(currentDates),
            List.from(currentStatuses),
          ),
        );
        rows.add(AppSpacing.v20);
        currentDates.clear();
        currentStatuses.clear();
      }
    }

    if (currentDates.isNotEmpty) {
      while (currentDates.length < 7) {
        currentDates.add('');
        currentStatuses.add(-1);
      }
      rows.add(_buildCalendarRow(currentDates, currentStatuses));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdays
              .map(
                (d) => SizedBox(
                  width: 32,
                  child: Text(
                    d,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
        AppSpacing.v24,
        ...rows,
      ],
    );
  }

  Widget _buildCalendarRow(List<String> dates, List<int> statuses) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        7,
        (i) => _buildCalendarDay(dates[i], statuses[i]),
      ),
    );
  }

  Widget _buildCalendarDay(String date, int status) {
    if (date.isEmpty) return const SizedBox(width: 32);

    return SizedBox(
      width: 32,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: Text(
                date,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (status != -1) ...[
            AppSpacing.v4,
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: status == 1
                    ? AppColors.successGreen.withValues(alpha: 0.6)
                    : (status == 2
                          ? AppColors.errorRed.withValues(alpha: 0.6)
                          : Colors.transparent),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          AppColors.successGreen.withValues(alpha: 0.6),
          'PRESENT',
        ),
        AppSpacing.h24,
        _buildLegendItem(AppColors.errorRed.withValues(alpha: 0.6), 'ABSENT'),
        AppSpacing.h24,
        _buildLegendItem(AppColors.textMuted.withValues(alpha: 0.4), 'OFF'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        AppSpacing.h8,
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksCard() {
    final latestRemark = controller.attendanceList.firstWhereOrNull(
      (a) => a.note != null && a.note!.isNotEmpty,
    );

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.all8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.speaker_notes,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ),
              AppSpacing.h16,
              Text(
                latestRemark != null
                    ? '${DateFormat('MMM dd').format(DateTime.parse(latestRemark.date)).toUpperCase()} REMARKS'
                    : 'LATEST REMARKS',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          AppSpacing.v20,
          Text(
            latestRemark?.note ?? 'No remarks for this month.',
            style: AppTextStyles.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

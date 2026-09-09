import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_self_attendance_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_attendance_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherSelfAttendanceScreen extends GetView<TeacherSelfAttendanceController> {
  const TeacherSelfAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const TeacherAppBar(title: 'My Attendance & Leaves'),
            _buildTabSelector(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }

                if (controller.selectedTab.value == 0) {
                  return _buildCalendarAndCheckInTab(context);
                } else {
                  return _buildLeavesTab(context);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(4),
        child: Obx(() {
          final tab = controller.selectedTab.value;
          return Row(
            children: [
              Expanded(
                child: _tabButton(
                  title: 'Calendar & Check-in',
                  icon: Icons.calendar_month_rounded,
                  isActive: tab == 0,
                  onTap: () => controller.selectedTab.value = 0,
                ),
              ),
              Expanded(
                child: _tabButton(
                  title: 'Leave Applications',
                  icon: Icons.beach_access_rounded,
                  isActive: tab == 1,
                  onTap: () => controller.selectedTab.value = 1,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primaryBrand : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primaryBrand : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: CALENDAR & TODAY'S CHECK-IN
  // ==========================================

  Widget _buildCalendarAndCheckInTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchCalendar(
        month: controller.currentMonth.value,
        year: controller.currentYear.value,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _buildTodayCheckInCard(context),
          AppSpacing.v16,
          _buildMonthSwitcher(),
          AppSpacing.v12,
          _buildSummaryDayCounts(),
          AppSpacing.v16,
          _buildMonthlyCalendarGrid(),
          AppSpacing.v16,
          _buildSelectedDayDetailCard(),
          AppSpacing.v20,
        ],
      ),
    );
  }

  Widget _buildTodayCheckInCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Attendance",
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Obx(() {
                final status = controller.today.value?.status;
                return _statusBadge(status ?? 'Not Marked');
              }),
            ],
          ),
          AppSpacing.v16,
          Text(
            'Tap status to mark attendance:',
            style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textSecondary),
          ),
          AppSpacing.v8,
          Obx(() {
            final todayStatus = controller.today.value?.status;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TeacherSelfAttendanceController.statuses.map((status) {
                final isSelected = todayStatus == status;
                return GestureDetector(
                  onTap: controller.isMarking.value
                      ? null
                      : () => _promptMarkToday(context, status),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBrand : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBrand : AppColors.borderGrey,
                      ),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  void _promptMarkToday(BuildContext context, String status) {
    final noteCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Mark as $status?',
          style: AppTextStyles.outfit(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm marking your attendance for today as "$status".',
              style: AppTextStyles.outfit(fontSize: 13, color: AppColors.textSecondary),
            ),
            AppSpacing.v12,
            TextField(
              controller: noteCtrl,
              decoration: InputDecoration(
                hintText: 'Add an optional note or remark...',
                hintStyle: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyles.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.markToday(status, note: noteCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Confirm', style: AppTextStyles.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSwitcher() {
    return Obx(() {
      final month = controller.currentMonth.value;
      final year = controller.currentYear.value;
      final date = DateTime(year, month);
      final monthLabel = DateFormat('MMMM yyyy').format(date);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => controller.changeMonth(-1),
            ),
            Row(
              children: [
                const Icon(Icons.event_note_rounded, size: 18, color: AppColors.primaryBrand),
                const SizedBox(width: 8),
                Text(
                  monthLabel,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => controller.changeMonth(1),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryDayCounts() {
    return Obx(() {
      final data = controller.calendarData.value;
      final p = data?.totalPresent ?? 0;
      final a = data?.totalAbsent ?? 0;
      final h = data?.totalHalfDay ?? 0;
      final l = data?.totalLate ?? 0;
      final lv = data?.totalLeave ?? 0;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _metricPill('Present', p, const Color(0xFF059669), const Color(0xFFECFDF5)),
            const SizedBox(width: 8),
            _metricPill('Absent', a, const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
            const SizedBox(width: 8),
            _metricPill('Half Day', h, const Color(0xFFD97706), const Color(0xFFFFFBEB)),
            const SizedBox(width: 8),
            _metricPill('Late', l, const Color(0xFFEA580C), const Color(0xFFFFF7ED)),
            const SizedBox(width: 8),
            _metricPill('Leave', lv, const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
          ],
        ),
      );
    });
  }

  Widget _metricPill(String label, int count, Color textCol, Color bgCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textCol.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(
            '$count',
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textCol,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCalendarGrid() {
    return Obx(() {
      if (controller.isLoadingCalendar.value) {
        return const Center(child: Padding(padding: EdgeInsets.all(24), child: CommonLoading()));
      }

      final year = controller.currentYear.value;
      final month = controller.currentMonth.value;
      final daysInMonth = DateUtils.getDaysInMonth(year, month);
      final firstDayOfMonth = DateTime(year, month, 1);
      final int startingWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

      final List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays
                  .map(
                    (w) => SizedBox(
                      width: 36,
                      child: Text(
                        w,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Divider(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (startingWeekday - 1) + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                if (index < startingWeekday - 1) {
                  return const SizedBox.shrink();
                }
                final dayNumber = index - (startingWeekday - 1) + 1;
                final date = DateTime(year, month, dayNumber);
                final dateStr = DateFormat('yyyy-MM-dd').format(date);
                final dayData = controller.calendarData.value?.days[dateStr];
                final isSunday = date.weekday == DateTime.sunday;
                final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;
                final isSelected = controller.selectedDay.value?.date == dateStr;

                return _calendarDayTile(
                  dayNumber: dayNumber,
                  dateStr: dateStr,
                  dayData: dayData,
                  isSunday: isSunday,
                  isToday: isToday,
                  isSelected: isSelected,
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _calendarDayTile({
    required int dayNumber,
    required String dateStr,
    required TeacherCalendarDay? dayData,
    required bool isSunday,
    required bool isToday,
    required bool isSelected,
  }) {
    Color bg = const Color(0xFFF8FAFC);
    Color textColor = AppColors.textPrimary;
    Color? dotColor;

    final status = (dayData?.status ?? '').toLowerCase();
    if (status.contains('present')) {
      bg = const Color(0xFFECFDF5);
      textColor = const Color(0xFF059669);
      dotColor = const Color(0xFF10B981);
    } else if (status.contains('absent')) {
      bg = const Color(0xFFFEF2F2);
      textColor = const Color(0xFFDC2626);
      dotColor = const Color(0xFFEF4444);
    } else if (status.contains('half')) {
      bg = const Color(0xFFFFFBEB);
      textColor = const Color(0xFFD97706);
      dotColor = const Color(0xFFF59E0B);
    } else if (status.contains('late')) {
      bg = const Color(0xFFFFF7ED);
      textColor = const Color(0xFFEA580C);
      dotColor = const Color(0xFFF97316);
    } else if (status.contains('leave')) {
      bg = const Color(0xFFF5F3FF);
      textColor = const Color(0xFF7C3AED);
      dotColor = const Color(0xFF8B5CF6);
    } else if (isSunday) {
      bg = const Color(0xFFF1F5F9);
      textColor = AppColors.textTertiary;
    }

    return GestureDetector(
      onTap: () => controller.onDaySelected(dateStr),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBrand
                : isToday
                    ? AppColors.primaryBrand.withValues(alpha: 0.5)
                    : Colors.transparent,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$dayNumber',
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (dotColor != null)
              Positioned(
                bottom: 3,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayDetailCard() {
    return Obx(() {
      final day = controller.selectedDay.value;
      if (day == null) return const SizedBox.shrink();

      DateTime? parsedDate;
      try {
        parsedDate = DateTime.parse(day.date);
      } catch (_) {}

      final formatted = parsedDate != null
          ? DateFormat('EEEE, dd MMMM yyyy').format(parsedDate)
          : day.date;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatted,
                  style: AppTextStyles.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                _statusBadge(day.status),
              ],
            ),
            if (day.inTime != null || day.outTime != null) ...[
              AppSpacing.v8,
              Row(
                children: [
                  if (day.inTime != null)
                    Text(
                      'In: ${day.inTime}',
                      style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  if (day.inTime != null && day.outTime != null)
                    const Text('  ·  ', style: TextStyle(color: AppColors.textTertiary)),
                  if (day.outTime != null)
                    Text(
                      'Out: ${day.outTime}',
                      style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ],
            if (day.note != null && day.note!.isNotEmpty) ...[
              AppSpacing.v8,
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note_alt_outlined, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        day.note!,
                        style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ==========================================
  // TAB 2: LEAVE APPLICATIONS
  // ==========================================

  Widget _buildLeavesTab(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Requests',
                    style: AppTextStyles.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Apply and manage your leave requests',
                    style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showApplyLeaveBottomSheet(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(
                  'Apply Leave',
                  style: AppTextStyles.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingLeaves.value && controller.leaves.isEmpty) {
              return const Center(child: CommonLoading());
            }

            if (controller.leaves.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.beach_access_outlined, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)),
                      AppSpacing.v12,
                      Text(
                        'No leave applications found.',
                        style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      AppSpacing.v16,
                      AppButton(
                        label: 'Apply for Leave',
                        onPressed: () => _showApplyLeaveBottomSheet(context),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchLeaves,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.leaves.length,
                separatorBuilder: (_, ___) => AppSpacing.v12,
                itemBuilder: (context, index) {
                  final leave = controller.leaves[index];
                  return _LeaveCard(
                    leave: leave,
                    onCancel: () => _confirmCancelLeave(context, leave),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showApplyLeaveBottomSheet(BuildContext context) {
    final startCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final endCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final reasonCtrl = TextEditingController();
    final skipSundays = true.obs;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Apply for Leave',
                  style: AppTextStyles.outfit(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            AppSpacing.v8,
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 7)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        startCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                        if (DateTime.parse(endCtrl.text).isBefore(picked)) {
                          endCtrl.text = startCtrl.text;
                        }
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: startCtrl,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final initial = DateTime.tryParse(startCtrl.text) ?? DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: initial,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        endCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: endCtrl,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.v12,
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Skip Sundays',
                  style: AppTextStyles.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Do not count Sundays in total leave days',
                  style: AppTextStyles.outfit(fontSize: 12, color: AppColors.textTertiary),
                ),
                value: skipSundays.value,
                activeThumbColor: AppColors.primaryBrand,
                onChanged: (val) => skipSundays.value = val,
              ),
            ),
            AppSpacing.v8,
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style: AppTextStyles.outfit(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Reason for Leave *',
                hintText: 'Provide details for your leave request...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            AppSpacing.v16,
            Obx(
              () => AppButton(
                label: 'Submit Leave Application',
                isLoading: controller.isSubmittingLeave.value,
                onPressed: () async {
                  if (reasonCtrl.text.trim().isEmpty) {
                    AppSnackBar.error('Please provide a reason for leave.');
                    return;
                  }
                  final ok = await controller.applyLeave(
                    startDate: startCtrl.text.trim(),
                    endDate: endCtrl.text.trim(),
                    reason: reasonCtrl.text.trim(),
                    skipSundays: skipSundays.value,
                  );
                  if (ok) Get.back();
                },
              ),
            ),
            AppSpacing.v12,
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmCancelLeave(BuildContext context, TeacherLeaveItem leave) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Leave?',
          style: AppTextStyles.outfit(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel your leave application for ${leave.startDate} to ${leave.endDate}?',
          style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Keep', style: AppTextStyles.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.cancelLeave(leave.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Cancel Leave', style: AppTextStyles.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = AppColors.textSecondary;

    final s = status.toLowerCase();
    if (s.contains('present')) {
      bg = const Color(0xFFECFDF5);
      text = const Color(0xFF059669);
    } else if (s.contains('absent')) {
      bg = const Color(0xFFFEF2F2);
      text = const Color(0xFFDC2626);
    } else if (s.contains('half')) {
      bg = const Color(0xFFFFFBEB);
      text = const Color(0xFFD97706);
    } else if (s.contains('late')) {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFEA580C);
    } else if (s.contains('leave') || s.contains('approved')) {
      bg = const Color(0xFFF5F3FF);
      text = const Color(0xFF7C3AED);
    } else if (s.contains('pending')) {
      bg = const Color(0xFFEFF6FF);
      text = const Color(0xFF2563EB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: AppTextStyles.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final TeacherLeaveItem leave;
  final VoidCallback onCancel;

  const _LeaveCard({
    required this.leave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusText;
    final s = leave.status.toLowerCase();

    if (s.contains('approved')) {
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF059669);
    } else if (s.contains('reject')) {
      statusBg = const Color(0xFFFEF2F2);
      statusText = const Color(0xFFDC2626);
    } else if (s.contains('cancel')) {
      statusBg = const Color(0xFFF1F5F9);
      statusText = AppColors.textTertiary;
    } else {
      statusBg = const Color(0xFFEFF6FF);
      statusText = const Color(0xFF2563EB);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 16, color: AppColors.primaryBrand),
                  const SizedBox(width: 6),
                  Text(
                    leave.startDate == leave.endDate
                        ? leave.startDate
                        : '${leave.startDate}  ➜  ${leave.endDate}',
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  leave.status,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v8,
          Text(
            leave.reason,
            style: AppTextStyles.outfit(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.v10,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: Text(
                      '${leave.daysCount} Day${leave.daysCount == 1 ? '' : 's'}',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (leave.skipSundays) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· Sundays skipped',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
              if (leave.isPending)
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Cancel Leave',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

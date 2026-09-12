import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_attendance_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_attendance_model.dart';

class TeacherSelfAttendanceController extends GetxController {
  final TeacherAttendanceRepositoryImpl _repository;

  TeacherSelfAttendanceController(this._repository);

  final RxBool isLoading = true.obs;
  final RxBool isMarking = false.obs;
  final RxBool isLoadingCalendar = false.obs;
  final RxBool isLoadingLeaves = false.obs;
  final RxBool isSubmittingLeave = false.obs;

  final RxInt selectedTab = 0.obs; // 0: Attendance Calendar, 1: Leaves

  final Rxn<TeacherStaffAttendance> today = Rxn<TeacherStaffAttendance>();
  final Rxn<TeacherSelfAttendanceHistory> history = Rxn<TeacherSelfAttendanceHistory>();
  final Rxn<TeacherAttendanceCalendarData> calendarData = Rxn<TeacherAttendanceCalendarData>();
  final Rxn<TeacherCalendarDay> selectedDay = Rxn<TeacherCalendarDay>();
  final RxList<TeacherLeaveItem> leaves = <TeacherLeaveItem>[].obs;

  final RxInt currentMonth = DateTime.now().month.obs;
  final RxInt currentYear = DateTime.now().year.obs;

  static const statuses = ['Present', 'Absent', 'Half Day', 'Late', 'Leave'];

  @override
  void onInit() {
    super.onInit();
    initLoad();
  }

  Future<void> initLoad() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchToday(),
        fetchCalendar(month: currentMonth.value, year: currentYear.value),
        fetchLeaves(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchToday() async {
    try {
      today.value = await _repository.getSelfAttendanceToday();
    } catch (e) {
      // Non-critical, ignore or log
    }
  }

  Future<void> fetchCalendar({int? month, int? year}) async {
    final m = month ?? currentMonth.value;
    final y = year ?? currentYear.value;
    currentMonth.value = m;
    currentYear.value = y;

    isLoadingCalendar.value = true;
    try {
      final res = await _repository.getSelfAttendanceCalendar(month: m, year: y);
      calendarData.value = res;

      // Select today if in current month/year, else first day of month
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayDay = _resolveDay(todayStr);
      if (todayDay != null) {
        selectedDay.value = todayDay;
      } else if (res.days.isNotEmpty) {
        selectedDay.value = res.days.values.first;
      } else {
        selectedDay.value = null;
      }
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoadingCalendar.value = false;
    }
  }

  void changeMonth(int offset) {
    var m = currentMonth.value + offset;
    var y = currentYear.value;
    if (m > 12) {
      m = 1;
      y++;
    } else if (m < 1) {
      m = 12;
      y--;
    }
    fetchCalendar(month: m, year: y);
  }

  void onDaySelected(String dateKey) {
    selectedDay.value = _resolveDay(dateKey) ??
        TeacherCalendarDay(date: dateKey, status: 'Not Marked');
  }

  /// The calendar endpoint keys each day by its bare day-of-month (e.g.
  /// "12"), not a full ISO date, so a lookup by "yyyy-MM-dd" alone always
  /// misses. Fall back to the day-of-month and stamp the real ISO date
  /// back on so the detail card can still format it properly.
  TeacherCalendarDay? _resolveDay(String isoDateStr) {
    final days = calendarData.value?.days;
    if (days == null) return null;

    final direct = days[isoDateStr];
    if (direct != null) return direct;

    final parsed = DateTime.tryParse(isoDateStr);
    if (parsed == null) return null;
    final byDayNumber =
        days[parsed.day.toString()] ?? days[parsed.day.toString().padLeft(2, '0')];
    if (byDayNumber == null) return null;

    return TeacherCalendarDay(
      date: isoDateStr,
      status: byDayNumber.status,
      note: byDayNumber.note,
      inTime: byDayNumber.inTime,
      outTime: byDayNumber.outTime,
    );
  }

  Future<void> markToday(String status, {String? note}) async {
    try {
      isMarking.value = true;
      final res = await _repository.markSelfAttendance(status: status, note: note);
      today.value = res;
      AppSnackBar.success('Attendance marked as $status');
      // Refresh calendar
      await fetchCalendar(month: currentMonth.value, year: currentYear.value);
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isMarking.value = false;
    }
  }

  Future<void> fetchLeaves() async {
    isLoadingLeaves.value = true;
    try {
      final result = await _repository.getAppliedLeaves();
      leaves.assignAll(result);
    } catch (e) {
      // silent or snackbar
    } finally {
      isLoadingLeaves.value = false;
    }
  }

  Future<bool> applyLeave({
    required String startDate,
    required String endDate,
    required String reason,
    bool skipSundays = true,
  }) async {
    isSubmittingLeave.value = true;
    try {
      await _repository.applyLeave(
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        skipSundays: skipSundays,
      );
      AppSnackBar.success('Leave application submitted successfully.');
      await fetchLeaves();
      await fetchCalendar(month: currentMonth.value, year: currentYear.value);
      return true;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      isSubmittingLeave.value = false;
    }
  }

  Future<bool> cancelLeave(int leaveId) async {
    try {
      await _repository.cancelLeave(leaveId);
      leaves.removeWhere((l) => l.id == leaveId);
      AppSnackBar.success('Leave cancelled successfully.');
      await fetchCalendar(month: currentMonth.value, year: currentYear.value);
      return true;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}

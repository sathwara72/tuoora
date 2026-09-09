import 'package:tuoora/presentation/teacher/models/teacher_attendance_model.dart';

abstract class TeacherAttendanceRepositoryImpl {
  Future<List<TeacherAttendanceRow>> getBatchAttendance({
    required int batchId,
    required String date,
  });

  Future<void> markBatchAttendance({
    required int batchId,
    required String date,
    required List<Map<String, dynamic>> attendance,
  });

  Future<TeacherStaffAttendance?> getSelfAttendanceToday();

  Future<TeacherSelfAttendanceHistory> getSelfAttendanceHistory({
    int? month,
    int? year,
    int page = 1,
  });

  Future<TeacherStaffAttendance> markSelfAttendance({
    required String status,
    String? note,
  });

  Future<TeacherAttendanceCalendarData> getSelfAttendanceCalendar({
    required int month,
    required int year,
  });

  Future<void> applyLeave({
    required String startDate,
    required String endDate,
    required String reason,
    bool skipSundays = true,
  });

  Future<List<TeacherLeaveItem>> getAppliedLeaves();

  Future<void> cancelLeave(int leaveId);
}

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
}

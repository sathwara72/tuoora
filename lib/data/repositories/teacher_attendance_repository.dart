import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/teacher_attendance_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_attendance_model.dart';

class TeacherAttendanceRepository implements TeacherAttendanceRepositoryImpl {
  final ApiClient _apiClient;

  TeacherAttendanceRepository(this._apiClient);

  @override
  Future<List<TeacherAttendanceRow>> getBatchAttendance({
    required int batchId,
    required String date,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.teacherAttendance,
      query: {'batch_id': batchId.toString(), 'date': date},
    );
    if (response.status.hasError) {
      throw Exception('Failed to load attendance: ${response.statusText}');
    }
    return (response.body['data'] as List? ?? [])
        .map((e) => TeacherAttendanceRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> markBatchAttendance({
    required int batchId,
    required String date,
    required List<Map<String, dynamic>> attendance,
  }) async {
    final response = await _apiClient.post(ApiConstants.teacherAttendance, {
      'batch_id': batchId,
      'date': date,
      'attendance': attendance,
    });
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to mark attendance',
      );
    }
  }

  @override
  Future<TeacherStaffAttendance?> getSelfAttendanceToday() async {
    final response = await _apiClient.get(ApiConstants.teacherSelfAttendanceToday);
    if (response.status.hasError) {
      throw Exception('Failed to load today\'s attendance: ${response.statusText}');
    }
    final data = response.body['data'];
    return data == null
        ? null
        : TeacherStaffAttendance.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<TeacherSelfAttendanceHistory> getSelfAttendanceHistory({
    int? month,
    int? year,
    int page = 1,
  }) async {
    final query = <String, String>{'per_page': '30', 'page': page.toString()};
    if (month != null) query['month'] = month.toString();
    if (year != null) query['year'] = year.toString();
    final response = await _apiClient.get(
      ApiConstants.teacherSelfAttendance,
      query: query,
    );
    if (response.status.hasError) {
      throw Exception('Failed to load attendance history: ${response.statusText}');
    }
    return TeacherSelfAttendanceHistory.fromJson(
      Map<String, dynamic>.from(response.body),
    );
  }

  @override
  Future<TeacherStaffAttendance> markSelfAttendance({
    required String status,
    String? note,
  }) async {
    final body = <String, dynamic>{'status': status};
    if (note != null && note.isNotEmpty) body['note'] = note;
    final response = await _apiClient.post(ApiConstants.teacherSelfAttendance, body);
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to mark attendance',
      );
    }
    return TeacherStaffAttendance.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }
}

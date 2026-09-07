import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/teacher_timetable_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_timetable_model.dart';

class TeacherTimetableRepository implements TeacherTimetableRepositoryImpl {
  final ApiClient _apiClient;

  TeacherTimetableRepository(this._apiClient);

  @override
  Future<List<TeacherTimetableSlot>> getTimetable({
    required int batchId,
    String? day,
  }) async {
    final query = <String, String>{'batch_id': batchId.toString()};
    if (day != null) query['day'] = day;
    final response = await _apiClient.get(ApiConstants.teacherTimetable, query: query);
    if (response.status.hasError) {
      throw Exception('Failed to load timetable: ${response.statusText}');
    }
    return (response.body['data'] as List? ?? [])
        .map((e) => TeacherTimetableSlot.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<TeacherTimetableSlot> createSlot(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.teacherTimetable, data);
    if (response.status.hasError) {
      throw Exception(response.body?['message'] ?? 'Failed to create slot');
    }
    return TeacherTimetableSlot.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<TeacherTimetableSlot> updateSlot(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put(
      ApiConstants.teacherTimetableDetail(id),
      data,
    );
    if (response.status.hasError) {
      throw Exception(response.body?['message'] ?? 'Failed to update slot');
    }
    return TeacherTimetableSlot.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<void> deleteSlot(int id) async {
    final response = await _apiClient.delete(ApiConstants.teacherTimetableDetail(id));
    if (response.status.hasError) {
      throw Exception(response.body?['message'] ?? 'Failed to delete slot');
    }
  }
}

import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/student_timetable_repository_impl.dart';
import 'package:tuoora/presentation/student/models/student_timetable_model.dart';

class StudentTimetableRepository implements StudentTimetableRepositoryImpl {
  final ApiClient _apiClient;

  StudentTimetableRepository(this._apiClient);

  @override
  Future<List<StudentTimetableSlot>> getTimetable({String day = 'all'}) async {
    final response = await _apiClient.get(
      ApiConstants.studentTimetable,
      query: {'day': day},
    );
    if (response.status.hasError) {
      throw Exception('Failed to load timetable: ${response.statusText}');
    }

    final data = response.body['data'] as List? ?? [];
    return data
        .map((json) => StudentTimetableSlot.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}

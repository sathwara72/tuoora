import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/student_exam_repository_impl.dart';
import 'package:tuoora/presentation/student/models/student_exam_model.dart';

class StudentExamRepository implements StudentExamRepositoryImpl {
  final ApiClient _apiClient;

  StudentExamRepository(this._apiClient);

  @override
  Future<StudentExamListData> getExams() async {
    final response = await _apiClient.get(ApiConstants.studentExams);
    if (response.status.hasError) {
      throw Exception('Failed to load exams: ${response.statusText}');
    }

    final data = response.body['data'];
    final examsList = (data['exams'] as List? ?? [])
        .map((e) => StudentExamListItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return StudentExamListData(
      exams: examsList,
      overallStats: StudentExamOverallStats.fromJson(
        Map<String, dynamic>.from(data['overall_stats'] ?? {}),
      ),
    );
  }

  @override
  Future<StudentExamDetail> getExamDetail(int id) async {
    final response = await _apiClient.get(ApiConstants.studentExamDetail(id));
    if (response.status.hasError) {
      throw Exception('Failed to load exam detail: ${response.statusText}');
    }
    return StudentExamDetail.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }
}

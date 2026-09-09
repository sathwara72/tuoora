import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/teacher_exam_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_exam_model.dart';

class TeacherExamRepository implements TeacherExamRepositoryImpl {
  final ApiClient _apiClient;

  TeacherExamRepository(this._apiClient);

  @override
  Future<TeacherExamListPage> getExams({
    required int batchId,
    String? status,
    int page = 1,
  }) async {
    final query = <String, String>{
      'batch_id': batchId.toString(),
      'page': page.toString(),
    };
    if (status != null) query['status'] = status;
    final response = await _apiClient.get(ApiConstants.teacherExams, query: query);
    if (response.status.hasError) {
      throw Exception('Failed to load exams: ${response.statusText}');
    }
    return TeacherExamListPage.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<TeacherExam> createExam(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.teacherExams, data);
    if (response.status.hasError) {
      _handleError(response, 'Failed to create exam');
    }
    return TeacherExam.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<TeacherExam> updateExam(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(ApiConstants.teacherExamDetail(id), data);
    if (response.status.hasError) {
      _handleError(response, 'Failed to update exam');
    }
    return TeacherExam.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<void> deleteExam(int id) async {
    final response = await _apiClient.delete(ApiConstants.teacherExamDetail(id));
    if (response.status.hasError) {
      throw Exception(response.body?['message'] ?? 'Failed to delete exam');
    }
  }

  @override
  Future<TeacherExamMarksData> getExamMarks(int id) async {
    final response = await _apiClient.get(ApiConstants.teacherExamMarks(id));
    if (response.status.hasError) {
      throw Exception('Failed to load marks: ${response.statusText}');
    }
    return TeacherExamMarksData.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<void> saveExamMarks(
    int id,
    List<Map<String, dynamic>> marks, {
    bool markStatusAsCompleted = true,
  }) async {
    final response = await _apiClient.post(ApiConstants.teacherExamMarks(id), {
      'marks': marks,
      'mark_status_as_completed': markStatusAsCompleted,
    });
    if (response.status.hasError) {
      throw Exception(response.body?['message'] ?? 'Failed to save marks');
    }
  }

  void _handleError(dynamic response, String defaultMessage) {
    if (response.statusCode == 422 && response.body?['errors'] != null) {
      throw ValidationException(
        Map<String, dynamic>.from(response.body['errors']),
      );
    }
    throw Exception(response.body?['message'] ?? defaultMessage);
  }
}

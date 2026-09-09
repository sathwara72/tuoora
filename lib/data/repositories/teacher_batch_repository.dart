import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/teacher_batch_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';

class TeacherBatchRepository implements TeacherBatchRepositoryImpl {
  final ApiClient _apiClient;

  TeacherBatchRepository(this._apiClient);

  @override
  Future<List<TeacherBatch>> getBatches() async {
    final response = await _apiClient.get(ApiConstants.teacherBatches);
    if (response.status.hasError) {
      throw Exception('Failed to load batches: ${response.statusText}');
    }
    return (response.body['data'] as List? ?? [])
        .map((e) => TeacherBatch.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<TeacherBatchDetail> getBatchDetail(int id) async {
    final response = await _apiClient.get(ApiConstants.teacherBatchDetail(id));
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to load batch details',
      );
    }
    return TeacherBatchDetail.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<List<TeacherBatchStudent>> getBatchStudents(int batchId) async {
    final response = await _apiClient.get(ApiConstants.teacherBatchStudents(batchId));
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to load batch students: ${response.statusText}',
      );
    }
    final rawData = response.body is Map ? (response.body['data'] ?? response.body['students']) : response.body;
    if (rawData is List) {
      return rawData
          .map((e) => TeacherBatchStudent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  @override
  Future<List<TeacherBatchStudent>> getAvailableStudents(int batchId, {String? search}) async {
    final query = (search != null && search.trim().isNotEmpty)
        ? '&search=${Uri.encodeComponent(search.trim())}'
        : '';
    final response = await _apiClient.get('${ApiConstants.teacherBatchStudents(batchId)}?available=1$query');
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to load available students: ${response.statusText}',
      );
    }
    final rawData = response.body is Map ? (response.body['data'] ?? response.body['students']) : response.body;
    if (rawData is List) {
      return rawData
          .map((e) => TeacherBatchStudent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  @override
  Future<void> assignStudentsToBatch(int batchId, List<int> studentIds) async {
    final response = await _apiClient.post(
      ApiConstants.teacherBatchStudents(batchId),
      {'student_ids': studentIds},
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to assign students: ${response.statusText}',
      );
    }
  }

  @override
  Future<void> registerStudentToBatch(int batchId, Map<String, dynamic> studentData) async {
    final response = await _apiClient.post(
      ApiConstants.teacherBatchStudents(batchId),
      studentData,
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to register student: ${response.statusText}',
      );
    }
  }

  @override
  Future<void> updateBatchStudent(int batchId, int studentId, Map<String, dynamic> studentData) async {
    final response = await _apiClient.put(
      ApiConstants.teacherBatchStudentDetail(batchId, studentId),
      studentData,
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to update student: ${response.statusText}',
      );
    }
  }

  @override
  Future<void> removeStudentFromBatch(int batchId, int studentId) async {
    final response = await _apiClient.post(
      ApiConstants.teacherBatchStudentRemove(batchId, studentId),
      {},
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to remove student from batch: ${response.statusText}',
      );
    }
  }
}

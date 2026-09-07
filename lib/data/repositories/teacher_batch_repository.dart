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
}

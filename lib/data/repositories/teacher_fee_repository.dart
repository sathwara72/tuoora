import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/teacher_fee_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_fee_model.dart';

class TeacherFeeRepository implements TeacherFeeRepositoryImpl {
  final ApiClient _apiClient;

  TeacherFeeRepository(this._apiClient);

  @override
  Future<List<TeacherFee>> getFees(int batchId) async {
    final response = await _apiClient.get(
      ApiConstants.teacherFees,
      query: {'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ??
            'Fee visibility is not enabled for this batch.',
      );
    }
    return (response.body['data'] as List? ?? [])
        .map((e) => TeacherFee.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

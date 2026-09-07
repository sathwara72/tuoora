import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/student_id_card_repository_impl.dart';
import 'package:tuoora/presentation/student/models/student_id_card_model.dart';

class StudentIdCardRepository implements StudentIdCardRepositoryImpl {
  final ApiClient _apiClient;

  StudentIdCardRepository(this._apiClient);

  @override
  Future<StudentIdCard> getIdCard() async {
    final response = await _apiClient.get(ApiConstants.studentIdCard);
    if (response.status.hasError) {
      throw Exception('Failed to load ID card: ${response.statusText}');
    }
    return StudentIdCard.fromJson(Map<String, dynamic>.from(response.body['data']));
  }
}

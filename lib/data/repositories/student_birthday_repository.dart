import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/student_birthday_repository_impl.dart';
import 'package:tuoora/presentation/student/models/student_birthday_model.dart';

class StudentBirthdayRepository implements StudentBirthdayRepositoryImpl {
  final ApiClient _apiClient;

  StudentBirthdayRepository(this._apiClient);

  @override
  Future<List<StudentBirthday>> getBatchBirthdays() async {
    final response = await _apiClient.get(ApiConstants.studentBirthdays);
    if (response.status.hasError) {
      throw Exception('Failed to load birthdays: ${response.statusText}');
    }

    final data = response.body['data'] as List? ?? [];
    return data
        .map((json) => StudentBirthday.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}

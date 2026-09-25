import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/data/repositories_impl/student_repository_impl.dart';
import 'package:get/get.dart';

class StudentRepository implements StudentRepositoryImpl {
  final ApiClient _apiClient;

  StudentRepository(this._apiClient);

  @override
  Future<List<Student>> listStudents({String? search, int? page}) async {
    final Map<String, dynamic> query = {};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (page != null) {
      query['page'] = page.toString();
    }

    final response = await _apiClient.get(
      ApiConstants.instituteStudents,
      query: query,
    );
    if (response.status.hasError) {
      throw Exception('Failed to load students: ${response.statusText}');
    }

    final Map<String, dynamic> body = response.body;
    final List<dynamic> items = body['data']?['items'] ?? [];
    return items.map((json) => Student.fromJson(json)).toList();
  }

  @override
  Future<Student> createStudent(Map<String, dynamic> data) async {
    final formData = FormData(data);

    if (data['profile_image_url'] != null &&
        data['profile_image_url'].toString().isNotEmpty &&
        !data['profile_image_url'].toString().startsWith('http')) {
      formData.files.add(
        MapEntry(
          'profile_image_url',
          MultipartFile(
            data['profile_image_url'],
            filename: 'student_profile.jpg',
          ),
        ),
      );
      data.remove('profile_image_url');
    }

    final response = await _apiClient.post(
      ApiConstants.instituteStudents,
      formData,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to create student');
    }
    return Student.fromJson(response.body['data']);
  }

  @override
  Future<Student> getStudentById(dynamic id) async {
    final response = await _apiClient.get(
      '${ApiConstants.instituteStudents}/$id',
    );
    if (response.status.hasError) {
      throw Exception('Failed to get student: ${response.statusText}');
    }
    return Student.fromJson(response.body['data']);
  }

  @override
  Future<Student> updateStudent(dynamic id, Map<String, dynamic> data) async {
    final formData = FormData(data);

    if (data['profile_image_url'] != null &&
        data['profile_image_url'].toString().isNotEmpty &&
        !data['profile_image_url'].toString().startsWith('http')) {
      formData.files.add(
        MapEntry(
          'profile_image_url',
          MultipartFile(
            data['profile_image_url'],
            filename: 'student_profile.jpg',
          ),
        ),
      );
      data.remove('profile_image_url');
    }

    formData.fields.add(const MapEntry('_method', 'PUT'));

    final response = await _apiClient.post(
      '${ApiConstants.instituteStudents}/$id',
      formData,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update student');
    }
    return Student.fromJson(response.body['data']);
  }

  @override
  Future<bool> deleteStudent(dynamic id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.instituteStudents}/$id',
    );
    if (response.status.hasError) {
      throw Exception('Failed to delete student: ${response.statusText}');
    }
    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<void> sendFeeReminder(dynamic id) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteStudents}/$id/fee-reminder',
      {},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to send fee reminder');
    }
  }

  @override
  Future<String> sendPassword(dynamic id) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteStudents}/$id/send-password',
      {},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to send password');
    }
    return response.body?['message'] ?? 'Password has been generated and sent to student email successfully!';
  }

  @override
  Future<void> resetPassword(dynamic id, String password) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteStudents}/$id/reset-password',
      {'password': password},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to reset password');
    }
  }

  @override
  Future<void> payInstallment(
    int installmentId, {
    required double amount,
    String paymentMethod = 'Cash',
  }) async {
    final response = await _apiClient.post(
      ApiConstants.institutePayInstallment(installmentId),
      {
        'amount': amount,
        'payment_method': paymentMethod,
      },
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to pay installment');
    }
  }

  void _handleError(Response response, String defaultMessage) {
    if (response.statusCode == 422 && response.body?['errors'] != null) {
      throw ValidationException(response.body['errors']);
    }
    final message = response.body?['message'] ?? defaultMessage;
    throw Exception(message);
  }
}


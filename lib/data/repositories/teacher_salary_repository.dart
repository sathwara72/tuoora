import 'dart:io';

import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/data/repositories_impl/teacher_salary_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_salary_model.dart';

class TeacherSalaryRepository implements TeacherSalaryRepositoryImpl {
  final ApiClient _apiClient;

  TeacherSalaryRepository(this._apiClient);

  @override
  Future<TeacherSalaryListPage> getSalaries({
    int? month,
    int? year,
    int page = 1,
  }) async {
    final query = <String, String>{'page': page.toString()};
    if (month != null) query['month'] = month.toString();
    if (year != null) query['year'] = year.toString();
    final response = await _apiClient.get(
      ApiConstants.teacherSalaries,
      query: query,
    );
    if (response.status.hasError) {
      throw Exception('Failed to load salary slips: ${response.statusText}');
    }
    return TeacherSalaryListPage.fromJson(
      Map<String, dynamic>.from(response.body),
    );
  }

  @override
  Future<List<int>> downloadSalarySlip(int id) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.teacherSalaryDownload(id)}',
    );
    final client = HttpClient();
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/pdf');

    final authService = Get.find<AuthService>();
    if (authService.isAuthenticated) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${authService.token}',
      );
    }

    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Failed to download salary slip (${response.statusCode})');
    }

    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
    }
    client.close();
    return bytes;
  }
}

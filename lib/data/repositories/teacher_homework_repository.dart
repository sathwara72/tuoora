import 'dart:io';

import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/repositories_impl/teacher_homework_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_homework_model.dart';

class TeacherHomeworkRepository implements TeacherHomeworkRepositoryImpl {
  final ApiClient _apiClient;

  TeacherHomeworkRepository(this._apiClient);

  @override
  Future<TeacherHomeworkListPage> getHomeworks({
    required int batchId,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.teacherHomeworks,
      query: {'batch_id': batchId.toString(), 'page': page.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to load homeworks: ${response.statusText}');
    }
    return TeacherHomeworkListPage.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<TeacherHomework> createHomework(
    Map<String, dynamic> data, {
    String? attachmentPath,
  }) async {
    final formData = FormData(data);
    if (attachmentPath != null) {
      formData.files.add(
        MapEntry(
          'attachment',
          MultipartFile(
            File(attachmentPath),
            filename: attachmentPath.split('/').last,
          ),
        ),
      );
    }
    final response = await _apiClient.post(
      ApiConstants.teacherHomeworks,
      formData,
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to create homework',
      );
    }
    return TeacherHomework.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<TeacherHomeworkDetail> getHomeworkDetail(int id) async {
    final response = await _apiClient.get(ApiConstants.teacherHomeworkDetail(id));
    if (response.status.hasError) {
      throw Exception('Failed to load homework: ${response.statusText}');
    }
    return TeacherHomeworkDetail.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<TeacherHomework> updateHomework(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put(
      ApiConstants.teacherHomeworkDetail(id),
      data,
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to update homework',
      );
    }
    return TeacherHomework.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<void> deleteHomework(int id) async {
    final response = await _apiClient.delete(ApiConstants.teacherHomeworkDetail(id));
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to delete homework',
      );
    }
  }

  @override
  Future<void> submitGrades(int id, List<Map<String, dynamic>> grades) async {
    final response = await _apiClient.post(
      ApiConstants.teacherHomeworkGrades(id),
      {'grades': grades},
    );
    if (response.status.hasError) {
      throw Exception(response.body?['message'] ?? 'Failed to save grades');
    }
  }
}

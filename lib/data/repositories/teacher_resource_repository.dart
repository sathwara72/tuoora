import 'dart:io';
import 'package:get/get.dart';

import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/data/repositories_impl/teacher_resource_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_resource_model.dart';

class TeacherResourceRepository implements TeacherResourceRepositoryImpl {
  final ApiClient _apiClient;

  TeacherResourceRepository(this._apiClient);

  @override
  Future<List<TeacherResource>> getBatchResources(int batchId) async {
    final response = await _apiClient.get(
      ApiConstants.teacherResources,
      query: {'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to load study materials: ${response.statusText}');
    }

    final rawData = response.body is Map
        ? (response.body['data'] ?? response.body['resources'])
        : response.body;

    if (rawData is List) {
      return rawData
          .map((e) => TeacherResource.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  @override
  Future<TeacherResource> uploadResource({
    required int batchId,
    required String title,
    String? subject,
    String? description,
    required String filePath,
  }) async {
    final file = File(filePath);
    final fileName = filePath.split(Platform.pathSeparator).last;

    final formData = FormData({
      'batch_id': batchId,
      'title': title,
      if (subject != null && subject.isNotEmpty) 'subject': subject,
      if (description != null && description.isNotEmpty) 'description': description,
      'file': MultipartFile(file, filename: fileName),
    });

    final response = await _apiClient.post(
      ApiConstants.teacherResources,
      formData,
    );

    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to upload study material',
      );
    }

    final data = response.body['data'] is Map ? response.body['data'] : response.body;
    return TeacherResource.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<List<int>> downloadResource(int resourceId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.teacherResourceDownload(resourceId)}',
    );
    final client = HttpClient();
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, '*/*');

    final authService = Get.find<AuthService>();
    if (authService.isAuthenticated) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${authService.token}',
      );
    }

    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Failed to download resource (${response.statusCode})');
    }

    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  @override
  Future<void> deleteResource(int resourceId) async {
    final response = await _apiClient.delete(
      ApiConstants.teacherResourceDetail(resourceId),
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to delete resource',
      );
    }
  }
}

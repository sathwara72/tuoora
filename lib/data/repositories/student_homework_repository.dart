import 'dart:io';
import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/data/repositories_impl/student_homework_repository_impl.dart';
import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/data/models/student_homework_attachment_model.dart';

class StudentHomeworkRepository implements StudentHomeworkRepositoryImpl {
  final ApiClient _apiClient;

  StudentHomeworkRepository(this._apiClient);

  @override
  Future<StudentHomeworkData> getHomeworks() async {
    final response = await _apiClient.get(ApiConstants.studentHomeworks);
    if (response.status.hasError) {
      throw Exception('Failed to load homeworks: ${response.statusText}');
    }

    final data = response.body['data'];
    final summary = AssignmentSummary.fromJson(data['summary'] ?? {});

    final pendingList =
        (data['pending'] as List?)
            ?.map((e) => Assignment.fromJson(e, isCompleted: false))
            .toList() ??
        [];

    final completedList =
        (data['completed'] as List?)
            ?.map((e) => Assignment.fromJson(e, isCompleted: true))
            .toList() ??
        [];

    return StudentHomeworkData(
      summary: summary,
      pending: pendingList,
      completed: completedList,
    );
  }

  @override
  Future<Assignment> getHomeworkDetail(int id) async {
    final response = await _apiClient.get(
      ApiConstants.studentHomeworkDetail(id),
    );
    if (response.status.hasError) {
      throw Exception('Failed to load homework detail: ${response.statusText}');
    }
    return Assignment.fromJson(
      response.body['data'],
      isCompleted: response.body['data']['submission'] != null,
    );
  }

  @override
  Future<StudentHomeworkAttachmentModel> getHomeworkAttachment(int id) async {
    final response = await _apiClient.get(
      ApiConstants.studentHomeworkAttachment(id),
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to load homework attachment: ${response.statusText}',
      );
    }
    return StudentHomeworkAttachmentModel.fromJson(response.body['data']);
  }

  @override
  Future<List<int>> downloadAttachment(
    int id, {
    void Function(double)? onProgress,
  }) async {
    return _downloadFile(
      ApiConstants.studentHomeworkAttachmentDownload(id),
      onProgress: onProgress,
    );
  }

  @override
  Future<void> submitHomework(int id, {String? note, String? attachmentPath}) async {
    final fields = <String, dynamic>{if (note != null) 'note': note};
    final formData = FormData(fields);
    if (attachmentPath != null && attachmentPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'attachment',
          MultipartFile(attachmentPath, filename: attachmentPath.split('/').last),
        ),
      );
    }

    final response = await _apiClient.post(
      '${ApiConstants.studentHomeworks}/$id/submit',
      formData,
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to submit homework';
      throw Exception(message);
    }
  }

  Future<List<int>> _downloadFile(
    String endpoint, {
    String acceptHeader = '*/*',
    Function(double)? onProgress,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final client = HttpClient();
      final request = await client.getUrl(uri);

      request.headers.set(HttpHeaders.acceptHeader, acceptHeader);

      final authService = Get.find<AuthService>();
      if (authService.isAuthenticated) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer ${authService.token}',
        );
      }

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      List<int> bytes = [];
      int downloaded = 0;

      await for (var chunk in response) {
        bytes.addAll(chunk);
        downloaded += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(downloaded / contentLength);
        }
      }
      return bytes;
    } catch (e) {
      throw Exception('Failed to download: $e');
    }
  }
}

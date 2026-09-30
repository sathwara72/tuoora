import 'dart:io';

import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/models/student_profile_model.dart';
import 'package:tuoora/data/repositories_impl/student_profile_repository_impl.dart';

class StudentProfileRepository implements StudentProfileRepositoryImpl {
  final ApiClient _apiClient;

  StudentProfileRepository(this._apiClient);

  @override
  Future<StudentProfileModel> getProfile() async {
    final response = await _apiClient.get(ApiConstants.studentProfile);
    if (response.status.hasError) {
      throw Exception('Failed to load profile: ${response.statusText}');
    }
    return StudentProfileModel.fromJson(response.body['data']);
  }

  @override
  Future<void> deleteAccount() async {
    final response = await _apiClient.delete(
      ApiConstants.studentAccountDelete,
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message']?.toString() ??
            'Failed to delete account: ${response.statusText}',
      );
    }
  }

  @override
  Future<void> submitFeedback(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.studentFeedback, data);
    if (response.status.hasError) {
      throw Exception('Failed to submit feedback: ${response.statusText}');
    }
  }

  @override
  Future<String> uploadAvatar(File file) async {
    final filename = file.uri.pathSegments.isEmpty
        ? 'avatar'
        : file.uri.pathSegments.last;

    final response = await _apiClient.post(
      ApiConstants.studentProfileAvatar,
      FormData({
        'avatar': MultipartFile(file, filename: filename),
      }),
    );

    if (response.status.hasError) {
      if (response.statusCode == 422 && response.body?['errors'] != null) {
        throw ValidationException(
          Map<String, dynamic>.from(response.body['errors']),
        );
      }
      throw Exception(
        response.body?['message']?.toString() ??
            'Failed to upload avatar: ${response.statusText}',
      );
    }

    final body = response.body;
    if (body is Map && body['avatar_url'] != null) {
      return body['avatar_url'].toString();
    }
    throw Exception('Upload succeeded but no avatar_url returned');
  }
}

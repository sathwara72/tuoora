import 'dart:io';

import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/data/models/user_model.dart';
import 'package:tuoora/data/repositories_impl/teacher_profile_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_profile_model.dart';

class TeacherProfileRepository implements TeacherProfileRepositoryImpl {
  final ApiClient _apiClient;

  TeacherProfileRepository(this._apiClient);

  @override
  Future<TeacherProfile> getProfile() async {
    final response = await _apiClient.get(ApiConstants.teacherProfile);
    if (response.status.hasError) {
      throw Exception('Failed to load profile: ${response.statusText}');
    }
    final data = Map<String, dynamic>.from(response.body['data']);

    // Sync available institutes to current user session if provided
    final rawInstitutes = data['institutes'] ?? data['available_institutes'];
    if (rawInstitutes is List && rawInstitutes.isNotEmpty) {
      final authService = Get.find<AuthService>();
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        final parsed = rawInstitutes
            .map(
              (e) => TeacherInstituteInfo.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
        await authService.saveSession(
          currentUser.copyWith(institutes: parsed),
          stayAuthenticated: authService.shouldStayAuthenticated,
          loggedIn: true,
          role: 'TEACHER',
        );
      }
    }

    return TeacherProfile.fromJson(data);
  }

  @override
  Future<TeacherProfile> updateAvatar(String filePath) async {
    final formData = FormData({
      'profile_image': MultipartFile(
        File(filePath),
        filename: filePath.split('/').last,
      ),
    });
    final response = await _apiClient.post(
      ApiConstants.teacherProfileAvatar,
      formData,
    );
    if (response.status.hasError) {
      throw Exception(response.body?['message'] ?? 'Failed to update avatar');
    }
    return TeacherProfile.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }
}

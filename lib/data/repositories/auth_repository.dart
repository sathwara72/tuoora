import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/institute_account_status_handler.dart';
import 'package:tuoora/data/models/subscription_model.dart';
import 'package:tuoora/data/models/user_model.dart';
import 'package:tuoora/data/repositories_impl/auth_repository_impl.dart';

class AuthRepository implements AuthRepositoryImpl {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  @override
  Future<User> loginInstitute(
    String email,
    String password, {
    String? device,
    String? os,
  }) async {
    final Map<String, dynamic> body = {'email': email, 'password': password};
    if (device != null) body['device'] = device;
    if (os != null) body['os'] = os;
    final response = await _apiClient.post(ApiConstants.instituteLogin, body);
    if (response.statusCode == 403) {
      final body = response.body;
      if (body is Map) {
        final status = body['status']?.toString().toLowerCase() ?? '';
        final message = body['message']?.toString() ?? 'Login forbidden';
        if (status.isNotEmpty) {
          throw AccountStatusException(status, message);
        }
      }
    }
    final user = _handleResponse(response, 'INSTITUTE');
    await _updateSubscription(response);
    return user;
  }

  @override
  Future<User> loginStudent(String email, String password) async {
    final response = await _apiClient.post(ApiConstants.studentLogin, {
      'email': email,
      'password': password,
    });
    final user = _handleResponse(response, 'STUDENT');
    await Get.find<AuthService>().setSubscription(null);
    return user;
  }

  @override
  Future<User> loginTeacher(String email, String password) async {
    final response = await _apiClient.post(ApiConstants.teacherLogin, {
      'email': email,
      'password': password,
    });
    final user = _handleResponse(response, 'TEACHER');
    await Get.find<AuthService>().setSubscription(null);
    return user;
  }

  Future<void> _updateSubscription(dynamic response) async {
    try {
      final sub = response.body?['subscription'];
      await Get.find<AuthService>().setSubscription(
        sub != null
            ? Subscription.fromJson(Map<String, dynamic>.from(sub))
            : null,
      );
    } catch (_) {}
  }

  User _handleResponse(dynamic response, String role) {
    if (response.status.hasError) {
      throw Exception(response.body?['message'] ?? 'Login failed');
    }

    final data = response.body['data'];
    final token =
        data['token']?.toString() ?? data['access_token']?.toString() ?? '';
    final accessToken = data['access_token']?.toString() ?? token;
    final refreshToken = data['refresh_token']?.toString() ?? '';
    return User.fromJson(
      data,
      token,
      role,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<({String accessToken, String refreshToken})?> refreshAccessToken(
    String refreshToken,
  ) async {
    try {
      final response = await _apiClient.post(ApiConstants.authRefresh, {
        'refresh_token': refreshToken,
      });
      if (response.status.hasError) return null;
      final data = response.body?['data'];
      if (data is! Map) return null;
      final newAccess =
          data['access_token']?.toString() ?? data['token']?.toString();
      final newRefresh = data['refresh_token']?.toString();
      if (newAccess == null || newAccess.isEmpty) return null;
      return (accessToken: newAccess, refreshToken: newRefresh ?? refreshToken);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout(String role) async {
    final endpoint = role == 'INSTITUTE'
        ? ApiConstants.instituteLogout
        : role == 'TEACHER'
        ? ApiConstants.teacherLogout
        : ApiConstants.studentLogout;
    final response = await _apiClient.post(endpoint, {});
    if (response.status.hasError) {
      throw Exception(response.body?['message'] ?? 'Logout failed');
    }
  }

  @override
  Future<String> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiConstants.instituteForgotPassword,
      {'email': email},
    );

    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to send reset OTP';
      throw Exception(message);
    }

    return response.body['message'] ?? 'Success';
  }

  @override
  Future<String> resetPassword(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteResetPassword,
      data,
    );

    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to reset password';
      throw Exception(message);
    }

    return response.body['message'] ?? 'Success';
  }

  @override
  Future<String> teacherForgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiConstants.teacherForgotPassword,
      {'email': email},
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to send reset OTP';
      throw Exception(message);
    }
    return response.body['message'] ?? 'Success';
  }

  @override
  Future<String> teacherResetPassword(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.teacherResetPassword,
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to reset password');
    }
    return response.body['message'] ?? 'Success';
  }

  @override
  Future<void> teacherChangePassword(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.teacherChangePassword,
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to change password');
    }
  }

  @override
  Future<User> switchTeacherInstitute(int instituteId) async {
    final response = await _apiClient.post(
      ApiConstants.teacherSwitchInstitute,
      {'institute_id': instituteId},
    );
    if (response.status.hasError) {
      throw Exception(
        response.body?['message'] ?? 'Failed to switch institute',
      );
    }

    final body = response.body;
    final data = body is Map ? (body['data'] ?? body) : null;
    final authService = Get.find<AuthService>();
    final currentUser = authService.currentUser;

    String? newAccessToken;
    String? newRefreshToken;
    String? newInstituteName;

    if (data is Map) {
      final token =
          data['token']?.toString() ?? data['access_token']?.toString();
      newAccessToken = data['access_token']?.toString() ?? token;
      newRefreshToken = data['refresh_token']?.toString();
      newInstituteName =
          data['institute_name']?.toString() ??
          (data['institute'] is Map
              ? (data['institute']['institute_name'] ??
                      data['institute']['name'])
                  ?.toString()
              : null);
    }

    if (newInstituteName == null && currentUser != null) {
      for (final inst in currentUser.institutes) {
        if (inst.id == instituteId) {
          newInstituteName = inst.name;
          break;
        }
      }
    }

    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        instituteId: instituteId,
        instituteName: newInstituteName ?? currentUser.instituteName,
        accessToken: newAccessToken ?? currentUser.accessToken,
        refreshToken: newRefreshToken ?? currentUser.refreshToken,
      );
      await authService.saveSession(
        updatedUser,
        stayAuthenticated: authService.shouldStayAuthenticated,
        loggedIn: true,
        role: 'TEACHER',
      );
      return updatedUser;
    } else {
      final user = _handleResponse(response, 'TEACHER');
      await authService.saveSession(
        user,
        stayAuthenticated: authService.shouldStayAuthenticated,
        loggedIn: true,
        role: 'TEACHER',
      );
      return user;
    }
  }

  void _handleError(dynamic response, String defaultMessage) {
    if (response.statusCode == 422 && response.body?['errors'] != null) {
      throw ValidationException(
        Map<String, dynamic>.from(response.body['errors']),
      );
    }
    throw Exception(response.body?['message'] ?? defaultMessage);
  }
}

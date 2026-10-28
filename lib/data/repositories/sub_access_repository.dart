import 'package:get/get_connect/http/src/response/response.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/models/sub_access_model.dart';

class SubAccessRepository {
  final ApiClient _apiClient;

  SubAccessRepository(this._apiClient);

  Future<({List<SubAccessUser> users, List<SubAccessPermissionGroup> groups})>
  list({String? search}) async {
    final response = await _apiClient.get(
      ApiConstants.instituteSubAccess,
      query: (search != null && search.isNotEmpty) ? {'search': search} : null,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to load sub-access users');
    }
    final body = response.body;
    final data = body is Map ? body['data'] : null;
    return (
      users: data is List
          ? data
                .whereType<Map>()
                .map((e) => SubAccessUser.fromJson(e.cast<String, dynamic>()))
                .toList()
          : <SubAccessUser>[],
      groups: SubAccessPermissionGroup.listFromJson(
        body is Map ? body['available_permissions'] : null,
      ),
    );
  }

  Future<List<SubAccessPermissionGroup>> getPermissions() async {
    final response = await _apiClient.get(
      ApiConstants.instituteSubAccessPermissions,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to load permissions');
    }
    final body = response.body;
    return SubAccessPermissionGroup.listFromJson(
      body is Map ? body['data'] : null,
    );
  }

  Future<SubAccessUser> create(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteSubAccess,
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to create sub-access user');
    }
    return SubAccessUser.fromJson(
      (response.body['data'] as Map).cast<String, dynamic>(),
    );
  }

  Future<SubAccessUser> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      ApiConstants.instituteSubAccessDetail(id),
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update sub-access user');
    }
    return SubAccessUser.fromJson(
      (response.body['data'] as Map).cast<String, dynamic>(),
    );
  }

  Future<void> delete(int id) async {
    final response = await _apiClient.delete(
      ApiConstants.instituteSubAccessDetail(id),
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to delete sub-access user');
    }
  }

  /// Returns the new status (`active` / `inactive`).
  Future<String> toggleStatus(int id) async {
    final response = await _apiClient.post(
      ApiConstants.instituteSubAccessToggleStatus(id),
      {},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update status');
    }
    return response.body?['new_status']?.toString() ?? 'active';
  }

  Future<String> forceLogout(int id) async {
    final response = await _apiClient.post(
      ApiConstants.instituteSubAccessForceLogout(id),
      {},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to log out user');
    }
    return response.body?['message']?.toString() ?? 'User has been logged out.';
  }

  Future<String> resetPassword(int id, String password) async {
    final response = await _apiClient.post(
      ApiConstants.instituteSubAccessResetPassword(id),
      {'password': password},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to reset password');
    }
    return response.body?['message']?.toString() ??
        'Password reset successfully.';
  }

  void _handleError(Response response, String defaultMessage) {
    if (response.statusCode == 422 && response.body?['errors'] != null) {
      throw ValidationException(
        (response.body['errors'] as Map).cast<String, dynamic>(),
      );
    }
    final body = response.body;
    final message = body is Map ? body['message'] : null;
    throw Exception(message ?? defaultMessage);
  }
}

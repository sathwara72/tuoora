import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/models/student_notification_model.dart';

class StudentNotificationsRepository {
  final ApiClient _apiClient;

  StudentNotificationsRepository(this._apiClient);

  Future<List<StudentNotification>> getNotifications() async {
    final response = await _apiClient.get(ApiConstants.studentNotifications);
    if (response.status.hasError) {
      throw Exception(
        'Failed to load notifications: ${response.statusText}',
      );
    }
    final list = (response.body['data'] as List?) ?? const [];
    return list
        .map((e) => StudentNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(int id) async {
    final response = await _apiClient.post(
      ApiConstants.studentNotificationRead(id),
      {},
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to mark notification as read: ${response.statusText}',
      );
    }
  }

  Future<void> markAllRead() async {
    final response = await _apiClient.post(
      ApiConstants.studentNotificationsMarkAllRead,
      {},
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to mark all notifications as read: ${response.statusText}',
      );
    }
  }

  Future<Map<String, dynamic>> getNotificationSettings() async {
    final response = await _apiClient.get(ApiConstants.studentNotificationSettings);
    if (response.status.hasError) {
      throw Exception('Failed to load notification settings: ${response.statusText}');
    }
    return response.body['data'] as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> updateNotificationSettings(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.studentNotificationSettings, data);
    if (response.status.hasError) {
      throw Exception('Failed to update notification settings: ${response.statusText}');
    }
    return response.body['data'] as Map<String, dynamic>? ?? {};
  }
}

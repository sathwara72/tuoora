import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/models/daily_update_model.dart';
import 'package:tuoora/data/repositories_impl/daily_update_repository_impl.dart';

class DailyUpdateRepository implements DailyUpdateRepositoryImpl {
  final ApiClient _apiClient;

  DailyUpdateRepository(this._apiClient);

  @override
  Future<DailyUpdate> createDailyUpdate(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteDailyUpdates,
      data,
    );

    if (response.status.hasError) {
      throw Exception('Failed to create daily update: ${response.statusText}');
    }

    final body = response.body;
    if (body == null) {
      throw Exception('Response body is null');
    }

    final updateData = body is Map<String, dynamic>
        ? (body['data'] ?? body)
        : body;

    if (updateData == null) {
      throw Exception('Update data is null');
    }

    return DailyUpdate.fromJson(updateData as Map<String, dynamic>);
  }

  @override
  Future<String> deleteDailyUpdate(int id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.instituteDailyUpdates}/$id',
    );
    final body = response.body;
    final message = body is Map ? body['message']?.toString() : null;
    if (response.status.hasError) {
      throw Exception(message ?? 'Failed to delete update');
    }
    return message ?? 'Update deleted successfully.';
  }

  @override
  Future<List<DailyUpdate>> listDailyUpdates() async {
    final response = await _apiClient.get(ApiConstants.instituteDailyUpdates);
    if (response.status.hasError) {
      throw Exception('Failed to list daily updates: ${response.statusText}');
    }

    final body = response.body;
    if (body == null) return [];

    List<dynamic> items = [];
    if (body is Map<String, dynamic>) {
      items = body['data'] ?? [];
    } else if (body is List) {
      items = body;
    }

    return items
        .map((json) {
          if (json is Map<String, dynamic>) {
            return DailyUpdate.fromJson(json);
          }
          return null;
        })
        .whereType<DailyUpdate>()
        .toList();
  }
}


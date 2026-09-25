import 'dart:io';

import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/presentation/student/models/fee_model.dart';

class StudentFeesRepository {
  final ApiClient _apiClient;

  StudentFeesRepository(this._apiClient);

  Future<StudentFeesData> getFees({dynamic batchId}) async {
    final Map<String, dynamic> query = {};
    if (batchId != null) query['batch_id'] = batchId.toString();

    final response = await _apiClient.get(
      ApiConstants.studentFees,
      query: query.isNotEmpty ? query : null,
    );
    if (response.status.hasError) {
      throw Exception('Failed to load fees: ${response.statusText}');
    }

    final data = response.body['data'] ?? {};
    final feesJson = (data['fees'] as List?) ?? const [];
    final fees = feesJson
        .map((e) => FeeStatement.fromJson(e as Map<String, dynamic>))
        .toList();

    final pendingCount = fees.where((f) => f.isPending).length;
    final pendingMonthsLabel = pendingCount == 0
        ? ''
        : pendingCount == 1
            ? '1 month pending'
            : '$pendingCount months pending';

    final summary = FeeSummary.fromJson(
      (data['summary'] as Map<String, dynamic>?) ?? const {},
      billedMonths: fees.length,
      pendingMonthsLabel: pendingMonthsLabel,
    );

    return StudentFeesData(
      summary: summary,
      fees: fees,
      allBatches: (data['all_batches'] as List?) ?? const [],
      selectedBatchId: data['selected_batch_id'],
      selectedBatch: data['selected_batch'],
    );
  }

  Future<StudentReceipt> getReceipt(int feeId) async {
    final response = await _apiClient.get(
      ApiConstants.studentReceiptDetail(feeId),
    );
    if (response.status.hasError) {
      throw Exception('Failed to load receipt: ${response.statusText}');
    }
    return StudentReceipt.fromJson(
      (response.body['data'] as Map<String, dynamic>?) ?? const {},
    );
  }

  Future<List<StudentReceipt>> getReceipts() async {
    final response = await _apiClient.get(ApiConstants.studentReceipts);
    if (response.status.hasError) {
      throw Exception('Failed to load receipts: ${response.statusText}');
    }
    final list = (response.body['data'] as List?) ?? const [];
    return list
        .map((e) => StudentReceipt.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getPaymentInfo() async {
    final response = await _apiClient.get(ApiConstants.studentPaymentInfo);
    if (response.status.hasError) {
      throw Exception('Failed to load payment info: ${response.statusText}');
    }
    return (response.body['data'] as Map<String, dynamic>?) ?? {};
  }

  Future<List<int>> downloadFeeReceipt(
    int feeId, {
    void Function(double)? onProgress,
  }) async {
    final endpoint = ApiConstants.studentFeeDownload(feeId);
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

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
      throw Exception('Failed: ${response.statusCode}');
    }

    final contentLength = response.contentLength;
    final bytes = <int>[];
    int downloaded = 0;
    await for (final chunk in response) {
      bytes.addAll(chunk);
      downloaded += chunk.length;
      if (contentLength > 0 && onProgress != null) {
        onProgress(downloaded / contentLength);
      }
    }
    return bytes;
  }
}

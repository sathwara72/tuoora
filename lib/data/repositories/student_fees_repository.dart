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

  Future<List<int>> downloadReceipt(
    StudentReceipt receipt, {
    void Function(double)? onProgress,
  }) async {
    // 1. If receipt has a direct download/pdf URL, try it
    if (receipt.downloadUrl != null &&
        receipt.downloadUrl!.trim().startsWith('http')) {
      try {
        return await _downloadFromUri(
          Uri.parse(receipt.downloadUrl!.trim()),
          onProgress: onProgress,
        );
      } catch (_) {}
    }

    // 2. Try the receipt download endpoint: /student/receipts/$id/download
    try {
      final endpoint = ApiConstants.studentReceiptDownload(receipt.id);
      return await _downloadFromUri(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        onProgress: onProgress,
      );
    } catch (e) {
      // 3. Fallback: if receipt has a distinct feeId or fallback
      if (receipt.feeId != null &&
          receipt.feeId != 0 &&
          receipt.feeId != receipt.id) {
        try {
          final fallbackEndpoint =
              ApiConstants.studentFeeDownload(receipt.feeId!);
          return await _downloadFromUri(
            Uri.parse('${ApiConstants.baseUrl}$fallbackEndpoint'),
            onProgress: onProgress,
          );
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<List<int>> downloadFeeReceipt(
    int feeId, {
    void Function(double)? onProgress,
  }) async {
    final endpoint = ApiConstants.studentFeeDownload(feeId);
    return _downloadFromUri(
      Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      onProgress: onProgress,
    );
  }

  Future<List<int>> _downloadFromUri(
    Uri initialUri, {
    void Function(double)? onProgress,
  }) async {
    final client = HttpClient();
    Uri currentUri = initialUri;
    HttpClientResponse? response;
    int redirectCount = 0;

    try {
      while (true) {
        final request = await client.getUrl(currentUri);
        request.followRedirects = false;
        request.headers.set(
          HttpHeaders.acceptHeader,
          'application/pdf, application/json, */*',
        );

        final authService = Get.find<AuthService>();
        final baseHost = Uri.parse(ApiConstants.baseUrl).host;
        // Only attach Bearer authorization token to our API backend domain
        if (authService.isAuthenticated &&
            (currentUri.host.contains('tuoora.com') ||
                currentUri.host == baseHost)) {
          request.headers.set(
            HttpHeaders.authorizationHeader,
            'Bearer ${authService.token}',
          );
        }

        response = await request.close();

        if (response.isRedirect ||
            response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 303 ||
            response.statusCode == 307 ||
            response.statusCode == 308) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          if (location != null && redirectCount < 5) {
            redirectCount++;
            currentUri = currentUri.resolve(location);
            continue;
          }
        }
        break;
      }

      if (response == null || response.statusCode != 200) {
        throw Exception(
          'Download failed (${response?.statusCode ?? 'No response'})',
        );
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
    } finally {
      client.close();
    }
  }
}

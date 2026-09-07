import 'package:tuoora/data/models/institute_subscription_model.dart';
import 'dart:io';
import 'package:tuoora/presentation/institute/models/expense_model.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/data/models/batch_model.dart';
import 'package:tuoora/data/models/institute_profile_model.dart';
import 'package:tuoora/data/models/whatsapp_settings_model.dart';
import 'package:tuoora/presentation/institute/models/fee_record.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/presentation/institute/models/report_models.dart';
import 'package:tuoora/presentation/institute/models/homework_model.dart';
import 'package:tuoora/presentation/institute/models/exam_model.dart';
import 'package:tuoora/presentation/institute/models/timetable_model.dart';
import 'package:tuoora/presentation/institute/models/resource_model.dart';
import 'package:tuoora/presentation/institute/models/school_class_model.dart';
import 'package:tuoora/presentation/institute/models/attendance_record_model.dart';
import 'package:tuoora/data/models/notification_model.dart';
import 'package:tuoora/data/models/staff_model.dart';
import 'package:tuoora/data/models/subscription_model.dart';
import 'package:tuoora/data/models/white_label_model.dart';
import 'package:tuoora/presentation/institute/models/birthday_model.dart';
import 'package:tuoora/presentation/institute/models/add_on_model.dart';
import 'package:get/get.dart';

class InstituteRepository implements InstituteRepositoryImpl {
  final ApiClient _apiClient;

  InstituteRepository(this._apiClient);

  @override
  Future<String> registerInstitute(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteRegister,
      data,
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Registration failed';
      throw Exception(message);
    }
    return response.body['message'] ?? 'Success';
  }

  @override
  Future<String> verifyOtp(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteVerifyOtp,
      data,
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'OTP verification failed';
      throw Exception(message);
    }

    final token = response.body['data']?['token'];
    if (token == null) {
      throw Exception('Token not found in response');
    }
    return token;
  }

  @override
  Future<InstituteProfile> getProfile() async {
    final response = await _apiClient.get(ApiConstants.instituteProfile);
    if (response.status.hasError) {
      throw Exception('Failed to fetch profile: ${response.statusText}');
    }

    final body = response.body;
    if (body == null || body['data'] == null) {
      throw Exception('Invalid profile response');
    }

    final sub = body['subscription'];
    if (sub != null) {
      await Get.find<AuthService>().setSubscription(
        Subscription.fromJson(Map<String, dynamic>.from(sub)),
      );
    }

    return InstituteProfile.fromJson(body['data']);
  }

  @override
  Future<void> deleteAccount() async {
    final response = await _apiClient.delete(
      ApiConstants.instituteAccountDelete,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to delete account');
    }
  }

  @override
  Future<Map<String, dynamic>> createRazorpayOrder({
    required int planId,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.razorpayCreateOrder,
      {'plan_id': planId},
    );
    if (response.status.connectionError) {
      throw Exception('No internet connection. Please check your network and try again.');
    }
    if (response.status.hasError) {
      _handleError(response, 'Failed to create payment order');
    }
    return Map<String, dynamic>.from(response.body['data']);
  }

  @override
  Future<void> verifyRazorpayPayment({
    required int planId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.razorpayVerifyPayment,
      {
        'plan_id': planId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );
    if (response.status.hasError) {
      _handleError(response, 'Payment verification failed');
    }

    final sub = response.body is Map ? response.body['subscription'] : null;
    if (sub != null) {
      await Get.find<AuthService>().setSubscription(
        Subscription.fromJson(Map<String, dynamic>.from(sub)),
      );
    }
  }

  @override
  Future<WhiteLabelStatus> getWhiteLabelStatus() async {
    final response = await _apiClient.get(ApiConstants.instituteWhiteLabel);
    if (response.status.hasError) {
      _handleError(response, 'Failed to fetch White Label status');
    }
    return WhiteLabelStatus.fromJson(Map<String, dynamic>.from(response.body['data']));
  }

  @override
  Future<Map<String, dynamic>> createWhiteLabelOrder() async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteWhiteLabel}/create-order',
      {},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to create payment order');
    }
    return Map<String, dynamic>.from(response.body['data']);
  }

  @override
  Future<WhiteLabelRecord> verifyWhiteLabelPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteWhiteLabel}/verify-payment',
      {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );
    if (response.status.hasError) {
      _handleError(response, 'Payment verification failed');
    }
    return WhiteLabelRecord.fromJson(Map<String, dynamic>.from(response.body['data']));
  }

  @override
  Future<WhiteLabelRecord> submitWhiteLabelBranding({
    required String appName,
    String? logoPath,
    String? primaryColor,
    String? secondaryColor,
  }) async {
    final fields = <String, dynamic>{
      'app_name': appName,
      if (primaryColor != null) 'primary_color': primaryColor,
      if (secondaryColor != null) 'secondary_color': secondaryColor,
    };
    final formData = FormData(fields);
    if (logoPath != null && logoPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'app_logo',
          MultipartFile(File(logoPath), filename: 'white_label_logo.jpg'),
        ),
      );
    }

    final response = await _apiClient.post(
      '${ApiConstants.instituteWhiteLabel}/branding',
      formData,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to submit branding');
    }
    return WhiteLabelRecord.fromJson(Map<String, dynamic>.from(response.body['data']));
  }

  @override
  Future<List<AddOnModel>> getAddOns() async {
    final response = await _apiClient.get(ApiConstants.instituteAddOns);
    if (response.status.hasError) {
      _handleError(response, 'Failed to load add-ons');
    }
    final data = response.body['data'] as List? ?? [];
    return data
        .map((json) => AddOnModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> createAddOnOrder(String addOnId) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteAddOns}/$addOnId/create-order',
      {},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to create payment order');
    }
    return Map<String, dynamic>.from(response.body['data']);
  }

  @override
  Future<void> verifyAddOnPayment({
    required String addOnId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteAddOns}/$addOnId/verify-payment',
      {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );
    if (response.status.hasError) {
      _handleError(response, 'Payment verification failed');
    }
  }

  @override
  Future<List<BirthdayModel>> getBirthdays() async {
    final response = await _apiClient.get(ApiConstants.instituteBirthdays);
    if (response.status.hasError) {
      _handleError(response, 'Failed to load birthdays');
    }
    final data = response.body['data'] as List? ?? [];
    return data
        .map((json) => BirthdayModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> sendBirthdayWish({
    required int studentId,
    required String studentName,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.instituteNotificationsSendPush,
      {
        'title': 'Happy Birthday! 🎂',
        'message': 'Wishing you a fantastic birthday, $studentName!',
        'target_type': 'specific_students',
        'target_ids': [studentId],
        'type': 'birthday_wish',
      },
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to send wish');
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final Map<String, dynamic> fields = Map.from(data);
    final String? logoUrl = fields['logo_url'];

    if (logoUrl != null && logoUrl.isNotEmpty && !logoUrl.startsWith('http')) {
      fields.remove('logo_url');
    }

    final formData = FormData(fields);

    if (logoUrl != null && logoUrl.isNotEmpty && !logoUrl.startsWith('http')) {
      formData.files.add(
        MapEntry(
          'logo_url',
          MultipartFile(File(logoUrl), filename: 'institute_logo.jpg'),
        ),
      );
    }

    final response = await _apiClient.post(
      ApiConstants.instituteProfileUpdate,
      formData,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update profile');
    }
  }

  @override
  Future<({String upiId, String? upiQrCodeUrl})> updatePaymentSettings({
    required String upiId,
    String? qrImagePath,
  }) async {
    // Always send as multipart so the backend treats it consistently
    // whether or not the user just picked a new QR image. When
    // [qrImagePath] is a local path (i.e. NOT an http URL the API
    // returned earlier), attach it as a file under `upi_qr_code`.
    final formData = FormData({'upi_id': upiId});
    if (qrImagePath != null &&
        qrImagePath.isNotEmpty &&
        !qrImagePath.startsWith('http')) {
      formData.files.add(
        MapEntry(
          'upi_qr_code',
          MultipartFile(qrImagePath, filename: 'upi_qr.png'),
        ),
      );
    }

    final response = await _apiClient.post(
      ApiConstants.institutePaymentUpdate,
      formData,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update payment settings');
    }

    final data = response.body is Map ? response.body['data'] : null;
    final newUpiId = (data is Map ? data['upi_id'] : null)?.toString() ?? upiId;
    final newQrUrl = (data is Map ? data['upi_qr_code_url'] : null)?.toString();
    return (upiId: newUpiId, upiQrCodeUrl: newQrUrl);
  }

  @override
  Future<WhatsAppSettings?> getWhatsAppSettings() async {
    final response = await _apiClient.get(
      ApiConstants.instituteWhatsAppSettings,
    );
    if (response.status.hasError) {
      if (response.statusCode == 404) return null;
      throw Exception(
        'Failed to fetch WhatsApp settings: ${response.statusText}',
      );
    }

    final body = response.body;
    if (body == null || body['data'] == null) return null;

    return WhatsAppSettings.fromJson(body['data']);
  }

  @override
  Future<WhatsAppSettings> saveWhatsAppSettings(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.instituteWhatsAppSettings,
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to save WhatsApp settings');
    }
    return WhatsAppSettings.fromJson(response.body['data']);
  }

  @override
  Future<WhatsAppSettings> updateWhatsAppSettings(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put(
      ApiConstants.instituteWhatsAppSettings,
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update WhatsApp settings');
    }
    return WhatsAppSettings.fromJson(response.body['data']);
  }

  @override
  Future<void> changePassword(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteChangePassword,
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to change password');
    }
  }

  @override
  Future<FeeListResponse> listFees({int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.instituteFees,
      query: {'page': page.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch fees: ${response.statusText}');
    }
    return FeeListResponse.fromJson(response.body['data']);
  }

  @override
  Future<FeeRecord> createFee(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.instituteFees, data);
    if (response.status.hasError) {
      _handleError(response, 'Failed to create fee record');
    }
    return FeeRecord.fromJson(response.body['data']);
  }

  @override
  Future<List<int>> exportFees() async {
    return _downloadFile(
      ApiConstants.instituteFeesExport,
      acceptHeader: 'application/pdf',
    );
  }

  @override
  Future<List<int>> downloadFeeReceipt(int feeId) async {
    return _downloadFile(
      ApiConstants.instituteReceiptDownload(feeId),
      acceptHeader: 'application/pdf',
    );
  }

  @override
  Future<FeeReportResponse> getFeeReport() async {
    final response = await _apiClient.get(ApiConstants.instituteReportFee);
    if (response.status.hasError) {
      throw Exception('Failed to fetch fee report: ${response.statusText}');
    }
    return FeeReportResponse.fromJson(response.body['data']);
  }

  @override
  Future<BatchFeeDetailResponse> getBatchFeeReport(int batchId) async {
    final response = await _apiClient.get(
      ApiConstants.instituteReportFee,
      query: {'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch batch fee report: ${response.statusText}',
      );
    }
    return BatchFeeDetailResponse.fromJson(response.body['data']);
  }

  @override
  Future<AttendanceReportResponse> getAttendanceReport() async {
    final response = await _apiClient.get(
      ApiConstants.instituteReportAttendance,
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch attendance report: ${response.statusText}',
      );
    }
    return AttendanceReportResponse.fromJson(response.body['data']);
  }

  @override
  Future<BatchAttendanceDetailResponse> getBatchAttendanceReport(
    int batchId,
  ) async {
    final response = await _apiClient.get(
      ApiConstants.instituteReportAttendance,
      query: {'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch batch attendance report: ${response.statusText}',
      );
    }
    return BatchAttendanceDetailResponse.fromJson(response.body['data']);
  }

  @override
  Future<PerformanceReportResponse> getPerformanceReport() async {
    final response = await _apiClient.get(
      ApiConstants.instituteReportPerformance,
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch performance report: ${response.statusText}',
      );
    }
    return PerformanceReportResponse.fromJson(response.body['data']);
  }

  @override
  Future<AnalyticsResponse> getAnalytics({int months = 6}) async {
    final response = await _apiClient.get(
      ApiConstants.instituteReportAnalytics,
      query: {'months': months.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch analytics: ${response.statusText}');
    }
    return AnalyticsResponse.fromJson(response.body['data']);
  }

  @override
  Future<BatchPerformanceDetailResponse> getBatchPerformanceReport(
    int batchId,
  ) async {
    final response = await _apiClient.get(
      ApiConstants.instituteReportPerformance,
      query: {'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch batch performance report: ${response.statusText}',
      );
    }
    return BatchPerformanceDetailResponse.fromJson(response.body['data']);
  }

  @override
  Future<List<int>> exportFeeReport() async {
    return _downloadFile(
      ApiConstants.instituteReportFeeExport,
      acceptHeader: 'application/pdf',
    );
  }

  @override
  Future<List<int>> exportAttendanceReport() async {
    return _downloadFile(
      ApiConstants.instituteReportAttendanceExport,
      acceptHeader: 'application/pdf',
    );
  }

  @override
  Future<List<int>> exportPerformanceReport() async {
    return _downloadFile(
      ApiConstants.instituteReportPerformanceExport,
      acceptHeader: 'application/pdf',
    );
  }

  @override
  Future<List<StudentBatchItem>> getStudentsForBatchReport(int batchId) async {
    final response = await _apiClient.get(
      ApiConstants.instituteReportStudent,
      query: {'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch batch students: ${response.statusText}');
    }
    final List<dynamic> items = response.body['data']?['items'] ?? [];
    return items
        .map(
          (json) => StudentBatchItem.fromJson(
            Map<String, dynamic>.from(json as Map),
          ),
        )
        .toList();
  }

  @override
  Future<StudentWiseReportData> getStudentWiseReport(int studentId) async {
    final response = await _apiClient.get(
      ApiConstants.instituteReportStudent,
      query: {'student_id': studentId.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch student report: ${response.statusText}');
    }
    return StudentWiseReportData.fromJson(
      Map<String, dynamic>.from(response.body['data']),
    );
  }

  @override
  Future<List<int>> exportStudentWiseReport(int studentId) async {
    return _downloadFile(
      '${ApiConstants.instituteReportStudentExport}?student_id=$studentId',
      acceptHeader: 'application/pdf',
    );
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
      throw Exception('Download failed: $e');
    }
  }

  @override
  Future<BatchListResponse> listBatches({int page = 1, String? search}) async {
    final query = <String, String>{'page': page.toString()};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    final response = await _apiClient.get(
      ApiConstants.instituteBatches,
      query: query,
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch batches: ${response.statusText}');
    }
    return BatchListResponse.fromJson(response.body['data']);
  }

  @override
  Future<Batch> createBatch(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.instituteBatches, data);
    if (response.status.hasError) {
      _handleError(response, 'Failed to create batch');
    }
    return Batch.fromJson(response.body['data']);
  }

  @override
  Future<Batch> updateBatch(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${ApiConstants.instituteBatches}/$id',
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update batch');
    }
    return Batch.fromJson(response.body['data']);
  }

  @override
  Future<void> deleteBatch(int id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.instituteBatches}/$id',
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to delete batch';
      throw Exception(message);
    }
  }

  @override
  Future<void> closeBatch(int id) async {
    final response = await _apiClient.post(
      ApiConstants.instituteCloseBatch(id),
      {},
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to close batch';
      throw Exception(message);
    }
  }

  @override
  Future<void> markAttendance(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteBatchAttendance,
      data,
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to mark attendance';
      throw Exception(message);
    }
  }

  @override
  Future<List<ExamModel>> getExams(int batchId) async {
    final response = await _apiClient.get(
      ApiConstants.instituteExams,
      query: {'batch_id': batchId.toString(), 'per_page': '100'},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch exams: ${response.statusText}');
    }

    final dynamic bodyData = response.body['data'];
    List<dynamic> data = [];

    if (bodyData is List) {
      data = bodyData;
    } else if (bodyData is Map && bodyData['data'] is List) {
      data = bodyData['data'];
    }

    return data.map((json) => ExamModel.fromJson(json)).toList();
  }

  @override
  Future<ExamModel> createExam(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.instituteExams, data);
    if (response.status.hasError) {
      _handleError(response, 'Failed to create exam');
    }
    return ExamModel.fromJson(response.body['data']);
  }

  @override
  Future<ExamModel> updateExam(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${ApiConstants.instituteExams}/$id',
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update exam');
    }
    return ExamModel.fromJson(response.body['data']);
  }

  @override
  Future<void> deleteExam(int id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.instituteExams}/$id',
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to delete exam';
      throw Exception(message);
    }
  }

  @override
  Future<ExamMarksData> getExamMarks(int examId) async {
    final response = await _apiClient.get(
      ApiConstants.instituteExamMarks(examId),
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch exam marks: ${response.statusText}');
    }

    final body = response.body['data'];
    return ExamMarksData(
      exam: ExamModel.fromJson(body['exam']),
      students: (body['students'] as List)
          .map((s) => ExamMarkRow.fromJson(s))
          .toList(),
      stats: ExamStats.fromJson(Map<String, dynamic>.from(body['stats'])),
    );
  }

  @override
  Future<ExamStats> saveExamMarks(
    int examId,
    List<Map<String, dynamic>> marks,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.instituteExamMarks(examId),
      {'marks': marks},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to save marks');
    }
    return ExamStats.fromJson(
      Map<String, dynamic>.from(response.body['data']['stats']),
    );
  }

  @override
  Future<List<TimetableSlot>> getTimetable({int? batchId, String? day}) async {
    final Map<String, String> query = {};
    if (batchId != null) {
      query['batch_id'] = batchId.toString();
    }
    if (day != null && day.isNotEmpty && day.toLowerCase() != 'all') {
      query['day'] = day.toLowerCase();
    }
    final response = await _apiClient.get(
      ApiConstants.instituteTimetable,
      query: query.isNotEmpty ? query : null,
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch timetable: ${response.statusText}');
    }

    final dynamic bodyData = response.body['data'];
    List<dynamic> data = [];

    if (bodyData is List) {
      data = bodyData;
    } else if (bodyData is Map && bodyData['data'] is List) {
      data = bodyData['data'];
    }

    return data.map((json) => TimetableSlot.fromJson(json)).toList();
  }

  @override
  Future<TimetableSlot> createTimetableSlot(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteTimetable,
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to create timetable slot');
    }
    return TimetableSlot.fromJson(response.body['data']);
  }

  @override
  Future<TimetableSlot> updateTimetableSlot(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put(
      '${ApiConstants.instituteTimetable}/$id',
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update timetable slot');
    }
    return TimetableSlot.fromJson(response.body['data']);
  }

  @override
  Future<void> deleteTimetableSlot(int id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.instituteTimetable}/$id',
    );
    if (response.status.hasError) {
      final message =
          response.body?['message'] ?? 'Failed to delete timetable slot';
      throw Exception(message);
    }
  }

  @override
  Future<List<HomeworkModel>> getHomeworks(int batchId) async {
    final response = await _apiClient.get(
      ApiConstants.instituteHomeworks,
      query: {'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch homeworks: ${response.statusText}');
    }

    final dynamic bodyData = response.body['data'];
    List<dynamic> data = [];

    if (bodyData is List) {
      data = bodyData;
    } else if (bodyData is Map && bodyData['data'] is List) {
      // Handle paginated response where the list is nested in another 'data' field
      data = bodyData['data'];
    }

    return data.map((json) => HomeworkModel.fromJson(json)).toList();
  }

  @override
  Future<HomeworkModel> getHomeworkDetails(int homeworkId) async {
    final response = await _apiClient.get(
      '${ApiConstants.instituteHomeworks}/$homeworkId',
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch homework details: ${response.statusText}',
      );
    }

    final body = response.body;
    if (body == null || body['data'] == null) {
      throw Exception('Invalid homework details response');
    }

    return HomeworkModel.fromJson(body['data']);
  }

  @override
  Future<List<AttendanceRecordModel>> getAttendance(
    String date,
    int batchId,
  ) async {
    final response = await _apiClient.get(
      ApiConstants.instituteBatchAttendance,
      query: {'date': date, 'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch attendance: ${response.statusText}');
    }

    final List<dynamic> data = response.body['data'] ?? [];
    return data.map((json) => AttendanceRecordModel.fromJson(json)).toList();
  }

  @override
  Future<dynamic> createHomework(Map<String, dynamic> data) async {
    final Map<String, dynamic> fields = {
      'batch_id': data['batch_id'],
      'title': data['title'],
      'description': data['description'],
      'due_date': data['due_date'],
    };

    if (data['attachment'] != null) {
      fields['attachment'] = MultipartFile(
        data['attachment'],
        filename: data['attachment'].split('/').last,
      );
    }

    final response = await _apiClient.post(
      ApiConstants.instituteHomeworks,
      FormData(fields),
    );

    if (response.status.hasError) {
      _handleError(response, 'Failed to create homework');
    }
    return response.body['data'];
  }

  @override
  Future<void> removeStudentFromBatch(int batchId, int studentId) async {
    final response = await _apiClient.post(
      ApiConstants.removeStudentFromBatch(batchId),
      {'student_id': studentId},
    );
    if (response.status.hasError) {
      final message =
          response.body?['message'] ?? 'Failed to remove student from batch';
      throw Exception(message);
    }
  }

  @override
  Future<dynamic> assignStudentsToBatch(
    int batchId,
    List<Map<String, dynamic>> students,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.assignStudentsToBatch(batchId),
      {'students': students},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to assign students to batch');
    }
    return response.body['data'];
  }

  @override
  Future<dynamic> submitHomeworkScore(
    int homeworkId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteHomeworks}/$homeworkId/score',
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to submit ratings');
    }
    return response.body['data'];
  }

  @override
  Future<List<ResourceModel>> getResources(int batchId) async {
    final response = await _apiClient.get(
      ApiConstants.instituteResources,
      query: {'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch resources: ${response.statusText}');
    }

    final dynamic bodyData = response.body['data'];
    List<dynamic> data = [];

    if (bodyData is List) {
      data = bodyData;
    } else if (bodyData is Map && bodyData['data'] is List) {
      data = bodyData['data'];
    }

    return data.map((json) => ResourceModel.fromJson(json)).toList();
  }

  @override
  Future<dynamic> uploadResource(Map<String, dynamic> data) async {
    final Map<String, dynamic> fields = Map.from(data);
    final String? filePath = fields.remove('file');

    final formData = FormData(fields);

    if (filePath != null) {
      formData.files.add(
        MapEntry(
          'file',
          MultipartFile(filePath, filename: filePath.split('/').last),
        ),
      );
    }

    final response = await _apiClient.post(
      ApiConstants.instituteResources,
      formData,
    );

    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to upload resource';
      throw Exception(message);
    }
    return response.body['data'];
  }

  @override
  Future<List<SchoolClassModel>> listClasses(int batchId) async {
    final response = await _apiClient.get(
      ApiConstants.instituteClasses,
      query: {'batch_id': batchId.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch classes: ${response.statusText}');
    }
    final data = response.body['data'] as List? ?? [];
    return data
        .map((json) => SchoolClassModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SchoolClassModel> createClass(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiConstants.instituteClasses, data);
    if (response.status.hasError) {
      _handleError(response, 'Failed to create class');
    }
    return SchoolClassModel.fromJson(response.body['data']);
  }

  @override
  Future<SchoolClassModel> updateClass(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put(
      '${ApiConstants.instituteClasses}/$id',
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update class');
    }
    return SchoolClassModel.fromJson(response.body['data']);
  }

  @override
  Future<void> deleteClass(int id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.instituteClasses}/$id',
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to delete class';
      throw Exception(message);
    }
  }

  @override
  Future<void> deleteResource(int id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.instituteResources}/$id',
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to delete resource';
      throw Exception(message);
    }
  }

  @override
  Future<List<int>> downloadResource(
    int resourceId, {
    Function(double)? onProgress,
  }) async {
    return _downloadFile(
      ApiConstants.downloadResource(resourceId),
      onProgress: onProgress,
    );
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get(ApiConstants.instituteNotifications);
    if (response.status.hasError) {
      throw Exception('Failed to fetch notifications: ${response.statusText}');
    }

    final List<dynamic> data = response.body['data'] ?? [];
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  @override
  Future<ExpenseListResponse> listExpenses({int page = 1}) async {
    final response = await _apiClient.get(
      ApiConstants.instituteExpenses,
      query: {'page': page.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch expenses: ${response.statusText}');
    }
    return ExpenseListResponse.fromJson(response.body['data']);
  }

  @override
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    final response = await _apiClient.get(
      ApiConstants.instituteExpenseCategories,
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch categories: ${response.statusText}');
    }
    final List<dynamic> data = response.body['data'] ?? [];
    return data.map((json) => ExpenseCategory.fromJson(json)).toList();
  }

  @override
  Future<ExpenseCategory> createExpenseCategory(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteExpenseCategories,
      data,
    );
    if (response.status.hasError) {
      throw Exception('Failed to create category: ${response.statusText}');
    }
    return ExpenseCategory.fromJson(response.body['data']);
  }

  @override
  Future<ExpenseModel> createExpense(Map<String, dynamic> data) async {
    final Map<String, dynamic> fields = Map.from(data);
    final String? receiptPath = fields.remove('receipt_image');

    final formData = FormData(fields);

    if (receiptPath != null && receiptPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'receipt_image',
          MultipartFile(receiptPath, filename: receiptPath.split('/').last),
        ),
      );
    }

    final response = await _apiClient.post(
      ApiConstants.instituteExpenses,
      formData,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to add expense');
    }
    return ExpenseModel.fromJson(response.body['data']);
  }

  @override
  Future<ExpenseAnalysis> getExpenseAnalysis(String month, String year) async {
    final response = await _apiClient.get(
      ApiConstants.instituteExpenseAnalysis,
      query: {'month': month, 'year': year},
    );
    if (response.status.hasError) {
      throw Exception(
        'Failed to fetch expense analysis: ${response.statusText}',
      );
    }
    return ExpenseAnalysis.fromJson(response.body);
  }

  @override
  Future<StaffListResponse> listStaff({int page = 1, String? search}) async {
    final response = await _apiClient.get(
      ApiConstants.instituteStaff,
      query: {
        'page': page.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch staff: ${response.statusText}');
    }
    return StaffListResponse.fromJson(response.body);
  }

  @override
  Future<void> deleteStaff(int id) async {
    final response = await _apiClient.delete(
      '${ApiConstants.instituteStaff}/$id',
    );
    if (response.status.hasError) {
      final message = response.body?['message'] ?? 'Failed to delete staff';
      throw Exception(message);
    }
  }

  @override
  Future<List<StaffRole>> getStaffRoles() async {
    final response = await _apiClient.get(ApiConstants.instituteStaffRoles);
    if (response.status.hasError) {
      throw Exception('Failed to fetch staff roles');
    }
    return (response.body as List).map((e) => StaffRole.fromJson(e)).toList();
  }

  @override
  Future<List<StaffDepartment>> getStaffDepartments() async {
    final response = await _apiClient.get(
      ApiConstants.instituteStaffDepartments,
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch staff departments');
    }
    return (response.body as List)
        .map((e) => StaffDepartment.fromJson(e))
        .toList();
  }

  @override
  Future<Staff> createStaff(
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    final formData = FormData(data);
    if (imagePath != null) {
      formData.files.add(
        MapEntry(
          'profile_image',
          MultipartFile(File(imagePath), filename: imagePath.split('/').last),
        ),
      );
    }

    final response = await _apiClient.post(
      ApiConstants.instituteStaff,
      formData,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to create staff');
    }

    return Staff.fromJson(response.body['data']);
  }

  @override
  Future<Staff> updateStaff(
    int id,
    Map<String, dynamic> data,
    String? imagePath,
  ) async {
    // Spoof PUT method for multipart/form-data updates
    data['_method'] = 'PUT';
    final formData = FormData(data);

    if (imagePath != null) {
      formData.files.add(
        MapEntry(
          'profile_image',
          MultipartFile(File(imagePath), filename: imagePath.split('/').last),
        ),
      );
    }

    final response = await _apiClient.post(
      '${ApiConstants.instituteStaff}/$id',
      formData,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update staff');
    }

    return Staff.fromJson(response.body['data']);
  }

  void _handleError(Response response, String defaultMessage) {
    if (response.statusCode == 422 && response.body?['errors'] != null) {
      throw ValidationException(response.body['errors']);
    }
    final message = response.body?['message'] ?? defaultMessage;
    throw Exception(message);
  }

  @override
  Future<String> sendStaffPassword(int id) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteStaff}/$id/send-password',
      {},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to send password');
    }
    return response.body?['message'] ??
        'A new password has been generated and emailed to the staff member.';
  }

  @override
  Future<Staff> changeStaffEmail(int id, String email) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteStaff}/$id/change-email',
      {'email': email},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update email');
    }
    return Staff.fromJson(response.body['data']);
  }

  @override
  Future<Staff> toggleStaffBlock(int id, bool blocked) async {
    final response = await _apiClient.post(
      '${ApiConstants.instituteStaff}/$id/toggle-block',
      {'blocked': blocked.toString()},
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to update login access');
    }
    return Staff.fromJson(response.body['data']);
  }

  @override
  Future<SalaryListResponse> getStaffSalaries(
    int staffId, {
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.instituteSalaries}/$staffId',
      query: {'page': page.toString()},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch salary history');
    }
    return SalaryListResponse.fromJson(response.body);
  }

  @override
  Future<SalaryPreview> getSalaryPreview(int staffId) async {
    final response = await _apiClient.get(
      '${ApiConstants.instituteSalaries}/preview/$staffId',
    );
    if (response.status.hasError) {
      throw Exception('Failed to load salary preview');
    }
    return SalaryPreview.fromJson(
      (response.body['data'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  @override
  Future<AttendanceListResponse> getStaffAttendance(
    int staffId, {
    int page = 1,
    String? month,
    String? year,
  }) async {
    final response = await _apiClient.get(
      '${ApiConstants.instituteAttendance}/$staffId',
      query: {'page': page.toString(), 'month': ?month, 'year': ?year},
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch attendance history');
    }
    return AttendanceListResponse.fromJson(response.body);
  }

  @override
  Future<AttendanceListResponse> getAttendanceLogs({
    int? page,
    String? month,
    String? year,
  }) async {
    final queryParams = {
      if (page != null) 'page': page.toString(),
      'month': ?month,
      'year': ?year,
    };
    final response = await _apiClient.get(
      ApiConstants.instituteAttendance,
      query: queryParams,
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch attendance logs');
    }
    return AttendanceListResponse.fromJson(response.body);
  }

  @override
  Future<void> logStaffAttendance(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteAttendance,
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to log attendance');
    }
  }

  @override
  Future<SalaryListResponse> getGlobalSalaries({
    int? page,
    String? month,
    String? year,
  }) async {
    final queryParams = {
      if (page != null) 'page': page.toString(),
      'month': ?month,
      'year': ?year,
    };
    final response = await _apiClient.get(
      ApiConstants.instituteSalaries,
      query: queryParams,
    );
    if (response.status.hasError) {
      throw Exception('Failed to fetch salaries');
    }
    return SalaryListResponse.fromJson(response.body);
  }

  @override
  Future<void> logSalary(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.instituteSalaries,
      data,
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to log salary');
    }
  }

  @override
  Future<InstituteSubscriptionData> getSubscriptionData() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.instituteSubscriptionAllData,
      );

      final body = response.body;
      if (body == null || body['data'] == null) {
        throw Exception('Failed to parse subscription data');
      }
      return InstituteSubscriptionData.fromJson(body['data']);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteDeviceSession(int sessionId) async {
    final response = await _apiClient.delete(
      ApiConstants.instituteDeleteDeviceSession(sessionId),
    );
    if (response.status.hasError) {
      _handleError(response, 'Failed to delete device session');
    }
  }
}

import 'package:tuoora/data/models/institute_subscription_model.dart';
import 'package:tuoora/data/models/batch_model.dart';
import 'package:tuoora/data/models/institute_profile_model.dart';
import 'package:tuoora/data/models/staff_model.dart';
import 'package:tuoora/data/models/whatsapp_settings_model.dart';
import 'package:tuoora/presentation/institute/models/expense_model.dart';
import 'package:tuoora/presentation/institute/models/fee_record.dart';
import 'package:tuoora/presentation/institute/models/report_models.dart';
import 'package:tuoora/presentation/institute/models/homework_model.dart';
import 'package:tuoora/presentation/institute/models/exam_model.dart';
import 'package:tuoora/presentation/institute/models/timetable_model.dart';
import 'package:tuoora/presentation/institute/models/resource_model.dart';
import 'package:tuoora/presentation/institute/models/attendance_record_model.dart';
import 'package:tuoora/data/models/notification_model.dart';
import 'package:tuoora/data/models/white_label_model.dart';
import 'package:tuoora/presentation/institute/models/birthday_model.dart';
import 'package:tuoora/presentation/institute/models/add_on_model.dart';
import 'package:tuoora/presentation/institute/models/school_class_model.dart';

abstract class InstituteRepositoryImpl {
  Future<InstituteProfile> getProfile();
  Future<InstituteSubscriptionData> getSubscriptionData();
  Future<void> updateProfile(Map<String, dynamic> data);

  Future<void> deleteAccount();

  Future<({String upiId, String? upiQrCodeUrl})> updatePaymentSettings({
    required String upiId,
    String? qrImagePath,
  });

  // Razorpay
  Future<Map<String, dynamic>> createRazorpayOrder({required int planId});
  Future<void> verifyRazorpayPayment({
    required int planId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  // White Label add-on
  Future<WhiteLabelStatus> getWhiteLabelStatus();
  Future<Map<String, dynamic>> createWhiteLabelOrder();
  Future<WhiteLabelRecord> verifyWhiteLabelPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });
  Future<WhiteLabelRecord> submitWhiteLabelBranding({
    required String appName,
    String? logoPath,
    String? primaryColor,
    String? secondaryColor,
  });

  // Generic Add-ons catalog (flag/quota kind — White Label above keeps its
  // own dedicated flow)
  Future<List<AddOnModel>> getAddOns();
  Future<Map<String, dynamic>> createAddOnOrder(String addOnId);
  Future<void> verifyAddOnPayment({
    required String addOnId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  });

  // Birthdays
  Future<List<BirthdayModel>> getBirthdays();
  Future<void> sendBirthdayWish({required int studentId, required String studentName});

  // Authentication
  Future<String> registerInstitute(Map<String, dynamic> data);
  Future<String> verifyOtp(Map<String, dynamic> data);

  // WhatsApp Settings
  Future<WhatsAppSettings?> getWhatsAppSettings();
  Future<WhatsAppSettings> saveWhatsAppSettings(Map<String, dynamic> data);
  Future<WhatsAppSettings> updateWhatsAppSettings(Map<String, dynamic> data);

  // Password Management
  Future<void> changePassword(Map<String, dynamic> data);

  // Fees Management
  Future<FeeListResponse> listFees({int page = 1});
  Future<FeeRecord> createFee(Map<String, dynamic> data);
  Future<List<int>> exportFees();

  // Downloads the PDF receipt for a single fee record.
  Future<List<int>> downloadFeeReceipt(int feeId);

  // Reports
  Future<FeeReportResponse> getFeeReport();
  Future<BatchFeeDetailResponse> getBatchFeeReport(int batchId);
  Future<List<int>> exportFeeReport();

  // Attendance Reports
  Future<AttendanceReportResponse> getAttendanceReport();
  Future<BatchAttendanceDetailResponse> getBatchAttendanceReport(int batchId);
  Future<List<int>> exportAttendanceReport();

  // Performance Reports
  Future<PerformanceReportResponse> getPerformanceReport();
  Future<BatchPerformanceDetailResponse> getBatchPerformanceReport(int batchId);
  Future<List<int>> exportPerformanceReport();

  // Student Wise Report
  Future<List<StudentBatchItem>> getStudentsForBatchReport(int batchId);
  Future<StudentWiseReportData> getStudentWiseReport(int studentId);
  Future<List<int>> exportStudentWiseReport(int studentId);

  // Business Analytics
  Future<AnalyticsResponse> getAnalytics({int months = 6});

  // Batches Management
  Future<BatchListResponse> listBatches({int page = 1, String? search});
  Future<Batch> createBatch(Map<String, dynamic> data);
  Future<Batch> updateBatch(int id, Map<String, dynamic> data);
  Future<void> deleteBatch(int id);
  Future<void> closeBatch(int id);

  // Attendance
  Future<List<AttendanceRecordModel>> getAttendance(String date, int batchId);
  Future<void> markAttendance(Map<String, dynamic> data);

  // Homework
  Future<List<HomeworkModel>> getHomeworks(int batchId);
  Future<HomeworkModel> getHomeworkDetails(int homeworkId);
  Future<dynamic> createHomework(Map<String, dynamic> data);
  Future<dynamic> submitHomeworkScore(
    int homeworkId,
    Map<String, dynamic> data,
  );

  // Exams
  Future<List<ExamModel>> getExams(int batchId);
  Future<ExamModel> createExam(Map<String, dynamic> data);
  Future<ExamModel> updateExam(int id, Map<String, dynamic> data);
  Future<void> deleteExam(int id);
  Future<ExamMarksData> getExamMarks(int examId);
  Future<ExamStats> saveExamMarks(int examId, List<Map<String, dynamic>> marks);

  // Timetable
  Future<List<TimetableSlot>> getTimetable({int? batchId, String? day});
  Future<TimetableSlot> createTimetableSlot(Map<String, dynamic> data);
  Future<TimetableSlot> updateTimetableSlot(int id, Map<String, dynamic> data);
  Future<void> deleteTimetableSlot(int id);

  // Batch Students
  Future<void> removeStudentFromBatch(int batchId, int studentId);
  Future<dynamic> assignStudentsToBatch(
    int batchId,
    List<Map<String, dynamic>> students,
  );

  // Resources
  Future<List<ResourceModel>> getResources(int batchId);
  Future<dynamic> uploadResource(Map<String, dynamic> data);

  // Classes (subjects + teacher assignment within a batch)
  Future<List<SchoolClassModel>> listClasses(int batchId);
  Future<SchoolClassModel> createClass(Map<String, dynamic> data);
  Future<SchoolClassModel> updateClass(int id, Map<String, dynamic> data);
  Future<void> deleteClass(int id);
  Future<List<int>> downloadResource(
    int resourceId, {
    Function(double)? onProgress,
  });

  // Notifications
  Future<List<NotificationModel>> getNotifications();

  // Expenses
  Future<ExpenseListResponse> listExpenses({int page = 1});
  Future<List<ExpenseCategory>> getExpenseCategories();
  Future<ExpenseCategory> createExpenseCategory(Map<String, dynamic> data);
  Future<ExpenseModel> createExpense(Map<String, dynamic> data);
  Future<ExpenseAnalysis> getExpenseAnalysis(String month, String year);

  // Staff
  Future<StaffListResponse> listStaff({int page = 1, String? search});
  Future<void> deleteStaff(int id);
  Future<List<StaffRole>> getStaffRoles();
  Future<List<StaffDepartment>> getStaffDepartments();
  Future<Staff> createStaff(Map<String, dynamic> data, String? imagePath);
  Future<Staff> updateStaff(
    int id,
    Map<String, dynamic> data,
    String? imagePath,
  );
  Future<String> sendStaffPassword(int id);
  Future<Staff> changeStaffEmail(int id, String email);
  Future<Staff> toggleStaffBlock(int id, bool blocked);
  Future<SalaryListResponse> getStaffSalaries(int staffId, {int page = 1});
  Future<SalaryPreview> getSalaryPreview(int staffId);
  Future<AttendanceListResponse> getStaffAttendance(
    int staffId, {
    int page = 1,
    String? month,
    String? year,
  });
  Future<AttendanceListResponse> getAttendanceLogs({
    int? page,
    String? month,
    String? year,
  });
  Future<void> logStaffAttendance(Map<String, dynamic> data);
  Future<SalaryListResponse> getGlobalSalaries({
    int? page,
    String? month,
    String? year,
  });
  Future<void> logSalary(Map<String, dynamic> data);
  Future<void> deleteResource(int id);
  Future<void> deleteDeviceSession(int sessionId);
}

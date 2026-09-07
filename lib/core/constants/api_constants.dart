class ApiConstants {
  static const String baseUrl = 'https://tuoora.com/api/v1';

  // Public, unauthenticated — fetched once at launch using the build's
  // baked-in institute_id (see BrandingService).
  static const String appBranding = '/app-branding';

  // Institute White Label add-on (purchase + branding submission)
  static const String instituteWhiteLabel = '/institute/whitelabel';

  // Generic Add-ons catalog (flag/quota kind — White Label keeps using
  // instituteWhiteLabel above, this covers everything else)
  static const String instituteAddOns = '/institute/addons';

  // Auth Endpoints
  static const String instituteLogin = '/institute/login';
  static const String instituteRegister = '/institute/register';
  static const String instituteVerifyOtp = '/institute/verify-otp';
  static const String instituteLogout = '/institute/logout';
  static const String studentLogin = '/student/login';
  static const String studentLogout = '/student/logout';
  static const String authRefresh = '/auth/refresh';
  static const String studentNotificationSettings =
      '/student/notification-settings';
  static const String studentProfile = '/student/profile';
  static const String studentProfileAvatar = '/student/profile/avatar';
  static const String studentAccountDelete = '/student/profile/delete';
  static const String studentFeedback = '/student/feedback';
  static const String studentHomeworks = '/student/homeworks';
  static String studentHomeworkDetail(int id) => '/student/homeworks/$id';
  static String studentHomeworkAttachment(int id) =>
      '/student/homeworks/$id/attachment';
  static String studentHomeworkAttachmentDownload(int id) =>
      '/student/homeworks/$id/attachment/download';
  static const String studentExams = '/student/exams';
  static String studentExamDetail(int id) => '/student/exams/$id';
  static const String studentTimetable = '/student/timetable';
  static const String studentBirthdays = '/student/birthdays';
  static const String studentIdCard = '/student/id-card';
  static const String studentAttendance = '/student/attendance';
  static const String studentReport = '/student/report';
  static const String studentInstitute = '/student/institute';
  static const String studentResources = '/student/resources';
  static const String studentDashboard = '/student/dashboard';
  static const String studentFees = '/student/fees';
  static const String studentPaymentInfo = '/student/payment-info';
  static const String studentReceipts = '/student/receipts';
  static String studentReceiptDetail(int id) => '/student/receipts/$id';
  static String studentFeeDownload(int id) => '/student/fees/$id/download';
  static const String studentNotifications = '/student/notifications';

  // Institute Endpoints
  static const String instituteStudents = '/institute/students';
  static const String instituteProfile = '/institute/profile';
  static const String instituteProfileUpdate = '/institute/profile/update';
  static const String instituteAccountDelete = '/institute/profile/delete';
  static const String institutePaymentUpdate =
      '/institute/profile/payment/update';
  static String instituteDeleteDeviceSession(int sessionId) =>
      '/institute/profile/device-sessions/$sessionId';
  static const String instituteBatches = '/institute/batches';
  static const String instituteClasses = '/institute/classes';
  static const String instituteChangePassword =
      '/institute/profile/change-password';
  static const String instituteWhatsAppSettings =
      '/institute/whatsapp-settings';
  static const String instituteFees = '/institute/fees';
  static const String instituteFeesExport = '/institute/fees/export';
  static String instituteReceiptDownload(int id) =>
      '/institute/receipt/$id/download';
  static const String instituteDailyUpdates = '/institute/daily-updates';
  static const String instituteAttendance = '/institute/attendance';
  static const String instituteHomeworks = '/institute/homeworks';
  static const String instituteExams = '/institute/exams';
  static String instituteExamMarks(int id) => '/institute/exams/$id/marks';
  static const String instituteTimetable = '/institute/timetable';
  static const String instituteResources = '/institute/resources';
  static const String instituteBatchAttendance = '/institute/batch-attendance';
  static String downloadResource(int resourceId) =>
      '/institute/resources/$resourceId/download';
  static const String instituteForgotPassword = '/institute/forgot-password';
  static const String instituteResetPassword = '/institute/reset-password';
  static const String instituteNotifications = '/institute/notifications';
  static const String instituteNotificationsSendPush =
      '/institute/notifications/send-push';
  static const String instituteBirthdays = '/institute/birthdays';
  static const String instituteExpenses = '/institute/expenses';
  static const String instituteExpenseCategories =
      '/institute/expenses/categories';
  static const String instituteExpenseAnalysis = '/institute/expenses/analysis';
  static const String instituteLeads = '/institute/leads';
  static const String instituteNotes = '/institute/notes';
  static const String instituteNoteCategories = '/institute/note-categories';
  static const String instituteStaff = '/institute/staff';
  static const String instituteStaffRoles = '/institute/staff-roles';
  static const String instituteStaffDepartments =
      '/institute/staff-departments';
  static const String instituteSalaries = '/institute/salaries';
  static const String instituteSubscriptionAllData =
      '/institute/subscriptions/all-data';
  static const String razorpayCreateOrder =
      '/institute/subscription/create-order';
  static const String razorpayVerifyPayment =
      '/institute/subscription/verify-payment';

  static String removeStudentFromBatch(int batchId) =>
      '/institute/batches/$batchId/remove-student';

  static String assignStudentsToBatch(int batchId) =>
      '/institute/batches/$batchId/assign-students';

  static String instituteCloseBatch(int batchId) =>
      '/institute/batches/$batchId/close';

  // Reports Endpoints
  static const String instituteReportFee = '/institute/reports/fee';
  static const String instituteReportFeeExport =
      '/institute/reports/fee/export';

  // Attendance Reports
  static const String instituteReportAttendance =
      '/institute/reports/attendance';
  static const String instituteReportAttendanceExport =
      '/institute/reports/attendance/export';

  // Performance Reports
  static const String instituteReportPerformance =
      '/institute/reports/performance';
  static const String instituteReportPerformanceExport =
      '/institute/reports/performance/export';

  // Business Analytics
  static const String instituteReportAnalytics =
      '/institute/reports/analytics';

  // FCM Endpoints
  static const String fcmToken = '/fcm-token';

  // Chat Endpoints
  static const String chatList = '/chat/list';
  static const String chatContacts = '/chat/contacts';
  static const String chatSend = '/chat/send';
  static const String chatMarkReceived = '/chat/mark-received';
  static const String chatMarkRead = '/chat/mark-read';
  static const String chatConversation = '/chat/conversation';
  static String chatMessages(String userId) => '/chat/messages/$userId';
}

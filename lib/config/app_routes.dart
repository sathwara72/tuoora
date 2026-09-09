class AppRoutes {
  static const String splash = '/';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';

  static const String studentDashboard = '/student/dashboard';
  static const String studentAttendance = '/student/attendance';
  static const String studentSettings = '/student/settings';
  static const String studentNotifications = '/student/notifications';
  static const String studentHomework = '/student/homework';
  static const String studentHomeworkDetail = '/student/homework-detail';
  static const String studentAssignmentDetail = '/student/assignment-detail';
  static const String studentExams = '/student/exams';
  static const String studentExamDetail = '/student/exam-detail';
  static const String studentTimetable = '/student/timetable';
  static const String studentBirthdays = '/student/birthdays';
  static const String studentIdCard = '/student/id-card';
  static const String studentAttachmentPreview = '/student/attachment-preview';
  static const String studentFeeReceipt = '/student/fee-receipt';
  static const String studentPayFees = '/student/pay-fees';
  static const String studentInstitute = '/student/institute';
  static const String studentFeeHistory = '/student/fee-history';
  static const String studentChat = '/student/chat';
  static const String studentCreateChat = '/student/chats/create';
  static const String studentChatMessages = '/student/chats/messages';
  static const String studentFeeReminder = '/student/fee-reminder';
  static const String studentEventDetail = '/student/event-detail';
  static const String studentHolidayDetail = '/student/holiday-detail';
  static const String studentReports = '/student/reports';
  static const String studentReceiptsList = '/student/receipts-list';
  static const String studentNotificationPreferences =
      '/student/notification-preferences';
  static const String studentStudyMaterial = '/student/study-material';
  static const String studentStudyMaterialDetail =
      '/student/study-material/detail';
  static const String studentFeedback = '/student/feedback';

  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherForgotPassword = '/teacher/forgot-password';
  static const String teacherResetPassword = '/teacher/reset-password';
  static const String teacherChangePassword = '/teacher/change-password';
  static const String teacherProfile = '/teacher/profile';
  static const String teacherBatches = '/teacher/batches';
  static const String teacherBatchDetails = '/teacher/batches/details';
  static const String teacherBatchStudents = '/teacher/batches/students';
  static const String teacherAssignStudents = '/teacher/batches/students/assign';
  static const String teacherMarkAttendance = '/teacher/batches/attendance';
  static const String teacherSelfAttendance = '/teacher/self-attendance';
  static const String teacherBatchHomework = '/teacher/batches/homework';
  static const String teacherAddHomework = '/teacher/batches/homework/add';
  static const String teacherHomeworkGrading = '/teacher/batches/homework/grade';
  static const String teacherBatchExams = '/teacher/batches/exams';
  static const String teacherAddExam = '/teacher/batches/exams/add';
  static const String teacherExamMarks = '/teacher/batches/exams/marks';
  static const String teacherBatchTimetable = '/teacher/batches/timetable';
  static const String teacherAddTimetableSlot =
      '/teacher/batches/timetable/add';
  static const String teacherFees = '/teacher/batches/fees';
  static const String teacherBatchResources = '/teacher/batches/resources';
  static const String teacherSalaries = '/teacher/salaries';

  static const String instituteDashboard = '/institute/dashboard';
  static const String instituteStudents = '/institute/students';
  static const String instituteStudentProfile = '/institute/students/profile';
  static const String instituteAddEditStudent = '/institute/students/add/edit';
  static const String instituteFees = '/institute/fees';
  static const String instituteRecordFee = '/institute/fees/record';
  static const String instituteFeeReceipt = '/institute/fees/receipt';
  static const String instituteBatches = '/institute/batches';
  static const String instituteBirthdays = '/institute/birthdays';
  static const String instituteMarkAttendance = '/institute/batches/mark';
  static const String instituteBatchDetails = '/institute/batches/details';
  static const String instituteEditProfile = '/institute/edit-profile';
  static const String instituteProfile = '/institute/profile';
  static const String instituteSettings = '/institute/profile/settings';
  static const String instituteChangePassword =
      '/institute/profile/changePassword';
  static const String instituteSubscription = '/institute/profile/subscription';
  static const String instituteWhiteLabel = '/institute/profile/white-label';
  static const String instituteAddOns = '/institute/profile/add-ons';
  static const String instituteWhatsApp = '/institute/profile/whatsapp';
  static const String instituteUpiPaymentSettings =
      '/institute/profile/upi-payment';
  static const String instituteFeeReport = '/institute/reports/fee-main';
  static const String instituteAttendanceReport =
      '/institute/reports/attendance';
  static const String institutePerformanceReport =
      '/institute/reports/performance';
  static const String instituteAnalytics = '/institute/reports/analytics';
  static const String instituteUpdates = '/institute/updates';
  static const String instituteCreateUpdate = '/institute/updates/create';
  static const String instituteNotifications = '/institute/notifications';
  static const String instituteMain = '/institute/main';
  static const String instituteBillingHistory =
      '/institute/profile/billing-history';
  static const String instituteAddBatch = '/institute/batches/add';
  static const String instituteEditBatch = '/institute/batches/edit';
  static const String instituteFeeTransactionHistory =
      '/institute/students/transaction-history';
  static const String instituteSignup = '/institute/signup';
  static const String instituteOtp = '/institute/otp';
  static const String instituteProfileSetup = '/institute/profile-setup';
  static const String instituteBatchReportDetail = '/institute/reports/detail';
  static const String instituteStudentWiseReport =
      '/institute/reports/student-wise';
  static const String instituteReports = '/institute/reports';
  static const String instituteForgotPassword = '/institute/forgot-password';
  static const String instituteResetPassword = '/institute/reset-password';
  static const String instituteBatchStudents = '/institute/batches/students';
  static const String instituteAssignToBatch = '/institute/batches/assign';
  static const String instituteBatchHomework = '/institute/batches/homework';
  static const String instituteAddHomework = '/institute/batches/homework/add';
  static const String instituteHomeworkRating =
      '/institute/batches/homework/rating';
  static const String instituteBatchExams = '/institute/batches/exams';
  static const String instituteAddExam = '/institute/batches/exams/add';
  static const String instituteExamMarks = '/institute/batches/exams/marks';
  static const String instituteTimetable = '/institute/timetable';
  static const String instituteBatchTimetable = '/institute/batches/timetable';
  static const String instituteAddTimetableSlot =
      '/institute/batches/timetable/add';
  static const String instituteBatchResources = '/institute/batches/resources';
  static const String instituteBatchClasses = '/institute/batches/classes';
  static const String instituteResourceDetail =
      '/institute/batches/resources/detail';
  static const String instituteLeads = '/institute/leads';
  static const String instituteAddEditLead = '/institute/leads/add-edit';
  static const String instituteLeadDetails = '/institute/leads/details';
  static const String instituteNotes = '/institute/notes';
  static const String instituteAddEditNote = '/institute/notes/add-edit';
  static const String instituteChats = '/institute/chats';
  static const String instituteCreateChat = '/institute/chats/create';
  static const String instituteChatMessages = '/institute/chats/messages';
  static const String instituteStaffs = '/institute/staffs';
  static const String instituteStaffDetails = '/institute/staffs/details';
  static const String instituteAddEditStaff = '/institute/staffs/add-edit';
  static const String instituteSalaryHistory =
      '/institute/staffs/salary-history';
  static const String instituteStaffAttendance = '/institute/staffs/attendance';
  static const String instituteLogStaffAttendance =
      '/institute/staffs/log-attendance';
  static const String instituteAddSalary = '/institute/staffs/add-salary';
  static const String instituteExpenses = '/institute/expenses';
  static const String instituteAddExpense = '/institute/expenses/add';
  static const String instituteExpenseAnalysis = '/institute/expenses/analysis';
}

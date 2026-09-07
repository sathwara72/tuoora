import 'package:tuoora/data/repositories/student_notifications_repository.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/presentation/institute/bindings/institute_binding.dart';
import 'package:tuoora/presentation/institute/view/batches_screen.dart';
import 'package:tuoora/presentation/institute/view/birthdays_screen.dart';
import 'package:tuoora/presentation/institute/view/fee_transaction_history_screen.dart';
import 'package:tuoora/presentation/institute/view/fees_screen.dart';
import 'package:tuoora/presentation/institute/view/fee_receipt_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_main_screen.dart';
import 'package:tuoora/presentation/institute/view/add_student_screen.dart';
import 'package:tuoora/presentation/institute/view/batch_details_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_profile_view_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_settings_screen.dart';
import 'package:tuoora/presentation/institute/view/mark_attendance_screen.dart';
import 'package:tuoora/presentation/institute/view/student_profile_screen.dart'
    as institute_student_profile;
import 'package:tuoora/presentation/institute/view/record_fee_screen.dart';
import 'package:tuoora/presentation/institute/view/edit_profile_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_change_password_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_subscription_screen.dart';
import 'package:tuoora/presentation/institute/view/white_label_screen.dart';
import 'package:tuoora/presentation/institute/view/add_ons_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_whatsapp_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_upi_payment_settings_screen.dart';
import 'package:tuoora/presentation/institute/view/fee_report_screen.dart';
import 'package:tuoora/presentation/institute/view/attendance_report_screen.dart';
import 'package:tuoora/presentation/institute/view/performance_report_screen.dart';
import 'package:tuoora/presentation/institute/view/analytics_screen.dart';
import 'package:tuoora/presentation/institute/view/reports_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_updates_screen.dart';
import 'package:tuoora/presentation/institute/view/create_update_screen.dart';
import 'package:tuoora/presentation/institute/view/batch_report_detail_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_notifications_screen.dart';
import 'package:tuoora/presentation/institute/view/billing_history_screen.dart';
import 'package:tuoora/presentation/institute/view/add_edit_batch_screen.dart';
import 'package:tuoora/presentation/institute/view/batch_students_screen.dart';
import 'package:tuoora/presentation/institute/view/assign_to_batch_screen.dart';
import 'package:tuoora/presentation/institute/view/batch_homework_screen.dart';
import 'package:tuoora/presentation/institute/view/add_homework_screen.dart';
import 'package:tuoora/presentation/institute/view/homework_rating_screen.dart';
import 'package:tuoora/presentation/institute/view/batch_exams_screen.dart';
import 'package:tuoora/presentation/institute/view/add_exam_screen.dart';
import 'package:tuoora/presentation/institute/view/exam_marks_screen.dart';
import 'package:tuoora/presentation/institute/view/batch_timetable_screen.dart';
import 'package:tuoora/presentation/institute/view/add_timetable_slot_screen.dart';
import 'package:tuoora/presentation/institute/view/batch_resources_screen.dart';
import 'package:tuoora/presentation/institute/view/resource_detail_screen.dart';
import 'package:tuoora/presentation/institute/view/students_registry_screen.dart';
import 'package:tuoora/presentation/teacher/bindings/teacher_binding.dart';
import 'package:tuoora/presentation/teacher/bindings/teacher_auth_binding.dart';
import 'package:tuoora/presentation/teacher/view/teacher_dashboard_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_forgot_password_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_reset_password_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_change_password_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_batches_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_batch_details_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_profile_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_mark_attendance_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_self_attendance_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_batch_homework_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_add_homework_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_homework_grading_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_batch_exams_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_add_exam_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_exam_marks_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_batch_timetable_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_add_timetable_slot_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_fees_screen.dart';
import 'package:tuoora/presentation/teacher/view/teacher_salary_screen.dart';
import 'package:tuoora/presentation/student/bindings.dart';
import 'package:tuoora/presentation/student/view/payment_history_screen.dart';
import 'package:tuoora/presentation/shared/bindings/auth_binding.dart';
import 'package:tuoora/presentation/institute/bindings/forgot_password_binding.dart';
import 'package:tuoora/presentation/shared/view/login_screen.dart';
import 'package:tuoora/presentation/institute/view/forgot_password_screen.dart';
import 'package:tuoora/presentation/institute/view/reset_password_screen.dart';
import 'package:tuoora/presentation/student/view/student_profile_screen.dart';
import 'package:tuoora/presentation/student/view/student_notification_screen.dart'
    as shared;
import 'package:tuoora/presentation/student/view/student_main_screen.dart';
import 'package:tuoora/presentation/student/view/homework_detail_screen.dart';
import 'package:tuoora/presentation/student/view/student_assignment_detail_screen.dart';
import 'package:tuoora/presentation/student/view/student_exams_screen.dart';
import 'package:tuoora/presentation/student/view/student_exam_detail_screen.dart';
import 'package:tuoora/presentation/student/view/student_timetable_screen.dart';
import 'package:tuoora/presentation/student/view/batch_birthdays_screen.dart';
import 'package:tuoora/presentation/student/view/student_id_card_screen.dart';
import 'package:tuoora/presentation/student/view/student_attachment_preview_screen.dart';
import 'package:tuoora/presentation/student/view/student_pay_fees_screen.dart';
import 'package:tuoora/presentation/student/view/student_receipt_screen.dart';
import 'package:tuoora/presentation/student/view/student_chat_messages_screen.dart';
import 'package:tuoora/presentation/student/view/student_fee_reminder_screen.dart';
import 'package:tuoora/presentation/student/view/student_event_detail_screen.dart';
import 'package:tuoora/presentation/student/view/student_holiday_detail_screen.dart';
import 'package:tuoora/presentation/student/view/student_reports_screen.dart';
import 'package:tuoora/presentation/student/view/student_institute_screen.dart';
import 'package:tuoora/presentation/student/view/student_receipts_list_screen.dart';
import 'package:tuoora/presentation/student/controllers/student_receipts_list_controller.dart';
import 'package:tuoora/presentation/student/controllers/fees_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_notifications_controller.dart';
import 'package:tuoora/presentation/student/view/student_notification_preferences_screen.dart';
import 'package:tuoora/presentation/student/controllers/student_notification_preferences_controller.dart';
import 'package:tuoora/presentation/student/view/student_study_material_screen.dart';
import 'package:tuoora/presentation/student/controllers/student_study_material_controller.dart';
import 'package:tuoora/presentation/student/view/student_study_material_detail_screen.dart';
import 'package:tuoora/presentation/student/controllers/student_study_material_detail_controller.dart';
import 'package:tuoora/presentation/student/view/student_feedback_screen.dart';
import 'package:tuoora/presentation/student/controllers/student_feedback_controller.dart';
import 'package:tuoora/presentation/shared/view/role_selection_screen.dart';
import 'package:tuoora/presentation/shared/bindings/splash_binding.dart';
import 'package:tuoora/presentation/shared/view/splash_screen.dart';
import 'package:tuoora/presentation/institute/bindings/signup_binding.dart';
import 'package:tuoora/presentation/institute/view/institute_signup_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_otp_screen.dart';
import 'package:tuoora/presentation/institute/view/institute_profile_setup_screen.dart';
import 'package:tuoora/presentation/institute/view/leads_management_screen.dart';
import 'package:tuoora/presentation/institute/view/add_edit_lead_screen.dart';
import 'package:tuoora/presentation/institute/view/lead_details_screen.dart';
import 'package:tuoora/presentation/institute/view/notes_list_screen.dart';
import 'package:tuoora/presentation/institute/view/add_edit_note_screen.dart';
import 'package:tuoora/presentation/institute/view/chat_list_screen.dart';
import 'package:tuoora/presentation/institute/view/create_chat_screen.dart';
import 'package:tuoora/presentation/institute/view/chat_messages_screen.dart';
import 'package:tuoora/presentation/institute/view/staff_main_screen.dart';
import 'package:tuoora/presentation/institute/view/staff_profile_screen.dart';
import 'package:tuoora/presentation/institute/view/add_edit_staff_screen.dart';
import 'package:tuoora/presentation/institute/view/salary_history_screen.dart';
import 'package:tuoora/presentation/institute/view/staff_attendance_screen.dart';
import 'package:tuoora/presentation/institute/view/log_attendance_screen.dart';
import 'package:tuoora/presentation/institute/view/add_salary_screen.dart';
import 'package:tuoora/presentation/institute/view/expenses_screen.dart';
import 'package:tuoora/presentation/institute/view/add_expense_screen.dart';
import 'package:tuoora/presentation/institute/view/expense_analysis_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    // Student routes
    GetPage(
      name: AppRoutes.studentDashboard,
      page: () => const StudentMainScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentAttendance,
      page: () => const StudentMainScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentSettings,
      page: () => const StudentProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.studentNotifications,
      page: () => const shared.StudentNotificationScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StudentNotificationsController>(
          () => StudentNotificationsController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.studentHomework,
      page: () => const StudentMainScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentHomeworkDetail,
      page: () => const StudentHomeworkDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.studentAssignmentDetail,
      page: () => const StudentAssignmentDetailScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentExams,
      page: () => const StudentExamsScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentExamDetail,
      page: () => const StudentExamDetailScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentTimetable,
      page: () => const StudentTimetableScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentBirthdays,
      page: () => const BatchBirthdaysScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentIdCard,
      page: () => const StudentIdCardScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentAttachmentPreview,
      page: () => const StudentAttachmentPreviewScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentFeeReceipt,
      page: () => const StudentReceiptScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentPayFees,
      page: () => const StudentPayFeesScreen(),
      binding: StudentBinding(),
    ),
    GetPage(
      name: AppRoutes.studentInstitute,
      page: () => const StudentInstituteScreen(),
    ),
    GetPage(
      name: AppRoutes.studentFeeHistory,
      page: () => const PaymentHistoryScreen(title: AppStrings.feeHistory),
    ),

    GetPage(
      name: AppRoutes.studentChat,
      page: () => const StudentChatMessagesScreen(),
    ),
    GetPage(
      name: AppRoutes.studentFeeReminder,
      page: () => const StudentFeeReminderScreen(),
    ),
    GetPage(
      name: AppRoutes.studentEventDetail,
      page: () => const StudentEventDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.studentHolidayDetail,
      page: () => const StudentHolidayDetailScreen(),
    ),
    GetPage(name: AppRoutes.studentReports, page: () => StudentReportsScreen()),
    GetPage(
      name: AppRoutes.studentReceiptsList,
      page: () => const StudentReceiptsListScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<FeesController>()) {
          Get.lazyPut<FeesController>(() => FeesController(), fenix: true);
        }
        Get.lazyPut<StudentReceiptsListController>(
          () => StudentReceiptsListController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.studentNotificationPreferences,
      page: () => const StudentNotificationPreferencesScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StudentNotificationPreferencesController>(
          () => StudentNotificationPreferencesController(
            StudentNotificationsRepository(Get.find()),
          ),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.studentStudyMaterial,
      page: () => const StudentStudyMaterialScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StudentStudyMaterialController>(
          () => StudentStudyMaterialController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.studentStudyMaterialDetail,
      page: () => const StudentStudyMaterialDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StudentStudyMaterialDetailController>(
          () => StudentStudyMaterialDetailController(),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.studentFeedback,
      page: () => const StudentFeedbackScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<StudentFeedbackController>(
          () => StudentFeedbackController(),
        );
      }),
    ),
    // Teacher routes
    GetPage(
      name: AppRoutes.teacherDashboard,
      page: () => const TeacherDashboardScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherForgotPassword,
      page: () => const TeacherForgotPasswordScreen(),
      binding: TeacherAuthBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherResetPassword,
      page: () => const TeacherResetPasswordScreen(),
      binding: TeacherAuthBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherChangePassword,
      page: () => const TeacherChangePasswordScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherBatches,
      page: () => const TeacherBatchesScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherBatchDetails,
      page: () => const TeacherBatchDetailsScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherProfile,
      page: () => const TeacherProfileScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherMarkAttendance,
      page: () => const TeacherMarkAttendanceScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherSelfAttendance,
      page: () => const TeacherSelfAttendanceScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherBatchHomework,
      page: () => const TeacherBatchHomeworkScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherAddHomework,
      page: () => const TeacherAddHomeworkScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherHomeworkGrading,
      page: () => const TeacherHomeworkGradingScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherBatchExams,
      page: () => const TeacherBatchExamsScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherAddExam,
      page: () => const TeacherAddExamScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherExamMarks,
      page: () => const TeacherExamMarksScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherBatchTimetable,
      page: () => const TeacherBatchTimetableScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherAddTimetableSlot,
      page: () => const TeacherAddTimetableSlotScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherFees,
      page: () => const TeacherFeesScreen(),
      binding: TeacherBinding(),
    ),
    GetPage(
      name: AppRoutes.teacherSalaries,
      page: () => const TeacherSalaryScreen(),
      binding: TeacherBinding(),
    ),
    // Institute routes
    GetPage(
      name: AppRoutes.instituteDashboard,
      page: () => const InstituteMainScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteMain,
      page: () => const InstituteMainScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteStudents,
      page: () => const StudentsRegistryScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteAddEditStudent,
      page: () => const AddEditStudentScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteFees,
      page: () => const InstituteFeesScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteRecordFee,
      page: () => const RecordFeeScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteFeeReceipt,
      page: () => const FeeReceiptScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteBatchDetails,
      page: () => const BatchDetailsScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteBatches,
      page: () => const BatchesScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteBirthdays,
      page: () => const BirthdaysScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteMarkAttendance,
      page: () => const MarkAttendanceScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteStudentProfile,
      page: () => const institute_student_profile.StudentProfileScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteEditProfile,
      page: () => const InstituteEditProfileScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteProfile,
      page: () => const InstituteProfileViewScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteSettings,
      page: () => const InstituteSettingsScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteChangePassword,
      page: () => const InstituteChangePasswordScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteSubscription,
      page: () => const InstituteSubscriptionScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteWhiteLabel,
      page: () => const WhiteLabelScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteAddOns,
      page: () => const AddOnsScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteWhatsApp,
      page: () => const InstituteWhatsAppScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteUpiPaymentSettings,
      page: () => const InstituteUpiPaymentSettingsScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteReports,
      page: () => const ReportsScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteFeeReport,
      page: () => const FeeReportScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteAttendanceReport,
      page: () => const AttendanceReportScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.institutePerformanceReport,
      page: () => const PerformanceReportScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteAnalytics,
      page: () => const AnalyticsScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteUpdates,
      page: () => const InstituteUpdatesScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteCreateUpdate,
      page: () => const CreateUpdateScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteNotifications,
      page: () => const InstituteNotificationsScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteBillingHistory,
      page: () => const BillingHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteAddBatch,
      page: () => const AddEditBatchScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteEditBatch,
      page: () => const AddEditBatchScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteFeeTransactionHistory,
      page: () => const FeeTransactionHistoryScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteSignup,
      page: () => const InstituteSignupScreen(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteOtp,
      page: () => const InstituteOtpScreen(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteProfileSetup,
      page: () => const InstituteProfileSetupScreen(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteBatchReportDetail,
      page: () => const BatchReportDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteForgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteResetPassword,
      page: () => const ResetPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteBatchStudents,
      page: () => const BatchStudentsScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteAssignToBatch,
      page: () => const AssignToBatchScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteBatchHomework,
      page: () => const BatchHomeworkScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteAddHomework,
      page: () => const AddHomeworkScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteHomeworkRating,
      page: () => const HomeworkRatingScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteBatchExams,
      page: () => const BatchExamsScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteAddExam,
      page: () => const AddExamScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteExamMarks,
      page: () => const ExamMarksScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteBatchTimetable,
      page: () => const BatchTimetableScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteAddTimetableSlot,
      page: () => const AddTimetableSlotScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteBatchResources,
      page: () => const BatchResourcesScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteResourceDetail,
      page: () => const ResourceDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.instituteLeads,
      page: () => const LeadsManagementScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteAddEditLead,
      page: () => const AddEditLeadScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteLeadDetails,
      page: () => const LeadDetailsScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteNotes,
      page: () => const NotesListScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteAddEditNote,
      page: () => const AddEditNoteScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteChats,
      page: () => const ChatListScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteCreateChat,
      page: () => const CreateChatScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteChatMessages,
      page: () => const ChatMessagesScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteStaffs,
      page: () => const StaffMainScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteStaffDetails,
      page: () => const StaffProfileScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteAddEditStaff,
      page: () => const AddEditStaffScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteSalaryHistory,
      page: () => const SalaryHistoryScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteStaffAttendance,
      page: () => const StaffAttendanceScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteLogStaffAttendance,
      page: () => const LogAttendanceScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteAddSalary,
      page: () => const AddSalaryScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteExpenses,
      page: () => const ExpensesScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteAddExpense,
      page: () => const AddExpenseScreen(),
      binding: InstituteBinding(),
    ),
    GetPage(
      name: AppRoutes.instituteExpenseAnalysis,
      page: () => const ExpenseAnalysisScreen(),
      binding: InstituteBinding(),
    ),
  ];
}

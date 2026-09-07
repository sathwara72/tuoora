import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/data/repositories_impl/chat_repository_impl.dart';
import 'package:tuoora/presentation/institute/controllers/chat_controller.dart';
import 'package:tuoora/core/services/chat_socket_service.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/services/download_service.dart';
import 'package:tuoora/presentation/student/controllers/assignments_controller.dart';
import 'package:tuoora/presentation/student/controllers/attendance_history_controller.dart';
import 'package:tuoora/presentation/student/controllers/fees_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_profile_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_reports_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_institute_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_study_material_controller.dart';
import 'package:tuoora/presentation/student/controllers/attachment_preview_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_dashboard_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_exams_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_timetable_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_birthday_controller.dart';
import 'package:tuoora/presentation/student/controllers/student_id_card_controller.dart';

class StudentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentController>(() => StudentController());
    Get.lazyPut<AssignmentsController>(
      () => AssignmentsController(),
      fenix: true,
    );
    Get.lazyPut<FeesController>(() => FeesController(), fenix: true);
    Get.lazyPut<AttendanceHistoryController>(
      () => AttendanceHistoryController(),
      fenix: true,
    );
    Get.lazyPut<StudentProfileController>(
      () => StudentProfileController(),
      fenix: true,
    );
    Get.lazyPut<StudentReportsController>(
      () => StudentReportsController(),
      fenix: true,
    );
    Get.lazyPut<StudentInstituteController>(
      () => StudentInstituteController(),
      fenix: true,
    );
    Get.lazyPut<StudentStudyMaterialController>(
      () => StudentStudyMaterialController(),
      fenix: true,
    );
    Get.lazyPut<AttachmentPreviewController>(
      () => AttachmentPreviewController(),
      fenix: true,
    );
    Get.lazyPut<StudentDashboardController>(
      () => StudentDashboardController(),
      fenix: true,
    );
    Get.lazyPut<StudentExamsController>(
      () => StudentExamsController(),
      fenix: true,
    );
    Get.lazyPut<StudentTimetableController>(
      () => StudentTimetableController(),
      fenix: true,
    );
    Get.lazyPut<StudentBirthdayController>(
      () => StudentBirthdayController(),
      fenix: true,
    );
    Get.lazyPut<StudentIdCardController>(
      () => StudentIdCardController(),
      fenix: true,
    );
    Get.lazyPut<ChatRepositoryImpl>(
      () => ChatRepositoryImpl(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<ChatController>(
      () => ChatController(Get.find<ChatRepositoryImpl>()),
      fenix: true,
    );
    if (!Get.isRegistered<ChatSocketService>()) {
      Get.put<ChatSocketService>(ChatSocketService(), permanent: true);
    }
    if (!Get.isRegistered<DownloadService>()) {
      Get.put<DownloadService>(DownloadService(), permanent: true);
    }
  }
}

import 'package:tuoora/core/services/chat_socket_service.dart';
import 'package:tuoora/presentation/institute/controllers/institute_subscription_controller.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/data/repositories_impl/auth_repository_impl.dart';
import 'package:tuoora/data/repositories/daily_update_repository.dart';
import 'package:tuoora/data/repositories_impl/daily_update_repository_impl.dart';
import 'package:tuoora/data/repositories/institute_repository.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/data/repositories/student_repository.dart';
import 'package:tuoora/data/repositories_impl/student_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/leads_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/notes_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/chat_repository_impl.dart';
import 'package:tuoora/presentation/institute/controllers/attendance_controller.dart';
import 'package:tuoora/presentation/institute/controllers/batch_controller.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/presentation/institute/controllers/institute_profile_controller.dart';
import 'package:tuoora/presentation/institute/controllers/leads_controller.dart';
import 'package:tuoora/presentation/institute/controllers/notes_controller.dart';
import 'package:tuoora/presentation/institute/controllers/notification_controller.dart';
import 'package:tuoora/presentation/institute/controllers/record_fee_controller.dart';
import 'package:tuoora/presentation/institute/controllers/reports_controller.dart';
import 'package:tuoora/presentation/institute/controllers/security_controller.dart';
import 'package:tuoora/presentation/institute/controllers/student_controller.dart';
import 'package:tuoora/presentation/institute/controllers/updates_controller.dart';
import 'package:tuoora/presentation/institute/controllers/whatsapp_controller.dart';
import 'package:tuoora/presentation/institute/controllers/chat_controller.dart';
import 'package:tuoora/presentation/institute/controllers/staff_controller.dart';
import 'package:tuoora/presentation/institute/controllers/expense_controller.dart';
import 'package:tuoora/presentation/institute/controllers/razorpay_controller.dart';
import 'package:tuoora/presentation/institute/controllers/white_label_controller.dart';
import 'package:tuoora/presentation/institute/controllers/birthday_controller.dart';
import 'package:tuoora/presentation/institute/controllers/add_ons_controller.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/services/download_service.dart';
import 'package:get/get.dart';

class InstituteBinding extends Bindings {
  @override
  void dependencies() {
    // API Dependencies FIRST
    Get.lazyPut<ApiClient>(() => ApiClient());
    Get.lazyPut<StudentRepositoryImpl>(
      () => StudentRepository(Get.find<ApiClient>()),
    );
    Get.lazyPut<AuthRepositoryImpl>(
      () => AuthRepository(Get.find<ApiClient>()),
    );
    Get.lazyPut<InstituteRepositoryImpl>(
      () => InstituteRepository(Get.find<ApiClient>()),
    );
    Get.lazyPut<DailyUpdateRepositoryImpl>(
      () => DailyUpdateRepository(Get.find<ApiClient>()),
    );
    Get.lazyPut<LeadsRepositoryImpl>(
      () => LeadsRepositoryImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<NotesRepositoryImpl>(
      () => NotesRepositoryImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<ChatRepositoryImpl>(
      () => ChatRepositoryImpl(Get.find<ApiClient>()),
    );

    // Controllers
    Get.lazyPut<InstituteController>(() => InstituteController());
    Get.lazyPut<InstituteStudentController>(
      () => InstituteStudentController(),
      fenix: true,
    );
    Get.lazyPut<RecordFeeController>(() => RecordFeeController(), fenix: true);
    Get.lazyPut<AttendanceController>(
      () => AttendanceController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<ReportsController>(() => ReportsController(), fenix: true);
    Get.lazyPut<InstituteSubscriptionController>(
      () =>
          InstituteSubscriptionController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<RazorpayController>(
      () => RazorpayController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<WhiteLabelController>(
      () => WhiteLabelController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<BirthdayController>(
      () => BirthdayController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<AddOnsController>(
      () => AddOnsController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<InstituteProfileController>(
      () => InstituteProfileController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<UpdatesController>(
      () => UpdatesController(
        Get.find<DailyUpdateRepositoryImpl>(),
        Get.find<InstituteRepositoryImpl>(),
      ),
      fenix: true,
    );

    // BatchController depends on InstituteRepositoryImpl
    Get.put<BatchController>(
      BatchController(Get.find<InstituteRepositoryImpl>()),
      permanent: true,
    );

    Get.lazyPut<SecurityController>(
      () => SecurityController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<WhatsAppController>(() => WhatsAppController(), fenix: true);
    Get.lazyPut<NotificationController>(
      () => NotificationController(
        Get.find<InstituteRepositoryImpl>() as InstituteRepository,
      ),
      fenix: true,
    );
    Get.lazyPut<LeadsController>(() => LeadsController(), fenix: true);
    Get.lazyPut<NotesController>(() => NotesController(), fenix: true);
    Get.lazyPut<ChatController>(
      () => ChatController(Get.find<ChatRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<StaffController>(
      () => StaffController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );
    Get.lazyPut<ExpenseController>(
      () => ExpenseController(Get.find<InstituteRepositoryImpl>()),
      fenix: true,
    );

    Get.put<DownloadService>(DownloadService(), permanent: true);
    if (!Get.isRegistered<ChatSocketService>()) {
      Get.put<ChatSocketService>(ChatSocketService(), permanent: true);
    }
  }
}

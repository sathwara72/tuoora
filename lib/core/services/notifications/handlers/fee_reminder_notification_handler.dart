import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/services/notifications/base_notification_handler.dart';
import 'package:tuoora/core/services/notifications/notification_payload.dart';
import 'package:tuoora/presentation/student/controllers/student_controller.dart';

/// Handles `fee_reminder` notification taps. Student-only.
///
/// Lands the student on the Fees tab (tab index 2) inside `StudentMainScreen`.
class FeeReminderNotificationHandler extends BaseNotificationHandler {
  static const int _feesTabIndex = 2;

  @override
  String get tag => 'FeeReminderNotificationHandler';

  @override
  Future<void> onReady(NotificationPayload payload, String role) async {
    if (role != 'STUDENT') {
      log('bail: role=$role (fee reminder taps are student-only)');
      return;
    }

    if (Get.isRegistered<StudentController>()) {
      log('switching bottom-nav to fees tab (index=$_feesTabIndex)');
      Get.find<StudentController>().changePage(_feesTabIndex);
      return;
    }

    log('pushing ${AppRoutes.studentDashboard} with fees tab');
    Get.offAllNamed(AppRoutes.studentDashboard);
  }
}

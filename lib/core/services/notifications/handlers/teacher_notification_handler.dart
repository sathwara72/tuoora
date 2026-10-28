import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/services/notifications/base_notification_handler.dart';
import 'package:tuoora/core/services/notifications/notification_payload.dart';

/// Teacher pushes:
/// - `salary_slip` → Salaries (slip PDF download lives there)
/// - `teacher_timetable` (sent daily at 7:00 AM) → today's timetable
/// - anything else (staff notices) → Notifications
class TeacherNotificationHandler extends BaseNotificationHandler {
  @override
  String get tag => 'TeacherNotificationHandler';

  @override
  Future<void> onReady(NotificationPayload payload, String role) async {
    if (role != 'TEACHER') {
      log('bail: role=$role (teacher-only handler)');
      return;
    }

    final String route;
    switch (payload.type.toLowerCase()) {
      case 'salary_slip':
        route = AppRoutes.teacherSalaries;
        break;
      case 'teacher_timetable':
        route = AppRoutes.teacherTimetable;
        break;
      default:
        route = AppRoutes.teacherNotifications;
    }

    if (Get.currentRoute == route) {
      log('already on $route');
      return;
    }
    log('navigating to $route');
    Get.toNamed<dynamic>(route);
  }
}

import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/services/notifications/base_notification_handler.dart';
import 'package:tuoora/core/services/notifications/notification_payload.dart';

/// Handles `exam`, `exam_scheduled`, and `exam_schedule` notification taps.
/// Student-only.
///
/// Directs the student to the Exams screen ([AppRoutes.studentExams])
/// or specific exam detail if exam_id is provided.
class ExamNotificationHandler extends BaseNotificationHandler {
  @override
  String get tag => 'ExamNotificationHandler';

  @override
  Future<void> onReady(NotificationPayload payload, String role) async {
    if (role != 'STUDENT') {
      log('bail: role=$role (exam taps are student-only)');
      return;
    }

    final examId = payload.get('exam_id') ?? payload.get('reference_id');
    if (examId != null && examId.isNotEmpty) {
      log('pushing ${AppRoutes.studentExamDetail} with exam_id=$examId');
      Get.toNamed<dynamic>(
        AppRoutes.studentExamDetail,
        arguments: {'exam_id': examId},
      );
      return;
    }

    log('pushing ${AppRoutes.studentExams}');
    Get.toNamed<dynamic>(AppRoutes.studentExams);
  }
}

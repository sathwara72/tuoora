import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/services/notifications/handlers/attendance_notification_handler.dart';
import 'package:tuoora/core/services/notifications/handlers/batch_notification_handler.dart';
import 'package:tuoora/core/services/notifications/handlers/birthday_notification_handler.dart';
import 'package:tuoora/core/services/notifications/handlers/broadcast_notification_handler.dart';
import 'package:tuoora/core/services/notifications/handlers/chat_notification_handler.dart';
import 'package:tuoora/core/services/notifications/handlers/exam_notification_handler.dart';
import 'package:tuoora/core/services/notifications/handlers/fee_reminder_notification_handler.dart';
import 'package:tuoora/core/services/notifications/handlers/homework_notification_handler.dart';
import 'package:tuoora/core/services/notifications/handlers/resource_notification_handler.dart';
import 'package:tuoora/core/services/notifications/handlers/subscription_notification_handler.dart';
import 'package:tuoora/core/services/notifications/notification_handler.dart';
import 'package:tuoora/core/services/notifications/notification_payload.dart';

/// Central dispatcher that turns a tapped notification's data payload into a
/// navigation action. Adding a new notification type is a 2-step change:
///   1. Implement [NotificationHandler] for the type.
///   2. Register it in [_handlers] keyed by the API's `type` string
///      (lowercase — lookup is case-insensitive).
///
/// The router never throws — unknown / malformed payloads are logged in
/// debug builds and silently dropped in release, so a misbehaving server
/// can never crash the app on tap.

class NotificationRouter extends GetxService {
  static NotificationRouter get to => Get.find<NotificationRouter>();

  late final Map<String, NotificationHandler> _handlers;

  Future<NotificationRouter> init() async {
    // Single homework handler shared by all three homework-related types —
    // they all carry a `homework_id` and open the same detail screen.
    final homeworkHandler = HomeworkNotificationHandler();
    // Single batch handler shared by assignment + removal + updates — both land the
    // student on the Assignments tab.
    final batchHandler = BatchNotificationHandler();
    // Single broadcast handler shared by every "informational" type —
    // they all open the student's notifications list, where the full
    // context (reference_id, image, category) already renders.
    final broadcastHandler = BroadcastNotificationHandler();
    final examHandler = ExamNotificationHandler();
    final feeReminderHandler = FeeReminderNotificationHandler();

    _handlers = <String, NotificationHandler>{
      'chat': ChatNotificationHandler(),
      'attendance': AttendanceNotificationHandler(),
      'homework': homeworkHandler,
      'homework_graded': homeworkHandler,
      'homework_reminder': homeworkHandler,
      'batch_assignment': batchHandler,
      'batch_removal': batchHandler,
      'batch_updated': batchHandler,
      'batch_update': batchHandler,
      'batch': batchHandler,
      'exam': examHandler,
      'exam_scheduled': examHandler,
      'exam_schedule': examHandler,
      'fee_reminder': feeReminderHandler,
      'fee_reminders': feeReminderHandler,
      'fees_reminder': feeReminderHandler,
      'fee_payment_reminder': feeReminderHandler,
      'announcement': broadcastHandler,
      'event': broadcastHandler,
      'holiday': broadcastHandler,
      'daily_update': broadcastHandler,
      'resource': ResourceNotificationHandler(),
      // Institute: admin approved a subscription renewal.
      'subscription_alert': SubscriptionNotificationHandler(),
      // Student: birthday celebration.
      'birthday_celebration': BirthdayNotificationHandler(),
    };
    return this;
  }

  /// Routes [data] (the `RemoteMessage.data` map) to the matching handler.
  /// Safe to call from anywhere — handlers fire-and-forget; the caller does
  /// not need to await navigation.
  void route(Map<String, dynamic>? data) {
    if (kDebugMode) debugPrint('[NotificationRouter] route() data=$data');

    if (data == null || data.isEmpty) {
      if (kDebugMode) debugPrint('[NotificationRouter] empty payload');
      return;
    }

    final payload = NotificationPayload.fromMap(data);
    final key = payload.type.toLowerCase();
    if (key.isEmpty) {
      if (kDebugMode) {
        debugPrint('[NotificationRouter] missing `type` field, data=$data');
      }
      return;
    }

    final handler = _handlers[key];
    if (handler == null) {
      if (kDebugMode) {
        debugPrint(
          '[NotificationRouter] no handler for type=$key '
          '(registered: ${_handlers.keys.toList()})',
        );
      }
      return;
    }

    if (kDebugMode) debugPrint('[NotificationRouter] dispatching type=$key');
    handler.handle(payload);
  }
}

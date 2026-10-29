import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_permissions.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/services/notifications/base_notification_handler.dart';
import 'package:tuoora/core/services/notifications/notification_payload.dart';
import 'package:tuoora/data/models/chat_model.dart';
import 'package:tuoora/presentation/institute/controllers/chat_controller.dart';

/// Handles `data.type == "chat"` taps.
///
/// Expected payload:
/// ```
/// {
///   "type": "chat",
///   "chat_id": "<backend chat id>",
///   "sender_id": "<other party user id>",
///   "sender_type": "Student" | "StudentParent" | "Staff" | "Institute"
/// }
/// ```
class ChatNotificationHandler extends BaseNotificationHandler {
  @override
  String get tag => 'ChatNotificationHandler';

  @override
  Future<void> onReady(NotificationPayload payload, String role) async {
    final senderId = payload.get('sender_id');
    final senderType = payload.get('sender_type');
    if (senderId == null || senderType == null) {
      log('bail: missing sender_id/sender_type');
      return;
    }

    final isStudent = role == 'STUDENT';
    final targetRoute = isStudent
        ? AppRoutes.studentChat
        : AppRoutes.instituteChatMessages;

    if (Get.currentRoute == targetRoute) {
      log('already on $targetRoute — nothing to do');
      return;
    }

    if (isStudent) {
      // The student messages screen self-initializes (its initState always
      // opens the institute chat and fetches messages), so we only need to
      // pre-seed the header and fire-and-forget navigate.
      _preseedSelectedChat(senderId: senderId, senderType: senderType);
      log('pushing $targetRoute (student, current=${Get.currentRoute})');
      // Never await Get.toNamed (its future resolves on pop, not push), and
      // never use offNamed (it replaces the dashboard and breaks back-nav).
      Get.toNamed<dynamic>(targetRoute);
      return;
    }

    // A sub-access user without chat access would only get "Access Denied".
    if (Get.isRegistered<AuthService>() &&
        !Get.find<AuthService>().can(AppPermissions.chatAccess)) {
      log('institute: no chat access — ignoring tap');
      return;
    }

    // Institute side: the messages screen is a passive GetView that renders
    // controller.messages and does NOT fetch on its own. Pre-seeding alone
    // left it empty (the bug). Route through openChat() so the conversation
    // is actually loaded — it sets selectedChat, calls fetchMessages AND
    // navigates to the messages route.
    if (!Get.isRegistered<ChatController>()) {
      log('institute: ChatController not registered — fallback navigate');
      Get.toNamed<dynamic>(targetRoute);
      return;
    }
    final controller = Get.find<ChatController>();
    final composedId = '${senderType}_$senderId';
    final chat = controller.chatsList.firstWhereOrNull(
          (c) => c.id == composedId,
        ) ??
        Chat(
          id: composedId,
          participantName: 'Chat',
          participantId: senderId,
          lastMessage: '',
          lastMessageTime: '',
          participantRole: senderType,
        );
    log('institute: openChat id=$composedId (current=${Get.currentRoute})');
    controller.openChat(chat);
  }

  void _preseedSelectedChat({
    required String senderId,
    required String senderType,
  }) {
    if (!Get.isRegistered<ChatController>()) {
      log('pre-seed skipped — ChatController not registered yet');
      return;
    }
    try {
      final controller = Get.find<ChatController>();
      final composedId = '${senderType}_$senderId';
      final existing = controller.chatsList.firstWhereOrNull(
        (c) => c.id == composedId,
      );
      controller.selectedChat.value = existing ??
          Chat(
            id: composedId,
            participantName: 'Chat',
            participantId: senderId,
            lastMessage: '',
            lastMessageTime: '',
            participantRole: senderType,
          );
      controller.messages.clear();
      log('pre-seeded selectedChat id=$composedId');
    } catch (e) {
      log('pre-seed failed: $e');
    }
  }
}

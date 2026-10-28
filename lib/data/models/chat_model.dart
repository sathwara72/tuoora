import 'package:intl/intl.dart';
import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/utils/date_format_utils.dart';

class Chat {
  final String id;
  final String participantName;
  final String participantId;
  final String? participantImage;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final String
  participantRole; // 'Student' | 'Staff' | 'Institute' | 'StudentParent'
  final String? myId;
  final String? myRole;
  final String? lastMessageType;
  final DateTime? lastMessageAt;

  Chat({
    required this.id,
    required this.participantName,
    required this.participantId,
    this.participantImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.participantRole,
    this.myId,
    this.myRole,
    this.lastMessageType,
    this.lastMessageAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final userId = json['user_id']?.toString() ?? '';
    final userType = json['user_type']?.toString() ?? '';
    final composedId = '${userType}_$userId';

    final createdAtRaw = json['created_at']?.toString();
    final createdAt = createdAtRaw != null
        ? DateTime.tryParse(createdAtRaw)?.toLocal()
        : null;

    return Chat(
      id: composedId,
      participantName: (json['user_name'] ?? '').toString(),
      participantId: userId,
      participantImage: (json['user_logo'] as String?)?.trim().isEmpty == true
          ? null
          : json['user_logo'] as String?,
      lastMessage: (json['latest_message'] ?? '').toString(),
      lastMessageTime: _formatRelative(createdAt),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      participantRole: userType,
      myId: json['my_id']?.toString(),
      myRole: json['my_type']?.toString(),
      lastMessageType: json['type']?.toString(),
      lastMessageAt: createdAt,
    );
  }

  Chat copyWith({
    String? id,
    String? lastMessage,
    String? lastMessageTime,
    int? unreadCount,
    String? lastMessageType,
    DateTime? lastMessageAt,
  }) {
    return Chat(
      id: id ?? this.id,
      participantName: participantName,
      participantId: participantId,
      participantImage: participantImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      participantRole: participantRole,
      myId: myId,
      myRole: myRole,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_name': participantName,
      'participant_id': participantId,
      'participant_image': participantImage,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'participant_role': participantRole,
    };
  }

  /// Relative time used in the chat list (shared app-wide rule).
  static String _formatRelative(DateTime? dt) =>
      DateFormatUtils.relativeTime(dt);
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderType;
  final String receiverId;
  final String receiverType;
  final String content;
  final String messageType;
  final String? attachment;
  final DateTime? createdAt;
  final DateTime? receivedAt;
  final DateTime? readAt;
  final bool isMe;
  final String timestamp;
  final bool failed;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderType,
    required this.receiverId,
    required this.receiverType,
    required this.content,
    this.messageType = 'text',
    this.attachment,
    this.createdAt,
    this.receivedAt,
    this.readAt,
    required this.isMe,
    required this.timestamp,
    this.failed = false,
  });

  MessageStatus get status {
    if (failed) return MessageStatus.failed;
    if (id.isEmpty) return MessageStatus.sending;
    // Read implies received — if backend skipped the MessageReceived event
    // (or only the read ack made it through), still show the blue tick.
    if (readAt != null) return MessageStatus.read;
    if (receivedAt != null) return MessageStatus.delivered;
    return MessageStatus.sent;
  }

  Message copyWith({
    String? id,
    DateTime? receivedAt,
    DateTime? readAt,
    bool? failed,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId,
      senderId: senderId,
      senderType: senderType,
      receiverId: receiverId,
      receiverType: receiverType,
      content: content,
      messageType: messageType,
      attachment: attachment,
      createdAt: createdAt,
      receivedAt: receivedAt ?? this.receivedAt,
      readAt: readAt ?? this.readAt,
      isMe: isMe,
      timestamp: timestamp,
      failed: failed ?? this.failed,
    );
  }

  /// Parses the `data` block returned by `POST /chat/send` and pushed by the
  /// `MessageSent` / `MessageReceived` / `MessageRead` socket events.
  ///
  /// [myUserId] and [myUserType] are used to compute [isMe]. Pass them from
  /// AuthService / current Chat. When unknown, pass empty strings.
  factory Message.fromJson(
    Map<String, dynamic> json, {
    required String myUserId,
    required String myUserType,
  }) {
    String stripAppModels(String type) => type.replaceFirst('App\\Models\\', '');
    final senderId = json['sender_id']?.toString() ?? '';
    final senderType = stripAppModels(json['sender_type']?.toString() ?? '');
    final receiverId = json['receiver_id']?.toString() ?? '';
    final receiverType = stripAppModels(json['receiver_type']?.toString() ?? '');

    final isMine = senderId == myUserId &&
        senderType.toLowerCase() == myUserType.toLowerCase();
    final otherId = isMine ? receiverId : senderId;
    final otherType = isMine ? receiverType : senderType;

    DateTime? parse(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

    final createdAt = parse(json['created_at']);
    var receivedAt = parse(json['received_at']);
    var readAt = parse(json['read_at']);

    // Defensive guard against a known backend quirk: when a sender opens
    // their own chat, the `/chat/messages` endpoint auto-stamps
    // `received_at` / `read_at` with the SAME instant as `created_at` on
    // the sender's OWN outgoing messages — even though the recipient
    // hasn't actually ack'd anything. That manifests as bogus blue ticks
    // on freshly re-opened chats.
    //
    // Real reads/deliveries always happen *strictly after* `created_at`
    // (the recipient device has to receive, then the user has to open the
    // chat — at minimum a few milliseconds). If we see equal-or-earlier
    // timestamps on our own messages, treat them as the bug and clear.
    if (isMine && createdAt != null) {
      if (readAt != null && !readAt.isAfter(createdAt)) readAt = null;
      if (receivedAt != null && !receivedAt.isAfter(createdAt)) {
        receivedAt = null;
      }
    }

    return Message(
      id: json['id']?.toString() ?? '',
      chatId: '${otherType}_$otherId',
      senderId: senderId,
      senderType: senderType,
      receiverId: receiverId,
      receiverType: receiverType,
      content: (json['message'] ?? json['content'] ?? '').toString(),
      messageType: (json['type'] ?? 'text').toString(),
      attachment: json['attachment']?.toString(),
      createdAt: createdAt,
      receivedAt: receivedAt,
      readAt: readAt,
      isMe: isMine,
      timestamp: createdAt == null
          ? ''
          : DateFormat('h:mm a').format(createdAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'sender_type': senderType,
      'receiver_id': receiverId,
      'receiver_type': receiverType,
      'message': content,
      'type': messageType,
      'attachment': attachment,
      'created_at': createdAt?.toIso8601String(),
      'received_at': receivedAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'is_me': isMe,
    };
  }
}

class ChatParticipant {
  final String id;
  final String name;
  final String role; // 'Student' | 'Staff' | 'Institute' | 'StudentParent'
  final String? image;

  ChatParticipant({
    required this.id,
    required this.name,
    required this.role,
    this.image,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    String? pickImage() {
      const candidates = [
        'profile_image_url',
        'profile_url',
        'logo_url',
        'profile_image',
      ];
      for (final key in candidates) {
        final v = json[key];
        if (v is String && v.trim().isNotEmpty) return v;
      }
      return null;
    }

    return ChatParticipant(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? '').toString(),
      role: (json['type'] ?? '').toString(),
      image: pickImage(),
    );
  }
}

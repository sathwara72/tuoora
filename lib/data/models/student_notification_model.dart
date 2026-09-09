import 'package:tuoora/core/enums/app_enums.dart';

class StudentNotification {
  final int id;
  final String title;
  final String message;
  final String? image;
  final NotificationKind kind;
  final String? referenceId;
  final bool isRead;
  final DateTime? createdAt;

  const StudentNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.image,
    required this.kind,
    required this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  int? get referenceIdInt =>
      referenceId == null ? null : int.tryParse(referenceId!);

  StudentNotification copyWith({bool? isRead}) {
    return StudentNotification(
      id: id,
      title: title,
      message: message,
      image: image,
      kind: kind,
      referenceId: referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory StudentNotification.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final rawCreated = json['created_at']?.toString();
    if (rawCreated != null && rawCreated.isNotEmpty) {
      try {
        created = DateTime.parse(rawCreated).toLocal();
      } catch (_) {}
    }

    return StudentNotification(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      image: json['image']?.toString(),
      kind: NotificationKind.fromString(json['type']?.toString()),
      referenceId: json['reference_id']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: created,
    );
  }
}

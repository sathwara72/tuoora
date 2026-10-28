/// In-app notification for staff: staff notices, salary slips and the daily
/// teaching schedule.
class TeacherNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final int? referenceId;
  final bool isRead;
  final DateTime? createdAt;

  const TeacherNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    this.isRead = false,
    this.createdAt,
  });

  bool get isSalarySlip => type == 'salary_slip';
  bool get isSchedule => type == 'teacher_timetable';

  factory TeacherNotification.fromJson(Map<String, dynamic> json) {
    final read = json['is_read'];
    return TeacherNotification(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      referenceId: int.tryParse(json['reference_id']?.toString() ?? ''),
      isRead: read == true || read == 1 || read == '1',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  TeacherNotification copyWith({bool? isRead}) => TeacherNotification(
    id: id,
    title: title,
    message: message,
    type: type,
    referenceId: referenceId,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}

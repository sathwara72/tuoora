class TeacherTimetableSlot {
  final int id;
  final int batchId;
  final String subject;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? roomNo;
  final String? description;
  final String status;
  final String? batchName;
  final String? timeSlot;
  final String? dayName;

  const TeacherTimetableSlot({
    required this.id,
    required this.batchId,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.roomNo,
    this.description,
    required this.status,
    this.batchName,
    this.timeSlot,
    this.dayName,
  });

  factory TeacherTimetableSlot.fromJson(Map<String, dynamic> json) {
    final batch = json['batch'];
    return TeacherTimetableSlot(
      id: json['id'],
      batchId: json['batch_id'],
      subject: json['subject'] ?? '',
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      roomNo: json['room_no'],
      description: json['description'],
      status: json['status'] ?? 'active',
      batchName: batch is Map ? batch['name'] : null,
      timeSlot: json['time_slot'],
      dayName: json['day_name'],
    );
  }
}

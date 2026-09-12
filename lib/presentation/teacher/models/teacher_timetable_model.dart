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
  final String? staffName;
  final int? staffId;
  final String? formattedStartTime;
  final String? formattedEndTime;

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
    this.staffName,
    this.staffId,
    this.formattedStartTime,
    this.formattedEndTime,
  });

  factory TeacherTimetableSlot.fromJson(Map<String, dynamic> json) {
    final batch = json['batch'];
    final staff = json['staff'];
    final teacher = json['teacher'];
    final facultyName = json['staff_name'] ??
        json['teacher_name'] ??
        (staff is Map ? (staff['full_name'] ?? staff['name']) : null) ??
        (teacher is Map ? (teacher['name'] ?? teacher['full_name']) : null);

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
      staffName: facultyName,
      staffId: json['staff_id'] ?? json['teacher_id'],
      formattedStartTime: json['formatted_start_time'],
      formattedEndTime: json['formatted_end_time'],
    );
  }
}

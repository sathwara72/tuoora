class StudentTimetableSlot {
  final String id;
  final String subject;
  final String dayOfWeek;
  final String startTime;
  final String? formattedStartTime;
  final String? formattedEndTime;
  final String? timeSlot;
  final String? staffName;
  final String? roomNo;

  StudentTimetableSlot({
    required this.id,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    this.formattedStartTime,
    this.formattedEndTime,
    this.timeSlot,
    this.staffName,
    this.roomNo,
  });

  factory StudentTimetableSlot.fromJson(Map<String, dynamic> json) {
    return StudentTimetableSlot(
      id: json['id'].toString(),
      subject: json['subject'] ?? '',
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time']?.toString() ?? '',
      formattedStartTime: json['formatted_start_time'],
      formattedEndTime: json['formatted_end_time'],
      timeSlot: json['time_slot'],
      staffName: json['staff']?['full_name'],
      roomNo: json['room_no'],
    );
  }
}

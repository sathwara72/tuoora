class DayOfWeek {
  static const String monday = 'monday';
  static const String tuesday = 'tuesday';
  static const String wednesday = 'wednesday';
  static const String thursday = 'thursday';
  static const String friday = 'friday';
  static const String saturday = 'saturday';
  static const String sunday = 'sunday';

  static const List<String> values = [
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
  ];

  static String labelFor(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static String shortLabelFor(String value) {
    return labelFor(value).substring(0, value.length >= 3 ? 3 : value.length);
  }

  /// Dart's [DateTime.weekday] is 1 (Monday) .. 7 (Sunday) — matches [values]' order.
  static String today() => values[DateTime.now().weekday - 1];
}

class TimetableSlot {
  final String id;
  final String batchId;
  final String? batchName;
  final int? staffId;
  final String? staffName;
  final String subject;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? formattedStartTime;
  final String? formattedEndTime;
  final String? timeSlot;
  final String? roomNo;
  final String? description;
  final String status;

  TimetableSlot({
    required this.id,
    required this.batchId,
    this.batchName,
    this.staffId,
    this.staffName,
    required this.subject,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.formattedStartTime,
    this.formattedEndTime,
    this.timeSlot,
    this.roomNo,
    this.description,
    required this.status,
  });

  String get dayLabel => DayOfWeek.labelFor(dayOfWeek);
  bool get isActive => status == 'active';

  factory TimetableSlot.fromJson(Map<String, dynamic> json) {
    return TimetableSlot(
      id: json['id'].toString(),
      batchId: json['batch_id'].toString(),
      batchName: json['batch']?['name'],
      staffId: json['staff_id'],
      staffName: json['staff']?['full_name'],
      subject: json['subject'] ?? '',
      dayOfWeek: json['day_of_week'] ?? DayOfWeek.monday,
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      formattedStartTime: json['formatted_start_time'],
      formattedEndTime: json['formatted_end_time'],
      timeSlot: json['time_slot'],
      roomNo: json['room_no'],
      description: json['description'],
      status: json['status'] ?? 'active',
    );
  }
}

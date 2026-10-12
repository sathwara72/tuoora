class AttendanceRecordModel {
  final int studentId;
  final String studentName;
  final String? enrollmentId;
  final String? phone;
  final String? profileImageUrl;
  final int batchId;
  final String? status;
  final String? markedBy;
  final int? attendanceId;
  final String? date;
  final int monthlyAbsentCount;
  final List<String> monthlyAbsentDates;

  AttendanceRecordModel({
    required this.studentId,
    required this.studentName,
    this.enrollmentId,
    this.phone,
    this.profileImageUrl,
    required this.batchId,
    this.status,
    this.markedBy,
    this.attendanceId,
    this.date,
    this.monthlyAbsentCount = 0,
    this.monthlyAbsentDates = const [],
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final rawEnrollment = (json['enrollment_id'] ??
            json['enrollment_no'] ??
            json['id_hash'] ??
            json['enrollmentId'])
        ?.toString();

    final absentCount = json['monthly_absent_count'] != null
        ? int.tryParse(json['monthly_absent_count'].toString()) ?? 0
        : 0;

    final rawDates = json['monthly_absent_dates'];
    final List<String> absentDates = (rawDates is List)
        ? rawDates.map((e) => e.toString()).toList()
        : [];

    return AttendanceRecordModel(
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? 'Student',
      enrollmentId: rawEnrollment,
      phone: json['phone']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      batchId: json['batch_id'] ?? 0,
      status: json['status'],
      markedBy: json['marked_by'],
      attendanceId: json['attendance_id'],
      date: json['date'],
      monthlyAbsentCount: absentCount,
      monthlyAbsentDates: absentDates,
    );
  }
}

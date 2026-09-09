class AttendanceRecordModel {
  final int studentId;
  final String studentName;
  final String? enrollmentId;
  final String? phone;
  final int batchId;
  final String? status;
  final String? markedBy;
  final int? attendanceId;
  final String? date;

  AttendanceRecordModel({
    required this.studentId,
    required this.studentName,
    this.enrollmentId,
    this.phone,
    required this.batchId,
    this.status,
    this.markedBy,
    this.attendanceId,
    this.date,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    final rawEnrollment = (json['enrollment_id'] ??
            json['enrollment_no'] ??
            json['id_hash'] ??
            json['enrollmentId'])
        ?.toString();

    return AttendanceRecordModel(
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? 'Student',
      enrollmentId: rawEnrollment,
      phone: json['phone'],
      batchId: json['batch_id'] ?? 0,
      status: json['status'],
      markedBy: json['marked_by'],
      attendanceId: json['attendance_id'],
      date: json['date'],
    );
  }
}


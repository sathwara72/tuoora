class TeacherAttendanceRow {
  final int studentId;
  final String studentName;
  final String? phone;
  final String? enrollmentId;
  String? status;
  final int? attendanceId;

  TeacherAttendanceRow({
    required this.studentId,
    required this.studentName,
    this.phone,
    this.enrollmentId,
    this.status,
    this.attendanceId,
  });

  factory TeacherAttendanceRow.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceRow(
      studentId: json['student_id'],
      studentName: json['student_name'] ?? '',
      phone: json['phone'],
      enrollmentId: json['enrollment_id'],
      status: json['status'],
      attendanceId: json['attendance_id'],
    );
  }
}

class TeacherStaffAttendance {
  final int id;
  final String date;
  final String status;
  final String? note;

  const TeacherStaffAttendance({
    required this.id,
    required this.date,
    required this.status,
    this.note,
  });

  factory TeacherStaffAttendance.fromJson(Map<String, dynamic> json) {
    return TeacherStaffAttendance(
      id: json['id'],
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      note: json['note'],
    );
  }
}

class TeacherSelfAttendanceHistory {
  final int totalPresent;
  final int totalAbsent;
  final List<TeacherStaffAttendance> items;
  final int currentPage;
  final int lastPage;

  const TeacherSelfAttendanceHistory({
    required this.totalPresent,
    required this.totalAbsent,
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  factory TeacherSelfAttendanceHistory.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    final pagination = json['pagination'] ?? {};
    return TeacherSelfAttendanceHistory(
      totalPresent: summary['total_present'] ?? 0,
      totalAbsent: summary['total_absent'] ?? 0,
      items: (json['data'] as List? ?? [])
          .map((e) => TeacherStaffAttendance.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentPage: pagination['current_page'] ?? 1,
      lastPage: pagination['last_page'] ?? 1,
    );
  }
}

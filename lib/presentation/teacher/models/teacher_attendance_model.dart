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

class TeacherCalendarDay {
  final String date;
  final String status;
  final String? note;
  final String? inTime;
  final String? outTime;

  const TeacherCalendarDay({
    required this.date,
    required this.status,
    this.note,
    this.inTime,
    this.outTime,
  });

  factory TeacherCalendarDay.fromJson(Map<String, dynamic> json) {
    return TeacherCalendarDay(
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Absent',
      note: json['note']?.toString(),
      inTime: json['in_time']?.toString(),
      outTime: json['out_time']?.toString(),
    );
  }
}

class TeacherAttendanceCalendarData {
  final int month;
  final int year;
  final int totalPresent;
  final int totalAbsent;
  final int totalHalfDay;
  final int totalLate;
  final int totalLeave;
  final int workingDays;
  final Map<String, TeacherCalendarDay> days;

  const TeacherAttendanceCalendarData({
    required this.month,
    required this.year,
    this.totalPresent = 0,
    this.totalAbsent = 0,
    this.totalHalfDay = 0,
    this.totalLate = 0,
    this.totalLeave = 0,
    this.workingDays = 0,
    this.days = const {},
  });

  factory TeacherAttendanceCalendarData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final summary = data['summary'] as Map? ?? {};

    final Map<String, TeacherCalendarDay> mappedDays = {};
    final rawCalendar = data['calendar'] ?? data['records'] ?? data['days'];

    if (rawCalendar is List) {
      for (final item in rawCalendar) {
        if (item is Map) {
          final day = TeacherCalendarDay.fromJson(Map<String, dynamic>.from(item));
          if (day.date.isNotEmpty) {
            mappedDays[day.date] = day;
          }
        }
      }
    } else if (rawCalendar is Map) {
      rawCalendar.forEach((key, value) {
        if (value is Map) {
          final valMap = Map<String, dynamic>.from(value);
          valMap['date'] ??= key.toString();
          mappedDays[key.toString()] = TeacherCalendarDay.fromJson(valMap);
        } else if (value is String) {
          mappedDays[key.toString()] = TeacherCalendarDay(
            date: key.toString(),
            status: value,
          );
        }
      });
    }

    int parseNum(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    return TeacherAttendanceCalendarData(
      month: parseNum(data['month']),
      year: parseNum(data['year']),
      totalPresent: parseNum(summary['total_present'] ?? summary['present']),
      totalAbsent: parseNum(summary['total_absent'] ?? summary['absent']),
      totalHalfDay: parseNum(summary['total_half_day'] ?? summary['half_day']),
      totalLate: parseNum(summary['total_late'] ?? summary['late']),
      totalLeave: parseNum(summary['total_leave'] ?? summary['leave']),
      workingDays: parseNum(summary['working_days'] ?? summary['total_days']),
      days: mappedDays,
    );
  }
}

class TeacherLeaveItem {
  final int id;
  final String startDate;
  final String endDate;
  final String reason;
  final bool skipSundays;
  final int daysCount;
  final String status;
  final String? createdAt;

  const TeacherLeaveItem({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.skipSundays = true,
    this.daysCount = 1,
    required this.status,
    this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  factory TeacherLeaveItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, {int fallback = 0}) {
      if (val == null) return fallback;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? fallback;
    }

    return TeacherLeaveItem(
      id: parseInt(json['id']),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? json['start_date']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      skipSundays: json['skip_sundays'] == true || json['skip_sundays'] == 1 || json['skip_sundays'] == '1',
      daysCount: parseInt(json['days_count'] ?? json['total_days'], fallback: 1),
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['created_at']?.toString(),
    );
  }
}

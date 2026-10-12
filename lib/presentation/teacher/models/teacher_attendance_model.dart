class TeacherAttendanceRow {
  final int studentId;
  final String studentName;
  final String? phone;
  final String? enrollmentId;
  final String? profileImageUrl;
  final int monthlyAbsentCount;
  final List<String> monthlyAbsentDates;
  String? status;
  final int? attendanceId;

  TeacherAttendanceRow({
    required this.studentId,
    required this.studentName,
    this.phone,
    this.enrollmentId,
    this.profileImageUrl,
    this.monthlyAbsentCount = 0,
    this.monthlyAbsentDates = const [],
    this.status,
    this.attendanceId,
  });

  factory TeacherAttendanceRow.fromJson(Map<String, dynamic> json) {
    final absentCount = json['monthly_absent_count'] != null
        ? int.tryParse(json['monthly_absent_count'].toString()) ?? 0
        : 0;

    final rawDates = json['monthly_absent_dates'];
    final List<String> absentDates = (rawDates is List)
        ? rawDates.map((e) => e.toString()).toList()
        : [];

    return TeacherAttendanceRow(
      studentId: json['student_id'] ?? json['id'] ?? 0,
      studentName: json['student_name'] ?? json['name'] ?? '',
      phone: json['phone']?.toString(),
      enrollmentId: json['enrollment_id']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      monthlyAbsentCount: absentCount,
      monthlyAbsentDates: absentDates,
      status: json['status'],
      attendanceId: json['attendance_id'],
    );
  }
}

class QrAttendanceResult {
  final int studentId;
  final String studentName;

  QrAttendanceResult({required this.studentId, required this.studentName});

  factory QrAttendanceResult.fromJson(Map<String, dynamic> json) {
    return QrAttendanceResult(
      studentId: json['student_id'],
      studentName: json['student_name'] ?? '',
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
  final int? id;
  final String date;
  final String status;
  final String? note;
  final String? inTime;
  final String? outTime;

  const TeacherCalendarDay({
    this.id,
    required this.date,
    required this.status,
    this.note,
    this.inTime,
    this.outTime,
  });

  factory TeacherCalendarDay.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] ?? json['attendance_date'] ?? json['day'] ?? json['attendanceDate'];
    String cleanDate = '';
    if (rawDate != null) {
      cleanDate = rawDate.toString().split(' ').first.split('T').first;
    }
    final rawStatus = json['status'] ?? json['attendance_status'] ?? json['attendance'] ?? json['type'] ?? '';
    return TeacherCalendarDay(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      date: cleanDate,
      status: rawStatus.toString(),
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
    // The self-attendance endpoint nests the day map one level deeper, as
    // data.calendar.days (data.calendar itself also carries month/year/
    // month_label) — drill into it first so those siblings aren't mistaken
    // for a flat day map.
    final calendarBlock = data['calendar'];
    final rawCalendar = (calendarBlock is Map && calendarBlock['days'] != null)
        ? calendarBlock['days']
        : (calendarBlock ?? data['records'] ?? data['days'] ?? data['attendance'] ?? data['data']);

    void addMapped(String key, TeacherCalendarDay day) {
      final cleanKey = key.split(' ').first.split('T').first;
      mappedDays[cleanKey] = day;
      if (day.date.isNotEmpty) {
        mappedDays[day.date] = day;
        try {
          final parsed = DateTime.tryParse(day.date);
          if (parsed != null) {
            mappedDays[parsed.day.toString()] = day;
            mappedDays[parsed.day.toString().padLeft(2, '0')] = day;
          }
        } catch (_) {}
      }
      final intKey = int.tryParse(cleanKey);
      if (intKey != null) {
        mappedDays[intKey.toString()] = day;
        mappedDays[intKey.toString().padLeft(2, '0')] = day;
      }
    }

    if (rawCalendar is List) {
      for (final item in rawCalendar) {
        if (item is Map) {
          final day = TeacherCalendarDay.fromJson(Map<String, dynamic>.from(item));
          if (day.date.isNotEmpty) {
            addMapped(day.date, day);
          }
        }
      }
    } else if (rawCalendar is Map) {
      rawCalendar.forEach((key, value) {
        if (value is Map) {
          final valMap = Map<String, dynamic>.from(value);
          valMap['date'] ??= key.toString();
          final day = TeacherCalendarDay.fromJson(valMap);
          addMapped(key.toString(), day);
        } else if (value is String) {
          final day = TeacherCalendarDay(
            date: key.toString(),
            status: value,
          );
          addMapped(key.toString(), day);
        }
      });
    }

    // calendar.days only carries a status string per day; calendar.details
    // adds the attendance record id and the note (leave reason).
    final details = calendarBlock is Map ? calendarBlock['details'] : null;
    if (details is Map) {
      details.forEach((key, value) {
        if (value is! Map) return;
        final valMap = Map<String, dynamic>.from(value);
        valMap['date'] ??= key.toString();
        addMapped(key.toString(), TeacherCalendarDay.fromJson(valMap));
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

  /// A leave can be cancelled until its last day has passed (the server has no
  /// approval step: a leave is a day marked "Leave" on the teacher's attendance).
  bool get canCancel {
    if (status.toLowerCase().contains('cancel')) return false;
    final end = DateTime.tryParse(endDate);
    if (end == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !DateTime(end.year, end.month, end.day).isBefore(today);
  }

  /// Parses one leave record. The API returns one attendance row per leave day
  /// (`date`, `note`, `status: Leave`), so each day becomes its own item.
  factory TeacherLeaveItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val, {int fallback = 0}) {
      if (val == null) return fallback;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? fallback;
    }

    String dateOnly(dynamic val) {
      final raw = val?.toString() ?? '';
      return raw.length >= 10 ? raw.substring(0, 10) : raw;
    }

    final start = dateOnly(json['start_date'] ?? json['date']);
    final end = dateOnly(json['end_date'] ?? json['start_date'] ?? json['date']);

    var reason = (json['reason'] ?? json['note'])?.toString().trim() ?? '';
    if (reason.toLowerCase().startsWith('leave:')) {
      reason = reason.substring(6).trim();
    } else if (reason.toLowerCase() == 'leave') {
      reason = '';
    }

    return TeacherLeaveItem(
      id: parseInt(json['id']),
      startDate: start,
      endDate: end,
      reason: reason,
      skipSundays: json['skip_sundays'] == true || json['skip_sundays'] == 1 || json['skip_sundays'] == '1',
      daysCount: parseInt(json['days_count'] ?? json['total_days'], fallback: 1),
      status: json['status']?.toString() ?? 'Leave',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class TeacherExamStats {
  final int totalStudents;
  final int marksEnteredCount;
  final int presentCount;
  final int absentCount;
  final int passedCount;
  final int failedCount;
  final double passPercentage;
  final double? highestMarks;
  final double? lowestMarks;
  final double averageMarks;

  const TeacherExamStats({
    required this.totalStudents,
    required this.marksEnteredCount,
    required this.presentCount,
    required this.absentCount,
    required this.passedCount,
    required this.failedCount,
    required this.passPercentage,
    this.highestMarks,
    this.lowestMarks,
    required this.averageMarks,
  });

  factory TeacherExamStats.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic v) => v == null ? null : double.tryParse('$v');
    return TeacherExamStats(
      totalStudents: json['total_students'] ?? 0,
      marksEnteredCount: json['marks_entered_count'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      passedCount: json['passed_count'] ?? 0,
      failedCount: json['failed_count'] ?? 0,
      passPercentage: asDouble(json['pass_percentage']) ?? 0,
      highestMarks: asDouble(json['highest_marks']),
      lowestMarks: asDouble(json['lowest_marks']),
      averageMarks: asDouble(json['average_marks']) ?? 0,
    );
  }
}

class TeacherExam {
  final int id;
  final int batchId;
  final String title;
  final String? subject;
  final String? examType;
  final String examDate;
  final String? startTime;
  final String? endTime;
  final double totalMarks;
  final double passingMarks;
  final String? description;
  final String status;
  final String? batchName;
  final String? className;
  final TeacherExamStats? stats;
  final String? formattedDate;

  const TeacherExam({
    required this.id,
    required this.batchId,
    required this.title,
    this.subject,
    this.examType,
    required this.examDate,
    this.startTime,
    this.endTime,
    required this.totalMarks,
    required this.passingMarks,
    this.description,
    required this.status,
    this.batchName,
    this.className,
    this.stats,
    this.formattedDate,
  });

  factory TeacherExam.fromJson(Map<String, dynamic> json) {
    final batch = json['batch'];
    return TeacherExam(
      id: json['id'],
      batchId: json['batch_id'],
      title: json['title'] ?? '',
      subject: json['subject'],
      examType: json['exam_type'],
      examDate: json['exam_date'] ?? '',
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalMarks: double.tryParse('${json['total_marks']}') ?? 0,
      passingMarks: double.tryParse('${json['passing_marks']}') ?? 0,
      description: json['description'],
      status: json['status'] ?? 'scheduled',
      batchName: batch is Map ? batch['name'] : null,
      className: json['class_name'] ?? json['class'] ?? json['classroom'] ?? (batch is Map ? (batch['class'] ?? batch['classroom']) : null),
      stats: json['stats'] != null
          ? TeacherExamStats.fromJson(Map<String, dynamic>.from(json['stats']))
          : null,
      formattedDate: json['formatted_date'],
    );
  }

  bool get isScheduled {
    final s = status.trim().toLowerCase();
    if (s == 'completed' || s == 'cancelled' || s == 'ongoing' || s == 'active') return false;
    if (s != 'scheduled') return false;
    final d = _examDay;
    if (d == null) return true;
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    return !d.isBefore(todayMidnight);
  }

  bool get isCompleted {
    final s = status.trim().toLowerCase();
    if (s == 'completed') return true;
    return s == 'scheduled' && !isScheduled;
  }

  DateTime? get _examDay {
    final parsed = DateTime.tryParse(examDate);
    return parsed == null ? null : DateTime(parsed.year, parsed.month, parsed.day);
  }

  bool get isToday {
    final d = _examDay;
    if (d == null) return false;
    final now = DateTime.now();
    return d == DateTime(now.year, now.month, now.day);
  }

  /// Scheduled for a day after today: marks entry stays locked until then.
  bool get isFutureScheduled {
    final d = _examDay;
    if (d == null || status.toLowerCase() != 'scheduled') return false;
    final now = DateTime.now();
    return d.isAfter(DateTime(now.year, now.month, now.day));
  }

  /// Exam date has passed but no marks were entered yet.
  bool get isPendingMarks {
    final d = _examDay;
    if (d == null || status.toLowerCase() != 'scheduled') return false;
    final now = DateTime.now();
    return d.isBefore(DateTime(now.year, now.month, now.day)) &&
        (stats?.marksEnteredCount ?? 0) == 0;
  }

  static String _formatTime(String raw) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw);
    if (m == null) return raw;
    var h = int.parse(m.group(1)!);
    final period = h >= 12 ? 'PM' : 'AM';
    h = h % 12 == 0 ? 12 : h % 12;
    return '$h:${m.group(2)} $period';
  }

  String? get timeRangeText {
    if (startTime == null || startTime!.isEmpty) return null;
    final start = _formatTime(startTime!);
    if (endTime == null || endTime!.isEmpty) return start;
    return '$start - ${_formatTime(endTime!)}';
  }

  String get opensOnText {
    if (formattedDate != null && formattedDate!.isNotEmpty) {
      return 'Opens on $formattedDate';
    }
    final parsed = DateTime.tryParse(examDate);
    if (parsed != null) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return 'Opens on ${parsed.day} ${months[parsed.month - 1]}, ${parsed.year}';
    }
    return 'Opens on $examDate';
  }
}

class TeacherExamListPage {
  final List<TeacherExam> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const TeacherExamListPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    this.total = 0,
  });

  factory TeacherExamListPage.fromJson(Map<String, dynamic> json) {
    return TeacherExamListPage(
      items: (json['data'] as List? ?? [])
          .map((e) => TeacherExam.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

class TeacherExamMarkRow {
  final int studentId;
  final String studentName;
  final String? enrollmentId;
  double? marksObtained;
  bool isAbsent;
  String? remarks;

  TeacherExamMarkRow({
    required this.studentId,
    required this.studentName,
    this.enrollmentId,
    this.marksObtained,
    this.isAbsent = false,
    this.remarks,
  });

  factory TeacherExamMarkRow.fromJson(Map<String, dynamic> json) {
    return TeacherExamMarkRow(
      studentId: json['student_id'],
      studentName: json['student_name'] ?? '',
      enrollmentId: json['enrollment_id'],
      marksObtained: json['marks_obtained'] != null
          ? double.tryParse('${json['marks_obtained']}')
          : null,
      isAbsent: json['is_absent'] == true,
      remarks: json['remarks'],
    );
  }
}

class TeacherExamMarksData {
  final TeacherExam exam;
  final List<TeacherExamMarkRow> students;
  final TeacherExamStats? stats;

  const TeacherExamMarksData({
    required this.exam,
    required this.students,
    this.stats,
  });

  factory TeacherExamMarksData.fromJson(Map<String, dynamic> json) {
    return TeacherExamMarksData(
      exam: TeacherExam.fromJson(Map<String, dynamic>.from(json['exam'])),
      students: (json['students'] as List? ?? [])
          .map((e) => TeacherExamMarkRow.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      stats: json['stats'] != null
          ? TeacherExamStats.fromJson(Map<String, dynamic>.from(json['stats']))
          : null,
    );
  }
}

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
      stats: json['stats'] != null
          ? TeacherExamStats.fromJson(Map<String, dynamic>.from(json['stats']))
          : null,
      formattedDate: json['formatted_date'],
    );
  }
}

class TeacherExamListPage {
  final List<TeacherExam> items;
  final int currentPage;
  final int lastPage;

  const TeacherExamListPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  factory TeacherExamListPage.fromJson(Map<String, dynamic> json) {
    return TeacherExamListPage(
      items: (json['data'] as List? ?? [])
          .map((e) => TeacherExam.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
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

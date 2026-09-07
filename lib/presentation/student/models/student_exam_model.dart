import 'package:tuoora/presentation/institute/models/exam_model.dart' show ExamType;

class StudentExamListItem {
  final String id;
  final String title;
  final String? subject;
  final String examType;
  final String? formattedDate;
  final double totalMarks;
  final double passingMarks;
  final String status; // scheduled, completed, cancelled
  final double? marksObtained;
  final bool isAbsent;
  final bool? isPass;
  final double? percentage;
  final String? grade;
  final String? remarks;

  StudentExamListItem({
    required this.id,
    required this.title,
    this.subject,
    required this.examType,
    this.formattedDate,
    required this.totalMarks,
    required this.passingMarks,
    required this.status,
    this.marksObtained,
    this.isAbsent = false,
    this.isPass,
    this.percentage,
    this.grade,
    this.remarks,
  });

  String get examTypeLabel => ExamType.labelFor(examType);
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get hasResult => marksObtained != null || isAbsent;

  factory StudentExamListItem.fromJson(Map<String, dynamic> json) {
    return StudentExamListItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      subject: json['subject'],
      examType: json['exam_type'] ?? ExamType.other,
      formattedDate: json['formatted_date'],
      totalMarks: (json['total_marks'] ?? 0).toDouble(),
      passingMarks: (json['passing_marks'] ?? 0).toDouble(),
      status: json['status'] ?? 'scheduled',
      marksObtained: json['marks_obtained'] != null
          ? (json['marks_obtained']).toDouble()
          : null,
      isAbsent: json['is_absent'] ?? false,
      isPass: json['is_pass'],
      percentage: json['percentage'] != null
          ? (json['percentage']).toDouble()
          : null,
      grade: json['grade'],
      remarks: json['remarks'],
    );
  }
}

class StudentExamOverallStats {
  final int totalExams;
  final int attendedExams;
  final int passedExams;
  final double averagePercentage;

  StudentExamOverallStats({
    required this.totalExams,
    required this.attendedExams,
    required this.passedExams,
    required this.averagePercentage,
  });

  factory StudentExamOverallStats.fromJson(Map<String, dynamic> json) {
    return StudentExamOverallStats(
      totalExams: json['total_exams'] ?? 0,
      attendedExams: json['attended_exams'] ?? 0,
      passedExams: json['passed_exams'] ?? 0,
      averagePercentage: (json['average_percentage'] ?? 0).toDouble(),
    );
  }
}

class StudentExamListData {
  final List<StudentExamListItem> exams;
  final StudentExamOverallStats overallStats;

  StudentExamListData({required this.exams, required this.overallStats});
}

class StudentExamResult {
  final double? marksObtained;
  final bool isAbsent;
  final bool? isPass;
  final double? percentage;
  final String? grade;
  final String? remarks;

  StudentExamResult({
    this.marksObtained,
    this.isAbsent = false,
    this.isPass,
    this.percentage,
    this.grade,
    this.remarks,
  });

  bool get hasResult => marksObtained != null || isAbsent;

  factory StudentExamResult.fromJson(Map<String, dynamic> json) {
    return StudentExamResult(
      marksObtained: json['marks_obtained'] != null
          ? (json['marks_obtained']).toDouble()
          : null,
      isAbsent: json['is_absent'] ?? false,
      isPass: json['is_pass'],
      percentage: json['percentage'] != null
          ? (json['percentage']).toDouble()
          : null,
      grade: json['grade'],
      remarks: json['remarks'],
    );
  }
}

class StudentExamClassStats {
  final double? highestMarks;
  final double averageMarks;
  final double passPercentage;

  StudentExamClassStats({
    this.highestMarks,
    required this.averageMarks,
    required this.passPercentage,
  });

  factory StudentExamClassStats.fromJson(Map<String, dynamic> json) {
    return StudentExamClassStats(
      highestMarks: json['highest_marks'] != null
          ? (json['highest_marks']).toDouble()
          : null,
      averageMarks: (json['average_marks'] ?? 0).toDouble(),
      passPercentage: (json['pass_percentage'] ?? 0).toDouble(),
    );
  }
}

class StudentExamDetail {
  final String id;
  final String title;
  final String? subject;
  final String examType;
  final String? formattedDate;
  final double totalMarks;
  final double passingMarks;
  final String status;
  final StudentExamResult result;
  final StudentExamClassStats classStats;

  StudentExamDetail({
    required this.id,
    required this.title,
    this.subject,
    required this.examType,
    this.formattedDate,
    required this.totalMarks,
    required this.passingMarks,
    required this.status,
    required this.result,
    required this.classStats,
  });

  String get examTypeLabel => ExamType.labelFor(examType);
  bool get isCompleted => status == 'completed';

  factory StudentExamDetail.fromJson(Map<String, dynamic> json) {
    final exam = json['exam'] as Map<String, dynamic>;
    return StudentExamDetail(
      id: exam['id'].toString(),
      title: exam['title'] ?? '',
      subject: exam['subject'],
      examType: exam['exam_type'] ?? ExamType.other,
      formattedDate: exam['formatted_date'],
      totalMarks: double.tryParse(exam['total_marks']?.toString() ?? '') ?? 0,
      passingMarks:
          double.tryParse(exam['passing_marks']?.toString() ?? '') ?? 0,
      status: exam['status'] ?? 'scheduled',
      result: StudentExamResult.fromJson(
        Map<String, dynamic>.from(json['student_result'] ?? {}),
      ),
      classStats: StudentExamClassStats.fromJson(
        Map<String, dynamic>.from(json['class_stats'] ?? {}),
      ),
    );
  }
}

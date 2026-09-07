import 'package:intl/intl.dart';

class ExamType {
  static const String unitTest = 'unit_test';
  static const String midTerm = 'mid_term';
  static const String finalExam = 'final';
  static const String quiz = 'quiz';
  static const String assignment = 'assignment';
  static const String other = 'other';

  static const List<String> values = [
    unitTest,
    midTerm,
    finalExam,
    quiz,
    assignment,
    other,
  ];

  static String labelFor(String value) {
    switch (value) {
      case unitTest:
        return 'Unit Test';
      case midTerm:
        return 'Mid Term';
      case finalExam:
        return 'Final';
      case quiz:
        return 'Quiz';
      case assignment:
        return 'Assignment';
      default:
        return 'Other';
    }
  }
}

class ExamStats {
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

  ExamStats({
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

  factory ExamStats.fromJson(Map<String, dynamic> json) {
    return ExamStats(
      totalStudents: json['total_students'] ?? 0,
      marksEnteredCount: json['marks_entered_count'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      passedCount: json['passed_count'] ?? 0,
      failedCount: json['failed_count'] ?? 0,
      passPercentage: (json['pass_percentage'] ?? 0).toDouble(),
      highestMarks: json['highest_marks'] != null
          ? (json['highest_marks']).toDouble()
          : null,
      lowestMarks: json['lowest_marks'] != null
          ? (json['lowest_marks']).toDouble()
          : null,
      averageMarks: (json['average_marks'] ?? 0).toDouble(),
    );
  }
}

class ExamModel {
  final String id;
  final String batchId;
  final String? batchName;
  final String title;
  final String? subject;
  final String examType;
  final DateTime examDate;
  final double totalMarks;
  final double passingMarks;
  final String? description;
  final String status; // scheduled, completed, cancelled
  final ExamStats? stats;

  ExamModel({
    required this.id,
    required this.batchId,
    this.batchName,
    required this.title,
    this.subject,
    required this.examType,
    required this.examDate,
    required this.totalMarks,
    required this.passingMarks,
    this.description,
    required this.status,
    this.stats,
  });

  String get examTypeLabel => ExamType.labelFor(examType);
  String get formattedDate => DateFormat('dd MMM, yyyy').format(examDate);
  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'].toString(),
      batchId: json['batch_id'].toString(),
      batchName: json['batch']?['name'],
      title: json['title'] ?? '',
      subject: json['subject'],
      examType: json['exam_type'] ?? ExamType.other,
      // Backend serializes the date-only column as a UTC-shifted ISO
      // timestamp (app timezone is Asia/Kolkata, UTC+5:30), so a bare
      // parse reads one calendar day early. toLocal() corrects it back.
      examDate: json['exam_date'] != null
          ? DateTime.parse(json['exam_date']).toLocal()
          : DateTime.now(),
      totalMarks: double.tryParse(json['total_marks']?.toString() ?? '') ?? 0,
      passingMarks:
          double.tryParse(json['passing_marks']?.toString() ?? '') ?? 0,
      description: json['description'],
      status: json['status'] ?? 'scheduled',
      stats: json['stats'] != null
          ? ExamStats.fromJson(Map<String, dynamic>.from(json['stats']))
          : null,
    );
  }
}

class ExamMarkRow {
  final int studentId;
  final String studentName;
  final String? phone;
  final String? enrollmentId;
  final String? profileImage;
  double? marksObtained;
  bool isAbsent;
  String remarks;
  final double? percentage;
  final bool? isPass;
  final String? grade;
  final int? markId;

  ExamMarkRow({
    required this.studentId,
    required this.studentName,
    this.phone,
    this.enrollmentId,
    this.profileImage,
    this.marksObtained,
    this.isAbsent = false,
    this.remarks = '',
    this.percentage,
    this.isPass,
    this.grade,
    this.markId,
  });

  factory ExamMarkRow.fromJson(Map<String, dynamic> json) {
    return ExamMarkRow(
      studentId: json['student_id'],
      studentName: json['student_name'] ?? 'Student',
      phone: json['phone'],
      enrollmentId: json['enrollment_id'],
      profileImage: json['profile_image'],
      marksObtained: json['marks_obtained'] != null
          ? (json['marks_obtained']).toDouble()
          : null,
      isAbsent: json['is_absent'] ?? false,
      remarks: json['remarks'] ?? '',
      percentage: json['percentage'] != null
          ? (json['percentage']).toDouble()
          : null,
      isPass: json['is_pass'],
      grade: json['grade'],
      markId: json['mark_id'],
    );
  }
}

class ExamMarksData {
  final ExamModel exam;
  final List<ExamMarkRow> students;
  final ExamStats stats;

  ExamMarksData({required this.exam, required this.students, required this.stats});
}

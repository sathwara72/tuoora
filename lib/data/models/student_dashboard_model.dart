import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/presentation/student/models/student_exam_model.dart';
import 'package:tuoora/data/models/student_resource_model.dart';

class StudentDashboardData {
  final String studentName;
  final int batchId;
  final String batchName;
  final int attendanceRate;
  final String totalFees;
  final String paidFees;
  final String dueFees;
  final TodayClass? todayClass;
  final List<WeekAttendanceDay> weekAttendanceDays;
  final List<Assignment> todayAssignments;
  final TodayAttendance todayAttendance;
  final List<StudentExamListItem> upcomingExams;
  final List<StudentResourceModel> studyMaterials;
  final List<PendingFee> pendingFees;
  final bool isBirthdayToday;
  final String? avatarUrl;

  StudentDashboardData({
    required this.studentName,
    required this.batchId,
    required this.batchName,
    required this.attendanceRate,
    required this.totalFees,
    required this.paidFees,
    required this.dueFees,
    this.todayClass,
    required this.weekAttendanceDays,
    required this.todayAssignments,
    required this.todayAttendance,
    required this.upcomingExams,
    required this.studyMaterials,
    required this.pendingFees,
    required this.isBirthdayToday,
    this.avatarUrl,
  });

  factory StudentDashboardData.fromJson(Map<String, dynamic> json) {
    return StudentDashboardData(
      studentName: json['student_name'] ?? '',
      batchId: json['batch_id'] ?? 0,
      batchName: json['batch_name'] ?? '',
      attendanceRate: json['attendance_rate'] ?? 0,
      totalFees: json['total_fees'] ?? '0.00',
      paidFees: json['paid_fees'] ?? '0.00',
      dueFees: json['due_fees'] ?? '0.00',
      todayClass: json['today_class'] != null ? TodayClass.fromJson(json['today_class']) : null,
      weekAttendanceDays: (json['week_attendance_days'] as List?)
              ?.map((e) => WeekAttendanceDay.fromJson(e))
              .toList() ??
          [],
      todayAssignments: (json['today_assignments'] as List?)
              ?.map((e) => Assignment.fromJson(e,
                  isCompleted: e['status']?.toString().toLowerCase() == 'submitted'))
              .toList() ??
          [],
      todayAttendance: json['today_attendance'] != null
          ? TodayAttendance.fromJson(json['today_attendance'])
          : TodayAttendance(status: '', text: ''),
      upcomingExams: (json['upcoming_exams'] as List?)
              ?.map((e) => StudentExamListItem.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      studyMaterials: (json['study_materials'] as List?)
              ?.map((e) => StudentResourceModel.fromJson(e))
              .toList() ??
          [],
      pendingFees: (json['pending_fees'] as List?)
              ?.map((e) => PendingFee.fromJson(e))
              .toList() ??
          [],
      isBirthdayToday: json['is_birthday_today'] ?? false,
      avatarUrl: json['avatar_url']?.toString() ??
          json['avatar']?.toString() ??
          json['profile_image']?.toString() ??
          json['profile_url']?.toString() ??
          json['photo']?.toString() ??
          json['student_photo']?.toString() ??
          json['student_image']?.toString() ??
          json['image']?.toString(),
    );
  }

  StudentDashboardData copyWith({
    String? studentName,
    int? batchId,
    String? batchName,
    int? attendanceRate,
    String? totalFees,
    String? paidFees,
    String? dueFees,
    TodayClass? todayClass,
    List<WeekAttendanceDay>? weekAttendanceDays,
    List<Assignment>? todayAssignments,
    TodayAttendance? todayAttendance,
    List<StudentExamListItem>? upcomingExams,
    List<StudentResourceModel>? studyMaterials,
    List<PendingFee>? pendingFees,
    bool? isBirthdayToday,
    String? avatarUrl,
  }) {
    return StudentDashboardData(
      studentName: studentName ?? this.studentName,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      totalFees: totalFees ?? this.totalFees,
      paidFees: paidFees ?? this.paidFees,
      dueFees: dueFees ?? this.dueFees,
      todayClass: todayClass ?? this.todayClass,
      weekAttendanceDays: weekAttendanceDays ?? this.weekAttendanceDays,
      todayAssignments: todayAssignments ?? this.todayAssignments,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      upcomingExams: upcomingExams ?? this.upcomingExams,
      studyMaterials: studyMaterials ?? this.studyMaterials,
      pendingFees: pendingFees ?? this.pendingFees,
      isBirthdayToday: isBirthdayToday ?? this.isBirthdayToday,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class TodayClass {
  final String subject;
  final String startTime;
  final String endTime;
  final String? teacherName;
  final String description;
  final String? classroom;
  final bool isToday;
  final String dayShort;
  final String dayLabel;

  TodayClass({
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.teacherName,
    required this.description,
    this.classroom,
    required this.isToday,
    required this.dayShort,
    required this.dayLabel,
  });

  factory TodayClass.fromJson(Map<String, dynamic> json) {
    return TodayClass(
      subject: json['subject'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      teacherName: json['teacher_name'],
      description: json['description'] ?? '',
      classroom: json['classroom'],
      isToday: json['is_today'] ?? false,
      dayShort: json['day_short'] ?? '',
      dayLabel: json['day_label'] ?? '',
    );
  }
}

class WeekAttendanceDay {
  final String day;
  final String status;
  final String date;

  WeekAttendanceDay({
    required this.day,
    required this.status,
    required this.date,
  });

  factory WeekAttendanceDay.fromJson(Map<String, dynamic> json) {
    return WeekAttendanceDay(
      day: json['day'] ?? '',
      status: json['status'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class TodayAttendance {
  final String status;
  final String text;

  TodayAttendance({
    required this.status,
    required this.text,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      status: json['status'] ?? '',
      text: json['text'] ?? '',
    );
  }
}

class PendingFee {
  final int? id;
  final String monthYear;
  final num dueAmount;
  final String status;

  PendingFee({
    this.id,
    required this.monthYear,
    required this.dueAmount,
    required this.status,
  });

  factory PendingFee.fromJson(Map<String, dynamic> json) {
    return PendingFee(
      id: json['id'],
      monthYear: json['month_year'] ?? '',
      dueAmount: json['due_amount'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

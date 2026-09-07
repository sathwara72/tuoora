import 'package:tuoora/presentation/institute/models/fee_record.dart';

class FeeReportSummary {
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final int count;

  FeeReportSummary({
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.count,
  });

  factory FeeReportSummary.fromJson(Map<String, dynamic> json) {
    return FeeReportSummary(
      totalAmount: FeeRecord.safeDouble(json['total_amount']),
      paidAmount: FeeRecord.safeDouble(json['paid_amount']),
      dueAmount: FeeRecord.safeDouble(json['due_amount']),
      count: FeeRecord.safeInt(json['count']),
    );
  }
}

class FeeReportBatch {
  final int batchId;
  final String batchName;
  final double batchFees;
  final double totalCollected;
  final double totalDue;
  final int studentsCount;

  FeeReportBatch({
    required this.batchId,
    required this.batchName,
    required this.batchFees,
    required this.totalCollected,
    required this.totalDue,
    required this.studentsCount,
  });

  factory FeeReportBatch.fromJson(Map<String, dynamic> json) {
    return FeeReportBatch(
      batchId: FeeRecord.safeInt(json['batch_id']),
      batchName: FeeRecord.safeString(json['batch_name']),
      batchFees: FeeRecord.safeDouble(json['batch_fees']),
      totalCollected: FeeRecord.safeDouble(json['total_collected']),
      totalDue: FeeRecord.safeDouble(json['total_due']),
      studentsCount: FeeRecord.safeInt(json['students_count']),
    );
  }
}

class FeeReportResponse {
  final FeeReportSummary summary;
  final List<FeeReportBatch> batches;

  FeeReportResponse({
    required this.summary,
    required this.batches,
  });

  factory FeeReportResponse.fromJson(Map<String, dynamic> json) {
    return FeeReportResponse(
      summary: FeeReportSummary.fromJson(json['summary'] ?? {}),
      batches: (json['batches'] as List? ?? [])
          .map((i) => FeeReportBatch.fromJson(i))
          .toList(),
    );
  }
}

class BatchFeeDetailResponse {
  final FeeReportSummary summary;
  final List<FeeRecord> fees;

  BatchFeeDetailResponse({
    required this.summary,
    required this.fees,
  });

  factory BatchFeeDetailResponse.fromJson(Map<String, dynamic> json) {
    return BatchFeeDetailResponse(
      summary: FeeReportSummary.fromJson(json['summary'] ?? {}),
      fees: (json['fees'] as List? ?? [])
          .map((i) => FeeRecord.fromJson(i))
          .toList(),
    );
  }
}

// Attendance Reports
class AttendanceReportSummary {
  final int present;
  final int absent;
  final int leave;
  final int total;

  AttendanceReportSummary({
    required this.present,
    required this.absent,
    required this.leave,
    required this.total,
  });

  factory AttendanceReportSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceReportSummary(
      present: FeeRecord.safeInt(json['present']),
      absent: FeeRecord.safeInt(json['absent']),
      leave: FeeRecord.safeInt(json['leave']),
      total: FeeRecord.safeInt(json['total']),
    );
  }
}

class AttendanceReportBatch {
  final int batchId;
  final String batchName;
  final double avgAttendance;
  final int studentsCount;

  AttendanceReportBatch({
    required this.batchId,
    required this.batchName,
    required this.avgAttendance,
    required this.studentsCount,
  });

  factory AttendanceReportBatch.fromJson(Map<String, dynamic> json) {
    return AttendanceReportBatch(
      batchId: FeeRecord.safeInt(json['batch_id']),
      batchName: FeeRecord.safeString(json['batch_name']),
      avgAttendance: FeeRecord.safeDouble(json['avg_attendance']),
      studentsCount: FeeRecord.safeInt(json['students_count']),
    );
  }
}

class AttendanceReportResponse {
  final AttendanceReportSummary summary;
  final List<AttendanceReportBatch> batches;

  AttendanceReportResponse({
    required this.summary,
    required this.batches,
  });

  factory AttendanceReportResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceReportResponse(
      summary: AttendanceReportSummary.fromJson(json['summary'] ?? {}),
      batches: (json['batches'] as List? ?? [])
          .map((i) => AttendanceReportBatch.fromJson(i))
          .toList(),
    );
  }
}

class AttendanceDetailRecord {
  final int id;
  final int studentId;
  final String status;
  final String studentName;
  final int presentDays;

  AttendanceDetailRecord({
    required this.id,
    required this.studentId,
    required this.status,
    required this.studentName,
    required this.presentDays,
  });

  factory AttendanceDetailRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceDetailRecord(
      id: FeeRecord.safeInt(json['id']),
      studentId: FeeRecord.safeInt(json['student_id']),
      status: FeeRecord.safeString(json['status']),
      studentName: FeeRecord.safeString(json['student']?['name']),
      presentDays: FeeRecord.safeInt(json['student']?['present_days']),
    );
  }
}

class BatchAttendanceDetailResponse {
  final AttendanceReportSummary summary;
  final List<AttendanceDetailRecord> attendance;

  BatchAttendanceDetailResponse({
    required this.summary,
    required this.attendance,
  });

  factory BatchAttendanceDetailResponse.fromJson(Map<String, dynamic> json) {
    return BatchAttendanceDetailResponse(
      summary: AttendanceReportSummary.fromJson(json['summary'] ?? {}),
      attendance: (json['attendance'] as List? ?? [])
          .map((i) => AttendanceDetailRecord.fromJson(i))
          .toList(),
    );
  }
}

// Performance Reports
class PerformanceReportSummary {
  final String averagePerformance;

  PerformanceReportSummary({required this.averagePerformance});

  factory PerformanceReportSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceReportSummary(
      averagePerformance: FeeRecord.safeString(json['average_performance']),
    );
  }
}

class PerformanceReportBatch {
  final int batchId;
  final String batchName;
  final String avgScore;
  final int studentsCount;

  PerformanceReportBatch({
    required this.batchId,
    required this.batchName,
    required this.avgScore,
    required this.studentsCount,
  });

  factory PerformanceReportBatch.fromJson(Map<String, dynamic> json) {
    return PerformanceReportBatch(
      batchId: FeeRecord.safeInt(json['batch_id']),
      batchName: FeeRecord.safeString(json['batch_name']),
      avgScore: FeeRecord.safeString(json['avg_score']),
      studentsCount: FeeRecord.safeInt(json['students_count']),
    );
  }
}

class PerformanceReportResponse {
  final PerformanceReportSummary summary;
  final List<PerformanceReportBatch> batches;

  PerformanceReportResponse({
    required this.summary,
    required this.batches,
  });

  factory PerformanceReportResponse.fromJson(Map<String, dynamic> json) {
    return PerformanceReportResponse(
      summary: PerformanceReportSummary.fromJson(json['summary'] ?? {}),
      batches: (json['batches'] as List? ?? [])
          .map((i) => PerformanceReportBatch.fromJson(i))
          .toList(),
    );
  }
}

class StudentPerformanceDetail {
  final int studentId;
  final String studentName;
  final String avgScore;

  StudentPerformanceDetail({
    required this.studentId,
    required this.studentName,
    required this.avgScore,
  });

  factory StudentPerformanceDetail.fromJson(Map<String, dynamic> json) {
    return StudentPerformanceDetail(
      studentId: FeeRecord.safeInt(json['student_id']),
      studentName: FeeRecord.safeString(json['student_name']),
      avgScore: FeeRecord.safeString(json['avg_score']),
    );
  }
}

class BatchPerformanceDetailResponse {
  final PerformanceReportSummary summary;
  final List<StudentPerformanceDetail> students;

  BatchPerformanceDetailResponse({
    required this.summary,
    required this.students,
  });

  factory BatchPerformanceDetailResponse.fromJson(Map<String, dynamic> json) {
    return BatchPerformanceDetailResponse(
      summary: PerformanceReportSummary.fromJson(json['summary'] ?? {}),
      students: (json['students'] as List? ?? [])
          .map((i) => StudentPerformanceDetail.fromJson(i))
          .toList(),
    );
  }
}

// Business Analytics Dashboard
class RevenueMonthPoint {
  final String month;
  final double feeCollected;
  final double billed;
  final double subscriptionRevenue;
  final double totalRevenue;

  RevenueMonthPoint({
    required this.month,
    required this.feeCollected,
    required this.billed,
    required this.subscriptionRevenue,
    required this.totalRevenue,
  });

  factory RevenueMonthPoint.fromJson(Map<String, dynamic> json) {
    return RevenueMonthPoint(
      month: FeeRecord.safeString(json['month']),
      feeCollected: FeeRecord.safeDouble(json['fee_collected']),
      billed: FeeRecord.safeDouble(json['billed']),
      subscriptionRevenue: FeeRecord.safeDouble(json['subscription_revenue']),
      totalRevenue: FeeRecord.safeDouble(json['total_revenue']),
    );
  }
}

class AnalyticsRevenue {
  final double currentMonthTotal;
  final double previousMonthTotal;
  final double growthPercent;
  final List<RevenueMonthPoint> monthlyTrend;

  AnalyticsRevenue({
    required this.currentMonthTotal,
    required this.previousMonthTotal,
    required this.growthPercent,
    required this.monthlyTrend,
  });

  factory AnalyticsRevenue.fromJson(Map<String, dynamic> json) {
    return AnalyticsRevenue(
      currentMonthTotal: FeeRecord.safeDouble(json['current_month_total']),
      previousMonthTotal: FeeRecord.safeDouble(json['previous_month_total']),
      growthPercent: FeeRecord.safeDouble(json['growth_percent']),
      monthlyTrend: (json['monthly_trend'] as List? ?? [])
          .map((i) => RevenueMonthPoint.fromJson(i))
          .toList(),
    );
  }
}

class CollectionMonthPoint {
  final String month;
  final double percent;

  CollectionMonthPoint({required this.month, required this.percent});

  factory CollectionMonthPoint.fromJson(Map<String, dynamic> json) {
    return CollectionMonthPoint(
      month: FeeRecord.safeString(json['month']),
      percent: FeeRecord.safeDouble(json['percent']),
    );
  }
}

class AnalyticsFeeCollection {
  final double overallPercent;
  final double currentMonthPercent;
  final double totalBilled;
  final double totalCollected;
  final List<CollectionMonthPoint> monthlyTrend;

  AnalyticsFeeCollection({
    required this.overallPercent,
    required this.currentMonthPercent,
    required this.totalBilled,
    required this.totalCollected,
    required this.monthlyTrend,
  });

  factory AnalyticsFeeCollection.fromJson(Map<String, dynamic> json) {
    return AnalyticsFeeCollection(
      overallPercent: FeeRecord.safeDouble(json['overall_percent']),
      currentMonthPercent: FeeRecord.safeDouble(json['current_month_percent']),
      totalBilled: FeeRecord.safeDouble(json['total_billed']),
      totalCollected: FeeRecord.safeDouble(json['total_collected']),
      monthlyTrend: (json['monthly_trend'] as List? ?? [])
          .map((i) => CollectionMonthPoint.fromJson(i))
          .toList(),
    );
  }
}

class AttendanceMonthPoint {
  final String month;
  final double? percent;

  AttendanceMonthPoint({required this.month, this.percent});

  factory AttendanceMonthPoint.fromJson(Map<String, dynamic> json) {
    return AttendanceMonthPoint(
      month: FeeRecord.safeString(json['month']),
      percent: json['percent'] == null
          ? null
          : FeeRecord.safeDouble(json['percent']),
    );
  }
}

class AnalyticsAttendanceBatch {
  final int batchId;
  final String batchName;
  final List<AttendanceMonthPoint> trend;

  AnalyticsAttendanceBatch({
    required this.batchId,
    required this.batchName,
    required this.trend,
  });

  factory AnalyticsAttendanceBatch.fromJson(Map<String, dynamic> json) {
    return AnalyticsAttendanceBatch(
      batchId: FeeRecord.safeInt(json['batch_id']),
      batchName: FeeRecord.safeString(json['batch_name']),
      trend: (json['trend'] as List? ?? [])
          .map((i) => AttendanceMonthPoint.fromJson(i))
          .toList(),
    );
  }
}

class AnalyticsAttendance {
  final double overallPercentThisMonth;
  final List<AnalyticsAttendanceBatch> batches;

  AnalyticsAttendance({
    required this.overallPercentThisMonth,
    required this.batches,
  });

  factory AnalyticsAttendance.fromJson(Map<String, dynamic> json) {
    return AnalyticsAttendance(
      overallPercentThisMonth:
          FeeRecord.safeDouble(json['overall_percent_this_month']),
      batches: (json['batches'] as List? ?? [])
          .map((i) => AnalyticsAttendanceBatch.fromJson(i))
          .toList(),
    );
  }
}

class AnalyticsDropoutBatch {
  final int batchId;
  final String batchName;
  final int activeCount;
  final int inactiveCount;
  final int total;
  final double dropoutRate;

  AnalyticsDropoutBatch({
    required this.batchId,
    required this.batchName,
    required this.activeCount,
    required this.inactiveCount,
    required this.total,
    required this.dropoutRate,
  });

  factory AnalyticsDropoutBatch.fromJson(Map<String, dynamic> json) {
    return AnalyticsDropoutBatch(
      batchId: FeeRecord.safeInt(json['batch_id']),
      batchName: FeeRecord.safeString(json['batch_name']),
      activeCount: FeeRecord.safeInt(json['active_count']),
      inactiveCount: FeeRecord.safeInt(json['inactive_count']),
      total: FeeRecord.safeInt(json['total']),
      dropoutRate: FeeRecord.safeDouble(json['dropout_rate']),
    );
  }
}

class AnalyticsDropout {
  final double overallRate;
  final int totalActive;
  final int totalInactive;
  final List<AnalyticsDropoutBatch> batches;

  AnalyticsDropout({
    required this.overallRate,
    required this.totalActive,
    required this.totalInactive,
    required this.batches,
  });

  factory AnalyticsDropout.fromJson(Map<String, dynamic> json) {
    return AnalyticsDropout(
      overallRate: FeeRecord.safeDouble(json['overall_rate']),
      totalActive: FeeRecord.safeInt(json['total_active']),
      totalInactive: FeeRecord.safeInt(json['total_inactive']),
      batches: (json['batches'] as List? ?? [])
          .map((i) => AnalyticsDropoutBatch.fromJson(i))
          .toList(),
    );
  }
}

class AnalyticsResponse {
  final AnalyticsRevenue revenue;
  final AnalyticsFeeCollection feeCollection;
  final AnalyticsAttendance attendance;
  final AnalyticsDropout dropout;

  AnalyticsResponse({
    required this.revenue,
    required this.feeCollection,
    required this.attendance,
    required this.dropout,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      revenue: AnalyticsRevenue.fromJson(json['revenue'] ?? {}),
      feeCollection:
          AnalyticsFeeCollection.fromJson(json['fee_collection'] ?? {}),
      attendance: AnalyticsAttendance.fromJson(json['attendance'] ?? {}),
      dropout: AnalyticsDropout.fromJson(json['dropout'] ?? {}),
    );
  }
}


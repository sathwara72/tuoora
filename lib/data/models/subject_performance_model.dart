/// Per-subject exam performance (same shape for the institute's student
/// profile and the student's own Subject Performance screen).
class SubjectPerformance {
  final List<SubjectPerformanceItem> subjects;
  final List<String> weak;
  final List<String> strong;

  const SubjectPerformance({
    this.subjects = const [],
    this.weak = const [],
    this.strong = const [],
  });

  bool get isEmpty => subjects.isEmpty;

  factory SubjectPerformance.fromJson(dynamic json) {
    if (json is! Map) return const SubjectPerformance();
    List<String> names(dynamic v) =>
        v is List ? v.map((e) => e.toString()).toList() : const [];
    final raw = json['subjects'];
    return SubjectPerformance(
      subjects: raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (e) => SubjectPerformanceItem.fromJson(
                    e.cast<String, dynamic>(),
                  ),
                )
                .toList()
          : const [],
      weak: names(json['weak']),
      strong: names(json['strong']),
    );
  }
}

class SubjectPerformanceItem {
  final String subject;

  /// `weak`, `average`, `strong` or `no_data`.
  final String level;
  final double? averagePercentage;
  final double? latestPercentage;

  /// `improving`, `declining` or `steady`.
  final String trend;
  final int examsTaken;
  final int examsAbsent;
  final bool failedLatest;

  const SubjectPerformanceItem({
    required this.subject,
    required this.level,
    this.averagePercentage,
    this.latestPercentage,
    this.trend = 'steady',
    this.examsTaken = 0,
    this.examsAbsent = 0,
    this.failedLatest = false,
  });

  factory SubjectPerformanceItem.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) =>
        v == null ? null : double.tryParse(v.toString());
    int toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
    return SubjectPerformanceItem(
      subject: json['subject']?.toString() ?? 'General',
      level: json['level']?.toString() ?? 'no_data',
      averagePercentage: toDouble(json['average_percentage']),
      latestPercentage: toDouble(json['latest_percentage']),
      trend: json['trend']?.toString() ?? 'steady',
      examsTaken: toInt(json['exams_taken']),
      examsAbsent: toInt(json['exams_absent']),
      failedLatest: json['failed_latest'] == true || json['failed_latest'] == 1,
    );
  }
}

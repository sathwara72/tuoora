class HomeworkModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String? attachment;
  final String batchId;
  final String? batchName;
  final int submissionsCount;
  final List<HomeworkSubmission> submissions;
  final List<String> resourcePaths;

  HomeworkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.attachment,
    required this.batchId,
    this.batchName,
    this.submissionsCount = 0,
    this.submissions = const [],
    this.resourcePaths = const [],
  });

  String get subject => batchName ?? 'General';
  bool get isActive => dueDate.isAfter(DateTime.now());
  int get submittedCount => submissionsCount;

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    return HomeworkModel(
      id: json['id'].toString(),
      batchId: json['batch_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      attachment: json['attachment'],
      batchName: json['batch']?['name'],
      submissionsCount: json['submissions_count'] ?? 0,
      submissions: json['submissions'] != null
          ? (json['submissions'] as List)
                .map((s) => HomeworkSubmission.fromJson(s))
                .toList()
          : [],
    );
  }
}

class HomeworkSubmission {
  final String id;
  final int studentId;
  final String studentName;
  final String? enrollmentId;
  final String? profileImageUrl;
  double score; // Non-final to allow local updates
  String status; // Non-final to allow local updates
  final bool isSubmitted; // Keep for legacy
  final DateTime? submittedAt; // Keep for legacy

  HomeworkSubmission({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.enrollmentId,
    this.profileImageUrl,
    required this.score,
    required this.status,
    this.isSubmitted = false,
    this.submittedAt,
  });

  bool get isLate => status.toLowerCase() == 'late';

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) {
    final student = json['student'] is Map ? json['student'] as Map : {};
    final statusStr = json['status'] ?? 'Pending';
    final rawEnrollment = (student['enrollment_id'] ??
            student['enrollment_no'] ??
            student['id_hash'] ??
            student['enrollmentId'] ??
            json['enrollment_id'])
        ?.toString();

    return HomeworkSubmission(
      id: json['id'].toString(),
      studentId: json['student_id'],
      studentName: student['name'] ?? 'Student',
      enrollmentId: rawEnrollment,
      profileImageUrl: student['profile_image_url'],
      score: (json['score'] ?? 0).toDouble(),
      status: statusStr,
      isSubmitted: statusStr.toLowerCase() == 'submitted',
      submittedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}


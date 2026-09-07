class TeacherHomework {
  final int id;
  final int batchId;
  final String title;
  final String description;
  final String dueDate;
  final String? attachmentUrl;
  final String? batchName;
  final int? submissionsCount;

  const TeacherHomework({
    required this.id,
    required this.batchId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.attachmentUrl,
    this.batchName,
    this.submissionsCount,
  });

  bool get isOverdue {
    final due = DateTime.tryParse(dueDate);
    if (due == null) return false;
    final today = DateTime.now();
    return DateTime(due.year, due.month, due.day)
        .isBefore(DateTime(today.year, today.month, today.day));
  }

  factory TeacherHomework.fromJson(Map<String, dynamic> json) {
    final batch = json['batch'];
    return TeacherHomework(
      id: json['id'],
      batchId: json['batch_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_date'] ?? '',
      attachmentUrl: json['attachment'],
      batchName: batch is Map ? batch['name'] : null,
      submissionsCount: json['submissions_count'],
    );
  }
}

class TeacherHomeworkListPage {
  final List<TeacherHomework> items;
  final int currentPage;
  final int lastPage;

  const TeacherHomeworkListPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  factory TeacherHomeworkListPage.fromJson(Map<String, dynamic> json) {
    return TeacherHomeworkListPage(
      items: (json['data'] as List? ?? [])
          .map((e) => TeacherHomework.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class TeacherHomeworkSubmission {
  final int studentId;
  final String studentName;
  final String? profileImageUrl;
  String status;
  double? score;
  final String? note;
  final String? attachmentUrl;

  TeacherHomeworkSubmission({
    required this.studentId,
    required this.studentName,
    this.profileImageUrl,
    required this.status,
    this.score,
    this.note,
    this.attachmentUrl,
  });

  factory TeacherHomeworkSubmission.fromJson(Map<String, dynamic> json) {
    final student = json['student'] ?? {};
    return TeacherHomeworkSubmission(
      studentId: json['student_id'] ?? student['id'],
      studentName: student['name'] ?? '',
      profileImageUrl: student['profile_image_url'],
      status: json['status'] ?? 'Pending',
      score: json['score'] != null ? double.tryParse('${json['score']}') : null,
      note: json['note'],
      attachmentUrl: json['attachment_url'],
    );
  }
}

class TeacherHomeworkDetail {
  final TeacherHomework homework;
  final List<TeacherHomeworkSubmission> submissions;

  const TeacherHomeworkDetail({required this.homework, required this.submissions});

  factory TeacherHomeworkDetail.fromJson(Map<String, dynamic> json) {
    return TeacherHomeworkDetail(
      homework: TeacherHomework.fromJson(json),
      submissions: (json['submissions'] as List? ?? [])
          .map((e) => TeacherHomeworkSubmission.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

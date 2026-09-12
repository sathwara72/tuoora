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
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final dueMidnight = DateTime(due.year, due.month, due.day);
    return dueMidnight.isBefore(todayMidnight);
  }

  int? get daysLeft {
    final due = DateTime.tryParse(dueDate);
    if (due == null) return null;
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final dueMidnight = DateTime(due.year, due.month, due.day);
    return dueMidnight.difference(todayMidnight).inDays;
  }

  String get daysLeftText {
    final d = daysLeft;
    if (d == null) return '';
    if (d < 0) {
      final daysAgo = d.abs();
      return daysAgo == 1 ? 'Overdue by 1 day' : 'Overdue by $daysAgo days';
    } else if (d == 0) {
      return 'Due Today';
    } else if (d == 1) {
      return '1 day left';
    } else {
      return '$d days left';
    }
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

  static String normalizeStatus(dynamic raw, {dynamic score, dynamic attachmentUrl, dynamic submittedAt, dynamic note}) {
    final s = raw?.toString().trim().toLowerCase() ?? '';
    if (s == 'reviewed' || s == 'graded' || s == 'checked') {
      return 'Reviewed';
    }
    if (s == 'submitted' || s == 'done' || s == 'complete' || s == 'completed' || s == 'turned_in') {
      return 'Submitted';
    }
    // If student has a score assigned already, mark as Reviewed or Submitted
    if (score != null && double.tryParse('$score') != null) {
      return 'Reviewed';
    }
    // If student has submitted an attachment or submission time or submission note
    if ((attachmentUrl != null && attachmentUrl.toString().trim().isNotEmpty) ||
        (submittedAt != null && submittedAt.toString().trim().isNotEmpty)) {
      return 'Submitted';
    }
    return 'Pending';
  }

  factory TeacherHomeworkSubmission.fromJson(Map<String, dynamic> json) {
    final student = json['student'] ?? {};
    final rawScore = json['score'];
    final rawAttachment = json['attachment_url'] ?? json['attachment'] ?? json['file_url'];
    final rawSubmittedAt = json['submitted_at'] ?? json['submittedAt'];
    final rawNote = json['note'];

    return TeacherHomeworkSubmission(
      studentId: json['student_id'] ?? student['id'] ?? 0,
      studentName: student['name'] ?? json['student_name'] ?? '',
      profileImageUrl: student['profile_image_url'] ?? json['profile_image_url'],
      status: normalizeStatus(
        json['status'],
        score: rawScore,
        attachmentUrl: rawAttachment,
        submittedAt: rawSubmittedAt,
        note: rawNote,
      ),
      score: rawScore != null ? double.tryParse('$rawScore') : null,
      note: rawNote,
      attachmentUrl: rawAttachment,
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

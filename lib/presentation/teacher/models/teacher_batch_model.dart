class TeacherBatch {
  final int id;
  final String name;
  final String? subject;
  final String? description;
  final String? feesLastDate;
  final String? startTime;
  final String? endTime;
  final List<String> days;
  final String? classroom;
  final String status;
  final bool teacherCanViewFees;
  final int? studentsCount;

  const TeacherBatch({
    required this.id,
    required this.name,
    this.subject,
    this.description,
    this.feesLastDate,
    this.startTime,
    this.endTime,
    this.days = const [],
    this.classroom,
    required this.status,
    required this.teacherCanViewFees,
    this.studentsCount,
  });

  factory TeacherBatch.fromJson(Map<String, dynamic> json) {
    return TeacherBatch(
      id: json['id'],
      name: json['name'] ?? '',
      subject: json['subject'],
      description: json['description'],
      feesLastDate: json['fees_last_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      days: (json['days'] as List?)?.map((e) => e.toString()).toList() ?? [],
      classroom: json['classroom'],
      status: json['status'] ?? 'active',
      teacherCanViewFees: json['teacher_can_view_fees'] == true,
      studentsCount: json['students_count'],
    );
  }
}

class TeacherBatchStudent {
  final int id;
  final String name;
  final String? enrollmentId;
  final String? profileImageUrl;

  const TeacherBatchStudent({
    required this.id,
    required this.name,
    this.enrollmentId,
    this.profileImageUrl,
  });

  factory TeacherBatchStudent.fromJson(Map<String, dynamic> json) {
    return TeacherBatchStudent(
      id: json['id'],
      name: json['name'] ?? '',
      enrollmentId: json['enrollment_id'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}

class TeacherBatchDetail {
  final TeacherBatch batch;
  final List<TeacherBatchStudent> students;

  const TeacherBatchDetail({required this.batch, required this.students});

  factory TeacherBatchDetail.fromJson(Map<String, dynamic> json) {
    return TeacherBatchDetail(
      batch: TeacherBatch.fromJson(json),
      students: (json['students'] as List? ?? [])
          .map((e) => TeacherBatchStudent.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

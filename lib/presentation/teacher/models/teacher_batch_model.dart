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
  final String? email;
  final String? phone;
  final String? enrollmentId;
  final String? profileImageUrl;
  final String? feeStatus;
  final String? standard;
  final String? guardianName;
  final num totalDue;
  final num totalPaid;
  final String? gender;

  const TeacherBatchStudent({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.enrollmentId,
    this.profileImageUrl,
    this.feeStatus,
    this.standard,
    this.guardianName,
    this.totalDue = 0,
    this.totalPaid = 0,
    this.gender,
  });

  factory TeacherBatchStudent.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic val, {int fallback = 0}) {
      if (val == null) return fallback;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? fallback;
    }

    return TeacherBatchStudent(
      id: safeInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      enrollmentId: json['enrollment_id']?.toString() ?? json['enrollmentId']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString() ?? json['avatar']?.toString(),
      feeStatus: json['fee_status']?.toString() ?? json['feeStatus']?.toString(),
      standard: json['standard']?.toString(),
      guardianName: json['guardian_name']?.toString() ?? json['father_name']?.toString(),
      totalDue: num.tryParse(json['total_due']?.toString() ?? '0') ?? 0,
      totalPaid: num.tryParse(json['total_paid']?.toString() ?? '0') ?? 0,
      gender: json['gender']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'enrollment_id': enrollmentId,
      'profile_image_url': profileImageUrl,
      'fee_status': feeStatus,
      'standard': standard,
      'guardian_name': guardianName,
      'total_due': totalDue,
      'total_paid': totalPaid,
      'gender': gender,
    };
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

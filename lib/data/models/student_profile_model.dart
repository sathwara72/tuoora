class StudentProfileModel {
  final StudentProfileHeader header;
  final StudentProfileStats stats;
  final StudentProfileQr studentQr;
  final StudentProfileInfo info;

  StudentProfileModel({
    required this.header,
    required this.stats,
    required this.studentQr,
    required this.info,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      header: StudentProfileHeader.fromJson(json['header'] ?? {}),
      stats: StudentProfileStats.fromJson(json['stats'] ?? {}),
      studentQr: StudentProfileQr.fromJson(json['student_qr'] ?? {}),
      info: StudentProfileInfo.fromJson(json['info'] ?? {}),
    );
  }

  StudentProfileModel copyWithAvatarUrl(String newAvatarUrl) {
    return StudentProfileModel(
      header: header.copyWithAvatarUrl(newAvatarUrl),
      stats: stats,
      studentQr: studentQr,
      info: info,
    );
  }

  StudentProfileModel copyWithStats(StudentProfileStats newStats) {
    return StudentProfileModel(
      header: header,
      stats: newStats,
      studentQr: studentQr,
      info: info,
    );
  }
}

class StudentProfileHeader {
  final String name;
  final String initials;
  final String avatarUrl;
  final String standard;
  final String batchName;
  final String subject;
  final String rollNo;
  final String memberSince;

  StudentProfileHeader({
    required this.name,
    required this.initials,
    required this.avatarUrl,
    required this.standard,
    required this.batchName,
    required this.subject,
    required this.rollNo,
    required this.memberSince,
  });

  factory StudentProfileHeader.fromJson(Map<String, dynamic> json) {
    return StudentProfileHeader(
      name: json['name'] ?? '',
      initials: json['initials'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      standard: json['standard'] ?? '',
      batchName: json['batch_name'] ?? '',
      subject: json['subject'] ?? '',
      rollNo: json['roll_no'] ?? '',
      memberSince: json['member_since'] ?? '',
    );
  }

  StudentProfileHeader copyWithAvatarUrl(String newAvatarUrl) {
    return StudentProfileHeader(
      name: name,
      initials: initials,
      avatarUrl: newAvatarUrl,
      standard: standard,
      batchName: batchName,
      subject: subject,
      rollNo: rollNo,
      memberSince: memberSince,
    );
  }
}

class StudentProfileStats {
  final int attendancePct;
  final String attendanceLabel;
  final int assignmentsPct;
  final String assignmentsLabel;
  final int performanceScore;
  final int examPct;
  final int homeworkPct;

  StudentProfileStats({
    required this.attendancePct,
    required this.attendanceLabel,
    required this.assignmentsPct,
    required this.assignmentsLabel,
    required this.performanceScore,
    this.examPct = 0,
    this.homeworkPct = 0,
  });

  factory StudentProfileStats.fromJson(Map<String, dynamic> json) {
    final att = (json['attendance_pct'] as num?)?.toInt() ?? 0;
    final hw = (json['homework_pct'] as num?)?.toInt() ??
        (json['assignments_pct'] as num?)?.toInt() ??
        0;
    final exam = (json['exam_pct'] as num?)?.toInt() ?? 0;
    int perf = (json['performance_score'] as num?)?.toInt() ?? 0;
    if (perf == 0 && (att > 0 || hw > 0 || exam > 0)) {
      perf = ((att + hw + exam) / 3).round();
    }

    return StudentProfileStats(
      attendancePct: att,
      attendanceLabel: json['attendance_label'] ?? '',
      assignmentsPct: (json['assignments_pct'] as num?)?.toInt() ?? hw,
      assignmentsLabel: json['assignments_label'] ?? '',
      performanceScore: perf,
      examPct: exam,
      homeworkPct: hw,
    );
  }

  StudentProfileStats copyWith({
    int? attendancePct,
    String? attendanceLabel,
    int? assignmentsPct,
    String? assignmentsLabel,
    int? performanceScore,
    int? examPct,
    int? homeworkPct,
  }) {
    return StudentProfileStats(
      attendancePct: attendancePct ?? this.attendancePct,
      attendanceLabel: attendanceLabel ?? this.attendanceLabel,
      assignmentsPct: assignmentsPct ?? this.assignmentsPct,
      assignmentsLabel: assignmentsLabel ?? this.assignmentsLabel,
      performanceScore: performanceScore ?? this.performanceScore,
      examPct: examPct ?? this.examPct,
      homeworkPct: homeworkPct ?? this.homeworkPct,
    );
  }
}

class StudentProfileQr {
  final String idHash;
  final String displayId;
  final String hint;

  StudentProfileQr({
    required this.idHash,
    required this.displayId,
    required this.hint,
  });

  factory StudentProfileQr.fromJson(Map<String, dynamic> json) {
    return StudentProfileQr(
      idHash: json['id_hash'] ?? '',
      displayId: json['display_id'] ?? '',
      hint: json['hint'] ?? '',
    );
  }
}

class StudentProfileInfo {
  final String phone;
  final String email;
  final String? parentName;
  final String? parentPhone;
  final String parentRelation;

  StudentProfileInfo({
    required this.phone,
    required this.email,
    this.parentName,
    this.parentPhone,
    required this.parentRelation,
  });

  factory StudentProfileInfo.fromJson(Map<String, dynamic> json) {
    return StudentProfileInfo(
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      parentRelation: json['parent_relation'] ?? '',
    );
  }
}

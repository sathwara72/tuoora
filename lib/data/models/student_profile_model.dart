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
    final qr = StudentProfileQr.fromJson(json['student_qr'] ?? {});
    final fallbackEnrollment = json['enrollment_id']?.toString() ??
        json['enrollment_no']?.toString() ??
        json['enrollment']?.toString();

    return StudentProfileModel(
      header: StudentProfileHeader.fromJson(
        json['header'] ?? {},
        fallbackEnrollment: fallbackEnrollment,
      ),
      stats: StudentProfileStats.fromJson(json['stats'] ?? {}),
      studentQr: qr,
      info: StudentProfileInfo.fromJson(
        (json['info'] as Map?)?.cast<String, dynamic>() ?? {},
        rootJson: json,
      ),
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
  final String batchName;
  final String subject;
  final String rollNo;
  final String memberSince;
  final String enrollment;

  StudentProfileHeader({
    required this.name,
    required this.initials,
    required this.avatarUrl,
    required this.batchName,
    required this.subject,
    required this.rollNo,
    required this.memberSince,
    this.enrollment = '',
  });

  factory StudentProfileHeader.fromJson(
    Map<String, dynamic> json, {
    String? fallbackEnrollment,
  }) {
    final parsedEnrollment = json['enrollment']?.toString() ??
        json['enrollment_id']?.toString() ??
        json['enrollment_no']?.toString() ??
        (fallbackEnrollment != null && fallbackEnrollment.isNotEmpty
            ? fallbackEnrollment
            : null) ??
        '';

    return StudentProfileHeader(
      name: json['name'] ?? '',
      initials: json['initials'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      batchName: json['batch_name'] ?? '',
      subject: json['subject'] ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
      memberSince: json['member_since'] ?? '',
      enrollment: parsedEnrollment,
    );
  }

  StudentProfileHeader copyWithAvatarUrl(String newAvatarUrl) {
    return StudentProfileHeader(
      name: name,
      initials: initials,
      avatarUrl: newAvatarUrl,
      batchName: batchName,
      subject: subject,
      rollNo: rollNo,
      memberSince: memberSince,
      enrollment: enrollment,
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
  final String? schoolName;
  final List<String> optionalPhones;

  StudentProfileInfo({
    required this.phone,
    required this.email,
    this.parentName,
    this.parentPhone,
    required this.parentRelation,
    this.schoolName,
    this.optionalPhones = const [],
  });

  factory StudentProfileInfo.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? rootJson,
  }) {
    List<String> parseOptional(dynamic val) {
      if (val is List) {
        return val
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      } else if (val is String && val.trim().isNotEmpty) {
        return [val.trim()];
      }
      return const [];
    }

    final parsedOptionalPhones = parseOptional(json['optional_phones']).isNotEmpty
        ? parseOptional(json['optional_phones'])
        : (rootJson != null ? parseOptional(rootJson['optional_phones']) : const <String>[]);

    final rawSchool = json['school_name']?.toString() ??
        json['school']?.toString() ??
        rootJson?['school_name']?.toString() ??
        rootJson?['school']?.toString();

    final cleanSchool =
        (rawSchool != null && rawSchool.trim().isNotEmpty && rawSchool.trim().toLowerCase() != 'null')
            ? rawSchool.trim()
            : null;

    final studentMap = rootJson?['student'] is Map ? rootJson!['student'] as Map : null;
    final fallbackSchool = studentMap?['school_name']?.toString() ?? studentMap?['school']?.toString();
    final effectiveSchool = cleanSchool ??
        ((fallbackSchool != null && fallbackSchool.trim().isNotEmpty) ? fallbackSchool.trim() : null);

    final effectiveOptional = parsedOptionalPhones.isNotEmpty
        ? parsedOptionalPhones
        : (studentMap != null ? parseOptional(studentMap['optional_phones']) : const <String>[]);

    return StudentProfileInfo(
      phone: json['phone']?.toString() ??
          rootJson?['phone']?.toString() ??
          studentMap?['phone']?.toString() ??
          '',
      email: json['email']?.toString() ??
          rootJson?['email']?.toString() ??
          studentMap?['email']?.toString() ??
          '',
      parentName: json['parent_name']?.toString() ??
          rootJson?['guardian_name']?.toString() ??
          studentMap?['guardian_name']?.toString(),
      parentPhone: json['parent_phone']?.toString() ??
          rootJson?['guardian_phone']?.toString() ??
          studentMap?['guardian_phone']?.toString(),
      parentRelation: json['parent_relation']?.toString() ?? 'Guardian',
      schoolName: effectiveSchool,
      optionalPhones: effectiveOptional,
    );
  }
}

class StudentIdCard {
  final String studentName;
  final String? studentPhone;
  final String? studentStandard;
  final String? studentDob;
  final String? studentProfileImageUrl;
  final String batchName;
  final String instituteName;
  final String? instituteLogoUrl;
  final String? instituteAddress;
  final String? instituteCity;
  final String? institutePhone;
  final String qrPayload;
  final String verificationHash;

  const StudentIdCard({
    required this.studentName,
    this.studentPhone,
    this.studentStandard,
    this.studentDob,
    this.studentProfileImageUrl,
    required this.batchName,
    required this.instituteName,
    this.instituteLogoUrl,
    this.instituteAddress,
    this.instituteCity,
    this.institutePhone,
    required this.qrPayload,
    required this.verificationHash,
  });

  factory StudentIdCard.fromJson(Map<String, dynamic> json) {
    final student = Map<String, dynamic>.from(json['student'] ?? {});
    final institute = Map<String, dynamic>.from(json['institute'] ?? {});

    return StudentIdCard(
      studentName: student['name'] ?? '',
      studentPhone: student['phone'],
      studentStandard: student['standard'],
      studentDob: student['dob'],
      studentProfileImageUrl: student['profile_image_url'],
      batchName: student['batch'] ?? 'N/A',
      instituteName: institute['institute_name'] ?? '',
      instituteLogoUrl: institute['logo_url'],
      instituteAddress: institute['address'],
      instituteCity: institute['city'],
      institutePhone: institute['phone'],
      qrPayload: json['qr_payload']?.toString() ?? '',
      verificationHash: json['verification_hash']?.toString() ?? '',
    );
  }
}

class TeacherProfile {
  final int id;
  final String? employeeId;
  final String fullName;
  final String email;
  final String? phone;
  final String? role;
  final String? department;
  final String? employmentType;
  final String? baseSalary;
  final String status;
  final String? profileUrl;
  final String? instituteName;
  final String? instituteLogo;

  const TeacherProfile({
    required this.id,
    this.employeeId,
    required this.fullName,
    required this.email,
    this.phone,
    this.role,
    this.department,
    this.employmentType,
    this.baseSalary,
    required this.status,
    this.profileUrl,
    this.instituteName,
    this.instituteLogo,
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    final institute = json['institute'];
    final role = json['role'];
    final department = json['department'];
    return TeacherProfile(
      id: json['id'],
      employeeId: json['employee_id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: role is Map ? role['name']?.toString() : role?.toString(),
      department: department is Map
          ? department['name']?.toString()
          : department?.toString(),
      employmentType: json['employment_type'],
      baseSalary: json['base_salary']?.toString(),
      status: json['status'] ?? 'active',
      profileUrl: json['profile_url'],
      instituteName: institute is Map ? institute['institute_name'] : null,
      instituteLogo: institute is Map ? institute['logo'] : null,
    );
  }
}

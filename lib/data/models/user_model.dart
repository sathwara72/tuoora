class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String accessToken;
  final String refreshToken;
  final String token;
  final String role; // 'INSTITUTE', 'STUDENT'
  final String? instituteName;
  final String? logo;
  final String? address;
  final int? instituteId;
  final int? batchId;
  final String? standard;
  final String? idHash;
  final String? city;
  final String? state;
  final String? pincode;
  final String? website;
  final String? youtube;
  final String? instagram;
  final bool isProfileSetup;
  final String? emailVerifiedAt;
  final String? staffRole;
  final String? department;
  final bool mustChangePassword;
  final String? profileImage;

  bool get isEmailVerified =>
      emailVerifiedAt != null && emailVerifiedAt!.isNotEmpty;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.token,
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    this.instituteName,
    this.logo,
    this.address,
    this.instituteId,
    this.batchId,
    this.standard,
    this.idHash,
    this.city,
    this.state,
    this.pincode,
    this.website,
    this.youtube,
    this.instagram,
    this.isProfileSetup = true,
    this.emailVerifiedAt,
    this.staffRole,
    this.department,
    this.mustChangePassword = false,
    this.profileImage,
  });

  factory User.fromJson(
    Map<String, dynamic> json,
    String token,
    String role, {
    String? accessToken,
    String? refreshToken,
  }) {
    final institute = json['institute'];
    return User(
      id: json['id'],
      name: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      token: token,
      accessToken: accessToken ?? token,
      refreshToken: refreshToken ?? '',
      role: role,
      instituteName:
          json['institute_name'] ??
          (institute is Map ? institute['institute_name'] : null),
      logo: json['logo'] ?? (institute is Map ? institute['logo'] : null),
      address: json['address'],
      instituteId:
          json['institute_id'] ?? (institute is Map ? institute['id'] : null),
      batchId: json['batch_id'],
      standard: json['standard'],
      idHash: json['id_hash'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      website: json['website'],
      youtube: json['youtube'],
      instagram: json['instagram'],
      isProfileSetup: json['is_profile_setup'] ?? true,
      emailVerifiedAt: json['email_verified_at']?.toString(),
      staffRole: _extractLabel(json['staff_role'] ?? json['role']),
      department: _extractLabel(json['staff_department'] ?? json['department']),
      mustChangePassword: json['must_change_password'] == true,
      profileImage: json['profile_url'] ?? json['profile_image'],
    );
  }

  static String? _extractLabel(dynamic value) {
    if (value is String) return value;
    if (value is Map) {
      return value['name']?.toString() ?? value['title']?.toString();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'role': role,
      'institute_name': instituteName,
      'logo': logo,
      'address': address,
      'institute_id': instituteId,
      'batch_id': batchId,
      'standard': standard,
      'id_hash': idHash,
      'city': city,
      'state': state,
      'pincode': pincode,
      'website': website,
      'youtube': youtube,
      'instagram': instagram,
      'is_profile_setup': isProfileSetup,
      'email_verified_at': emailVerifiedAt,
      'staff_role': staffRole,
      'staff_department': department,
      'must_change_password': mustChangePassword,
      'profile_url': profileImage,
    };
  }

  User copyWith({
    String? accessToken,
    String? refreshToken,
    bool? mustChangePassword,
  }) {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
      token: accessToken ?? this.accessToken,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      role: role,
      instituteName: instituteName,
      logo: logo,
      address: address,
      instituteId: instituteId,
      batchId: batchId,
      standard: standard,
      idHash: idHash,
      city: city,
      state: state,
      pincode: pincode,
      website: website,
      youtube: youtube,
      instagram: instagram,
      isProfileSetup: isProfileSetup,
      emailVerifiedAt: emailVerifiedAt,
      staffRole: staffRole,
      department: department,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      profileImage: profileImage,
    );
  }
}

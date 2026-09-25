class InstituteProfile {
  final int id;
  final String name;
  final String? instituteCode;
  final String email;
  final String phone;
  final String? instituteName;
  final String? address;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? website;
  final String? youtube;
  final String? instagram;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? logoUrl;
  final String? upiId;
  final String? upiQrCodeUrl;
  final String? device;
  final String? os;
  final String? lastLogin;
  final String? lastOpen;
  final String? fcmToken;
  List<ActiveSessions>? activeSessions;
  // When i hit the institute profile get api the  in the response i get active session array that should be add in

  InstituteProfile({
    required this.id,
    required this.name,
    this.instituteCode,
    required this.email,
    required this.phone,
    this.instituteName,
    this.address,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.website,
    this.youtube,
    this.instagram,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.logoUrl,
    this.upiId,
    this.upiQrCodeUrl,
    this.device,
    this.os,
    this.lastLogin,
    this.lastOpen,
    this.fcmToken,
    this.activeSessions,
  });

  factory InstituteProfile.fromJson(Map<String, dynamic> json) {
    return InstituteProfile(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      instituteCode: json['institute_code']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      instituteName: json['institute_name']?.toString(),
      address: json['address']?.toString(),
      addressLine2: json['address_line_2']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      pincode: json['pincode']?.toString(),
      website: json['website']?.toString(),
      youtube: json['youtube']?.toString(),
      instagram: json['instagram']?.toString(),
      status: json['status']?.toString() ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      logoUrl: json['logo_url']?.toString(),
      upiId: json['upi_id']?.toString(),
      upiQrCodeUrl: json['upi_qr_code_url']?.toString(),
      device: json['device']?.toString(),
      os: json['os']?.toString(),
      lastLogin: json['last_login']?.toString(),
      lastOpen: json['last_open']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
      activeSessions: json['active_sessions'] != null
          ? List<ActiveSessions>.from(
              (json['active_sessions'] as List).map((x) => ActiveSessions.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'institute_code': instituteCode,
      'email': email,
      'phone': phone,
      'institute_name': instituteName,
      'address': address,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'website': website,
      'youtube': youtube,
      'instagram': instagram,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'logo_url': logoUrl,
      'upi_id': upiId,
      'upi_qr_code_url': upiQrCodeUrl,
      'device': device,
      'os': os,
      'last_login': lastLogin,
      'last_open': lastOpen,
      'fcm_token': fcmToken,
      'active_sessions': activeSessions?.map((x) => x.toJson()).toList(),
    };
  }

  InstituteProfile copyWithPayment({String? upiId, String? upiQrCodeUrl}) {
    return InstituteProfile(
      id: id,
      name: name,
      instituteCode: instituteCode,
      email: email,
      phone: phone,
      instituteName: instituteName,
      address: address,
      addressLine2: addressLine2,
      city: city,
      state: state,
      country: country,
      pincode: pincode,
      website: website,
      youtube: youtube,
      instagram: instagram,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      logoUrl: logoUrl,
      upiId: upiId ?? this.upiId,
      upiQrCodeUrl: upiQrCodeUrl ?? this.upiQrCodeUrl,
      device: device,
      os: os,
      lastLogin: lastLogin,
      lastOpen: lastOpen,
      fcmToken: fcmToken,
      activeSessions: activeSessions,
    );
  }
}

class ActiveSessions {
  int? id;
  String? device;
  String? os;
  String? lastLogin;
  String? lastOpen;
  String? fcmToken;
  bool? isCurrent;
  bool? isApp;
  String? sessionType;

  ActiveSessions({
    this.id,
    this.device,
    this.os,
    this.lastLogin,
    this.lastOpen,
    this.fcmToken,
    this.isCurrent,
    this.isApp,
    this.sessionType,
  });

  ActiveSessions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    device = json['device'];
    os = json['os'];
    lastLogin = json['last_login'];
    lastOpen = json['last_open'];
    fcmToken = json['fcm_token'];
    isCurrent = json['is_current'];
    isApp = json['is_app'];
    sessionType = json['session_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['device'] = device;
    data['os'] = os;
    data['last_login'] = lastLogin;
    data['last_open'] = lastOpen;
    data['fcm_token'] = fcmToken;
    data['is_current'] = isCurrent;
    data['is_app'] = isApp;
    data['session_type'] = sessionType;
    return data;
  }
}

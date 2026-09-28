class NotificationPreferenceModule {
  final String module;
  final String name;
  final String desc;
  final String icon;
  bool whatsappEnabled;
  bool pushEnabled;
  bool emailEnabled;

  NotificationPreferenceModule({
    required this.module,
    required this.name,
    required this.desc,
    required this.icon,
    this.whatsappEnabled = true,
    this.pushEnabled = true,
    this.emailEnabled = true,
  });

  bool get isAnyActive => whatsappEnabled || pushEnabled || emailEnabled;

  factory NotificationPreferenceModule.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModule(
      module: json['module']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🔔',
      whatsappEnabled: json['whatsapp_enabled'] == true ||
          json['whatsapp'] == true ||
          json['whatsapp_enabled'] == 1,
      pushEnabled: json['push_enabled'] == true ||
          json['push'] == true ||
          json['push_enabled'] == 1,
      emailEnabled: json['email_enabled'] == true ||
          json['email'] == true ||
          json['email_enabled'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'whatsapp': whatsappEnabled,
      'push': pushEnabled,
      'email': emailEnabled,
    };
  }

  NotificationPreferenceModule copyWith({
    String? module,
    String? name,
    String? desc,
    String? icon,
    bool? whatsappEnabled,
    bool? pushEnabled,
    bool? emailEnabled,
  }) {
    return NotificationPreferenceModule(
      module: module ?? this.module,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      icon: icon ?? this.icon,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
    );
  }
}

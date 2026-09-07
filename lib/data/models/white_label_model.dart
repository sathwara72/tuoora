class WhiteLabelAddon {
  final String title;
  final String description;
  final double price;
  final String formattedPrice;
  final String billingType;
  final bool enabled;

  const WhiteLabelAddon({
    required this.title,
    required this.description,
    required this.price,
    required this.formattedPrice,
    required this.billingType,
    required this.enabled,
  });

  factory WhiteLabelAddon.fromJson(Map<String, dynamic> json) {
    return WhiteLabelAddon(
      title: json['title'] ?? 'Mobile App White Label',
      description: json['description'] ?? '',
      price: double.tryParse('${json['price']}') ?? 0,
      formattedPrice: json['formatted_price'] ?? '',
      billingType: json['billing_type'] ?? 'One Time',
      enabled: json['enabled'] ?? true,
    );
  }
}

class WhiteLabelRecord {
  final int id;
  final String status;
  final String? appName;
  final String? logoUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final bool isActive;
  final bool brandingComplete;
  final DateTime? adminConfirmedAt;
  final String? adminNotes;

  const WhiteLabelRecord({
    required this.id,
    required this.status,
    this.appName,
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
    required this.isActive,
    required this.brandingComplete,
    this.adminConfirmedAt,
    this.adminNotes,
  });

  bool get isReviewed => adminConfirmedAt != null;

  factory WhiteLabelRecord.fromJson(Map<String, dynamic> json) {
    return WhiteLabelRecord(
      id: json['id'],
      status: json['status'] ?? 'pending',
      appName: json['app_name'],
      logoUrl: json['app_logo_url'],
      primaryColor: json['primary_color'],
      secondaryColor: json['secondary_color'],
      isActive: json['is_active'] ?? false,
      brandingComplete: json['branding_complete'] ?? false,
      adminConfirmedAt: json['admin_confirmed_at'] != null
          ? DateTime.tryParse(json['admin_confirmed_at'])
          : null,
      adminNotes: json['admin_notes'],
    );
  }
}

class WhiteLabelStatus {
  final bool purchased;
  final WhiteLabelRecord? record;
  final WhiteLabelAddon addon;

  const WhiteLabelStatus({
    required this.purchased,
    this.record,
    required this.addon,
  });

  factory WhiteLabelStatus.fromJson(Map<String, dynamic> json) {
    return WhiteLabelStatus(
      purchased: json['purchased'] ?? false,
      record: json['record'] != null
          ? WhiteLabelRecord.fromJson(Map<String, dynamic>.from(json['record']))
          : null,
      addon: WhiteLabelAddon.fromJson(Map<String, dynamic>.from(json['addon'] ?? {})),
    );
  }
}

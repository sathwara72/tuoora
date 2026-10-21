class WhatsAppSettings {
  final int? id;
  final int? instituteId;
  final String phoneNumber;
  final String accessToken;
  final String phoneNumberId;
  final String businessAccountId;
  final bool isActive;
  final String? lastVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  WhatsAppSettings({
    this.id,
    this.instituteId,
    required this.phoneNumber,
    required this.accessToken,
    required this.phoneNumberId,
    required this.businessAccountId,
    this.isActive = false,
    this.lastVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory WhatsAppSettings.fromJson(Map<String, dynamic> json) {
    return WhatsAppSettings(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      instituteId: json['institute_id'] is int ? json['institute_id'] : int.tryParse(json['institute_id']?.toString() ?? ''),
      phoneNumber: json['phone_number']?.toString() ?? '',
      accessToken: json['access_token']?.toString() ?? '',
      phoneNumberId: json['phone_number_id']?.toString() ?? '',
      businessAccountId: json['business_account_id']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      lastVerifiedAt: json['last_verified_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'access_token': accessToken,
      'phone_number_id': phoneNumberId,
      'business_account_id': businessAccountId,
      'is_active': isActive ? 1 : 0,
    };
  }
}

class WhatsAppWallet {
  final int balance;
  final String formattedBalance;
  final String unit;
  final bool isLow;

  WhatsAppWallet({
    required this.balance,
    required this.formattedBalance,
    required this.unit,
    required this.isLow,
  });

  factory WhatsAppWallet.fromJson(Map<String, dynamic> json) {
    return WhatsAppWallet(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      formattedBalance: json['formatted_balance']?.toString() ?? '0',
      unit: json['unit']?.toString() ?? 'Messages',
      isLow: json['is_low'] == true,
    );
  }
}

class WhatsAppPackItem {
  final int id;
  final String name;
  final int credits;
  final String formattedCredits;
  final double price;
  final String priceFormatted;
  final String costPerMessage;

  WhatsAppPackItem({
    required this.id,
    required this.name,
    required this.credits,
    required this.formattedCredits,
    required this.price,
    required this.priceFormatted,
    required this.costPerMessage,
  });

  factory WhatsAppPackItem.fromJson(Map<String, dynamic> json) {
    return WhatsAppPackItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      formattedCredits: json['formatted_credits']?.toString() ?? '0',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      priceFormatted: json['price_formatted']?.toString() ?? '₹0.00',
      costPerMessage: json['cost_per_message']?.toString() ?? '₹0.00',
    );
  }
}

class WhatsAppLogItem {
  final int id;
  final String recipientName;
  final String? parentName;
  final String message;
  final String status;
  final bool isSent;
  final String? metaMessageId;
  final String? errorMessage;
  final String? sentAt;
  final String? createdAt;

  WhatsAppLogItem({
    required this.id,
    required this.recipientName,
    this.parentName,
    required this.message,
    required this.status,
    required this.isSent,
    this.metaMessageId,
    this.errorMessage,
    this.sentAt,
    this.createdAt,
  });

  factory WhatsAppLogItem.fromJson(Map<String, dynamic> json) {
    return WhatsAppLogItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      recipientName: json['recipient_name']?.toString() ?? 'Direct Number',
      parentName: json['parent_name']?.toString(),
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'sent',
      isSent: json['is_sent'] == true || json['status'] == 'sent',
      metaMessageId: json['meta_message_id']?.toString(),
      errorMessage: json['error_message']?.toString(),
      sentAt: json['sent_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class WhatsAppOverviewData {
  final WhatsAppWallet wallet;
  final bool isWhiteLabel;
  final bool hasDedicatedWhatsApp;
  final String mode;
  final String modeTitle;
  final String modeBadge;
  final String modeDescription;
  final WhatsAppSettings? settings;
  final List<WhatsAppPackItem> packs;
  final List<WhatsAppLogItem> recentLogs;

  WhatsAppOverviewData({
    required this.wallet,
    required this.isWhiteLabel,
    required this.hasDedicatedWhatsApp,
    required this.mode,
    required this.modeTitle,
    required this.modeBadge,
    required this.modeDescription,
    this.settings,
    required this.packs,
    required this.recentLogs,
  });

  factory WhatsAppOverviewData.fromJson(Map<String, dynamic> json) {
    final modeInfo = json['mode_info'] as Map<String, dynamic>? ?? {};
    return WhatsAppOverviewData(
      wallet: WhatsAppWallet.fromJson(json['wallet'] as Map<String, dynamic>? ?? {}),
      isWhiteLabel: json['is_white_label'] == true,
      hasDedicatedWhatsApp: json['has_dedicated_whatsapp'] == true,
      mode: json['mode']?.toString() ?? 'tuoora_gateway',
      modeTitle: modeInfo['title']?.toString() ?? 'Automated WhatsApp Messaging Active',
      modeBadge: modeInfo['badge']?.toString() ?? 'Tuoora Official Gateway',
      modeDescription: modeInfo['description']?.toString() ?? '',
      settings: json['settings'] != null ? WhatsAppSettings.fromJson(json['settings']) : null,
      packs: (json['packs'] as List<dynamic>? ?? [])
          .map((e) => WhatsAppPackItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentLogs: (json['recent_logs'] as List<dynamic>? ?? [])
          .map((e) => WhatsAppLogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
import 'package:tuoora/core/constants/url_constants.dart';

class SubscriptionPlan {
  final int id;
  final String name;
  final String price;
  final int durationDays;
  final int trialDays;
  final int status;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.trialDays,
    required this.status,
  });

  bool get isFree => (double.tryParse(price) ?? 0) == 0;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      durationDays: json['duration_days'] ?? 0,
      trialDays: json['trial_days'] ?? 0,
      status: json['status'] ?? 0,
    );
  }
}

class SubscriptionDetails {
  final String planName;
  final String price;
  final String status;
  final DateTime? expiresAt;
  final int studentsEnrolled;
  final int studentLimit;

  SubscriptionDetails({
    required this.planName,
    required this.price,
    required this.status,
    this.expiresAt,
    required this.studentsEnrolled,
    required this.studentLimit,
  });

  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetails(
      planName: json['plan_name'] ?? 'No Active Plan',
      price: json['price']?.toString() ?? '0',
      status: json['status'] ?? 'Inactive',
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at']).toLocal()
          : null,
      studentsEnrolled: json['students_enrolled'] ?? 0,
      studentLimit: json['student_limit'] ?? 0,
    );
  }
}

class SubscriptionHistory {
  final int id;
  final String planName;
  final String amount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  SubscriptionHistory({
    required this.id,
    required this.planName,
    required this.amount,
    this.startDate,
    this.endDate,
    required this.status,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      id: json['id'] ?? 0,
      planName: json['plan_name'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date']).toLocal()
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date']).toLocal()
          : null,
      status: json['status'] ?? '',
    );
  }
}

class SubscriptionPaymentSettings {
  final String? bankHolderName;
  final String? bankName;
  final String? bankAccount;
  final String? bankIfsc;
  final String? upiId;
  final String? qrPath;
  final String? qrUrl;

  const SubscriptionPaymentSettings({
    this.bankHolderName,
    this.bankName,
    this.bankAccount,
    this.bankIfsc,
    this.upiId,
    this.qrPath,
    this.qrUrl,
  });

  factory SubscriptionPaymentSettings.fromJson(Map<String, dynamic> json) {
    String? s(String key) {
      final v = json[key]?.toString().trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    final rawQrUrl = s('qr_url');
    return SubscriptionPaymentSettings(
      bankHolderName: s('bank_holder_name'),
      bankName: s('bank_name'),
      bankAccount: s('bank_account'),
      bankIfsc: s('bank_ifsc'),
      upiId: s('upi_id'),
      qrPath: s('qr_path'),
      // Resolve server-relative paths to absolute URLs so CachedNetworkImage
      // can load them (the API returns /admin/storage/... not https://...).
      qrUrl: rawQrUrl != null ? UrlConstants.resolveUrl(rawQrUrl) : null,
    );
  }

  bool get hasBankDetails =>
      (bankHolderName?.isNotEmpty ?? false) ||
      (bankName?.isNotEmpty ?? false) ||
      (bankAccount?.isNotEmpty ?? false) ||
      (bankIfsc?.isNotEmpty ?? false);
}

class InstituteSubscriptionData {
  final SubscriptionDetails subscription;
  final List<SubscriptionPlan> plans;
  final List<SubscriptionHistory> history;
  final SubscriptionPaymentSettings? paymentSettings;

  InstituteSubscriptionData({
    required this.subscription,
    required this.plans,
    required this.history,
    this.paymentSettings,
  });

  factory InstituteSubscriptionData.fromJson(Map<String, dynamic> json) {
    return InstituteSubscriptionData(
      subscription: SubscriptionDetails.fromJson(json['subscription'] ?? {}),
      plans:
          (json['plans'] as List?)
              ?.map((e) => SubscriptionPlan.fromJson(e))
              .toList() ??
          [],
      history:
          (json['history'] as List?)
              ?.map((e) => SubscriptionHistory.fromJson(e))
              .toList() ??
          [],
      paymentSettings: json['payment_settings'] is Map
          ? SubscriptionPaymentSettings.fromJson(
              (json['payment_settings'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

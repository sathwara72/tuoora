class Subscription {
  final int id;
  final int? instituteId;
  final String planName;
  final String amount;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String effectiveStatus;
  final String statusLabel;
  /// 0 for lifetime plans (the server sends null); check [isLifetime] first.
  final int daysLeft;

  /// Lifetime plans never expire; their end date is a far-future placeholder.
  final bool isLifetime;

  const Subscription({
    required this.id,
    this.instituteId,
    required this.planName,
    required this.amount,
    this.startDate,
    this.endDate,
    required this.status,
    this.effectiveStatus = '',
    this.statusLabel = '',
    this.daysLeft = 0,
    this.isLifetime = false,
  });

  bool get isActive => effectiveStatus.toLowerCase() == 'active';
  bool get isExpired => effectiveStatus.toLowerCase() == 'expired';
  bool get isPending => effectiveStatus.toLowerCase() == 'pending';
  bool get isCancel => effectiveStatus.toLowerCase() == 'cancel';
  bool get isExpireSoon => effectiveStatus.toLowerCase() == 'expire_soon';
  bool get isReject => effectiveStatus.toLowerCase() == 'reject';

  Subscription copyWith({String? status}) {
    return Subscription(
      id: id,
      instituteId: instituteId,
      planName: planName,
      amount: amount,
      startDate: startDate,
      endDate: endDate,
      status: status ?? this.status,
      effectiveStatus: effectiveStatus,
      statusLabel: statusLabel,
      daysLeft: daysLeft,
      isLifetime: isLifetime,
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString())?.toLocal();
    }

    return Subscription(
      id: json['id'] ?? 0,
      instituteId: json['institute_id'],
      planName: json['plan_name'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      status: (json['status'] ?? '').toString(),
      effectiveStatus: (json['effective_status'] ?? json['status'] ?? '').toString(),
      statusLabel: (json['status_label'] ?? '').toString(),
      daysLeft: int.tryParse(json['days_left']?.toString() ?? '') ?? 0,
      isLifetime: json['is_lifetime'] == true || json['is_lifetime'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institute_id': instituteId,
      'plan_name': planName,
      'amount': amount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'effective_status': effectiveStatus,
      'status_label': statusLabel,
      'days_left': daysLeft,
      'is_lifetime': isLifetime,
    };
  }
}

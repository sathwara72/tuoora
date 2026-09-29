class Student {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int instituteId;
  final String? enrollmentID;
  final int? parentId;
  final int? batchId;
  final String dob;
  final String? guardianName;
  final String? monthlyFee;
  final String? schoolName;
  final String status;
  final String idHash;
  final String createdAt;
  final String updatedAt;
  final String profileImageUrl;
  final dynamic batch;
  final num totalDue;
  final num totalPaid;
  final List<StudentFee> fees;
  final num? totalFee;
  final dynamic selectedBatchId;
  final dynamic selectedBatch;
  final List<dynamic> allBatches;
  final bool isLoginBlocked;
  final bool doNotSendFeeReminders;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;

  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.instituteId,
    this.enrollmentID,
    this.parentId,
    this.batchId,
    required this.dob,
    this.guardianName,
    this.monthlyFee,
    this.schoolName,
    required this.status,
    required this.idHash,
    required this.createdAt,
    required this.updatedAt,
    required this.profileImageUrl,
    this.batch,
    this.totalDue = 0,
    this.totalPaid = 0,
    this.fees = const [],
    this.totalFee,
    this.selectedBatchId,
    this.selectedBatch,
    this.allBatches = const [],
    this.isLoginBlocked = false,
    this.doNotSendFeeReminders = false,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.pincode,
  });

  static bool _asBool(dynamic v) => v == true || v == 1 || v == '1';

  factory Student.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? fallback;
    }

    int? safeNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return Student(
      id: safeInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      instituteId: safeInt(json['institute_id']),
      enrollmentID: json['enrollment_id'],
      parentId: safeNullableInt(json['parent_id']),
      batchId: safeNullableInt(json['batch_id']),
      dob: json['dob']?.toString() ?? '',
      guardianName: json['guardian_name']?.toString(),
      monthlyFee: json['monthly_fee']?.toString(),
      schoolName: json['school_name']?.toString(),
      status: json['status']?.toString() ?? '1',
      idHash:
          json['id_hash']?.toString() ??
          json['enrollment_id']?.toString() ??
          '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      profileImageUrl: json['profile_image_url']?.toString() ?? '',
      batch: json['batch'],
      totalDue: num.tryParse(json['total_due']?.toString() ?? '0') ?? 0,
      totalPaid: num.tryParse(json['total_paid']?.toString() ?? '0') ?? 0,
      fees:
          (json['fees'] as List?)
              ?.whereType<Map>()
              .map((e) => StudentFee.fromJson(e.cast<String, dynamic>()))
              .toList() ??
          const [],
      totalFee: num.tryParse(json['total_fee']?.toString() ?? '') ?? (num.tryParse(json['monthly_fee']?.toString() ?? '0') ?? 0),
      selectedBatchId: json['selected_batch_id'],
      selectedBatch: json['selected_batch'],
      allBatches: (json['all_batches'] as List?) ?? const [],
      isLoginBlocked: _asBool(json['is_login_blocked']),
      doNotSendFeeReminders: _asBool(json['do_not_send_fee_reminders']),
      addressLine1: json['address_line_1']?.toString(),
      addressLine2: json['address_line_2']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      pincode: json['pincode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'institute_id': instituteId,
      'enrollment_id': enrollmentID,
      'parent_id': parentId,
      'batch_id': batchId,
      'dob': dob,
      'guardian_name': guardianName,
      'monthly_fee': monthlyFee,
      'school_name': schoolName,
      'status': status,
      'id_hash': idHash,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'profile_image_url': profileImageUrl,
      'batch': batch,
      'total_due': totalDue,
      'total_paid': totalPaid,
      'fees': fees.map((f) => f.toJson()).toList(),
      'total_fee': totalFee,
      'selected_batch_id': selectedBatchId,
      'selected_batch': selectedBatch,
      'all_batches': allBatches,
      'is_login_blocked': isLoginBlocked,
      'do_not_send_fee_reminders': doNotSendFeeReminders,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
    };
  }

  Student copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    int? instituteId,
    int? parentId,
    int? batchId,
    String? dob,
    String? guardianName,
    String? monthlyFee,
    String? schoolName,
    String? status,
    String? idHash,
    String? createdAt,
    String? updatedAt,
    String? profileImageUrl,
    dynamic batch,
    num? totalDue,
    num? totalPaid,
    List<StudentFee>? fees,
    num? totalFee,
    dynamic selectedBatchId,
    dynamic selectedBatch,
    List<dynamic>? allBatches,
    bool? isLoginBlocked,
    bool? doNotSendFeeReminders,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    String? pincode,
    // copyWith cannot set a field back to null, so removing a student from a
    // batch has to clear the batch explicitly.
    bool clearBatch = false,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      instituteId: instituteId ?? this.instituteId,
      parentId: parentId ?? this.parentId,
      batchId: clearBatch ? null : (batchId ?? this.batchId),
      dob: dob ?? this.dob,
      guardianName: guardianName ?? this.guardianName,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      schoolName: schoolName ?? this.schoolName,
      status: status ?? this.status,
      idHash: idHash ?? this.idHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      batch: clearBatch ? null : (batch ?? this.batch),
      totalDue: totalDue ?? this.totalDue,
      totalPaid: totalPaid ?? this.totalPaid,
      fees: fees ?? this.fees,
      totalFee: totalFee ?? this.totalFee,
      selectedBatchId: selectedBatchId ?? this.selectedBatchId,
      selectedBatch: selectedBatch ?? this.selectedBatch,
      allBatches: allBatches ?? this.allBatches,
      isLoginBlocked: isLoginBlocked ?? this.isLoginBlocked,
      doNotSendFeeReminders:
          doNotSendFeeReminders ?? this.doNotSendFeeReminders,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
    );
  }

  /// Address as one readable string, or empty when none was entered.
  String get fullAddress {
    final parts = [addressLine1, addressLine2, city, state, pincode, country]
        .map((e) => (e ?? '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  // Helper getters for UI compatibility
  String get imageUrl => profileImageUrl;
  String get currentBatchName {
    if (batch != null && batch is Map) {
      return batch['name'] ?? 'Not Assigned';
    }
    return 'Not Assigned';
  }

  /// The enrollment ID exactly as stored in the database, for display. Never
  /// built from the hash or row id.
  String get displayEnrollmentId {
    final e = enrollmentID?.trim() ?? '';
    return e.isNotEmpty ? e : 'N/A';
  }

  /// Stable key for routing/lookup only (falls back to hash, then row id).
  /// Do not show this to users; use [displayEnrollmentId].
  String get enrollmentId {
    final e = enrollmentID;
    if (e != null && e.isNotEmpty) return e;
    return idHash.isNotEmpty ? idHash : id.toString();
  }

  List<FeeInstallmentModel> get allInstallments {
    final list = <FeeInstallmentModel>[];
    for (final f in fees) {
      list.addAll(f.installments);
    }
    return list;
  }
}

class FeeInstallmentModel {
  final int id;
  final int feeId;
  final int studentId;
  final String title;
  final double amount;
  final double paidAmount;
  final String? dueDate;
  final String status;
  final int order;
  final String? notes;

  const FeeInstallmentModel({
    required this.id,
    this.feeId = 0,
    this.studentId = 0,
    required this.title,
    required this.amount,
    required this.paidAmount,
    this.dueDate,
    required this.status,
    this.order = 1,
    this.notes,
  });

  double get dueAmount {
    final diff = amount - paidAmount;
    return diff > 0 ? diff : 0.0;
  }

  bool get isPaid => status.toLowerCase() == 'paid' || dueAmount <= 0;
  bool get isPartial => !isPaid && paidAmount > 0;
  bool get isPending => !isPaid && !isPartial;

  factory FeeInstallmentModel.fromJson(Map<String, dynamic> json) {
    return FeeInstallmentModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      feeId: int.tryParse(json['fee_id']?.toString() ?? '0') ?? 0,
      studentId: int.tryParse(json['student_id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Installment',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0,
      dueDate: json['due_date']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      order: int.tryParse(json['order']?.toString() ?? '1') ?? 1,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fee_id': feeId,
    'student_id': studentId,
    'title': title,
    'amount': amount,
    'paid_amount': paidAmount,
    'due_date': dueDate,
    'status': status,
    'order': order,
    'notes': notes,
  };
}

class StudentFee {
  final int id;
  final int studentId;
  final int? batchId;
  final String totalAmount;
  final String paidAmount;
  final String status;
  final String date;
  final List<FeeInstallmentModel> installments;
  final List<dynamic> payments;

  const StudentFee({
    required this.id,
    required this.studentId,
    this.batchId,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.date,
    this.installments = const [],
    this.payments = const [],
  });

  factory StudentFee.fromJson(Map<String, dynamic> json) {
    return StudentFee(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      studentId: int.tryParse(json['student_id']?.toString() ?? '0') ?? 0,
      batchId: int.tryParse(json['batch_id']?.toString() ?? ''),
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      installments: (json['installments'] as List?)
              ?.whereType<Map>()
              .map((e) => FeeInstallmentModel.fromJson(e.cast<String, dynamic>()))
              .toList() ??
          const [],
      payments: (json['payments'] as List?) ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'student_id': studentId,
    'batch_id': batchId,
    'total_amount': totalAmount,
    'paid_amount': paidAmount,
    'status': status,
    'date': date,
    'installments': installments.map((i) => i.toJson()).toList(),
    'payments': payments,
  };
}
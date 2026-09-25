class Student {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int instituteId;
  final String? enrollmentID;
  final int? parentId;
  final int? batchId;
  final String standard;
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

  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.instituteId,
    this.enrollmentID,
    this.parentId,
    this.batchId,
    required this.standard,
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
  });

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
      standard: json['standard']?.toString() ?? '',
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
      'standard': standard,
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
    String? standard,
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
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      instituteId: instituteId ?? this.instituteId,
      parentId: parentId ?? this.parentId,
      batchId: batchId ?? this.batchId,
      standard: standard ?? this.standard,
      dob: dob ?? this.dob,
      guardianName: guardianName ?? this.guardianName,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      schoolName: schoolName ?? this.schoolName,
      status: status ?? this.status,
      idHash: idHash ?? this.idHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      batch: batch ?? this.batch,
      totalDue: totalDue ?? this.totalDue,
      totalPaid: totalPaid ?? this.totalPaid,
      fees: fees ?? this.fees,
    );
  }

  // Helper getters for UI compatibility
  String get grade => standard;
  String get imageUrl => profileImageUrl;
  String get currentBatchName {
    if (batch != null && batch is Map) {
      return batch['name'] ?? 'Not Assigned';
    }
    return 'Not Assigned';
  }

  String get enrollmentId => idHash.isNotEmpty ? idHash : id.toString();

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
  final String totalAmount;
  final String paidAmount;
  final String status;
  final String date;
  final List<FeeInstallmentModel> installments;
  final List<dynamic> payments;

  const StudentFee({
    required this.id,
    required this.studentId,
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
    'total_amount': totalAmount,
    'paid_amount': paidAmount,
    'status': status,
    'date': date,
    'installments': installments.map((i) => i.toJson()).toList(),
    'payments': payments,
  };
}
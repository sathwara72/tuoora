import 'package:tuoora/data/models/student_model.dart';

class FeeRecord {
  final int id;
  final int studentId;
  final int instituteId;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Student? student;
  final List<FeePayment> payments;
  final List<FeeInstallment> installments;

  FeeRecord({
    required this.id,
    required this.studentId,
    required this.instituteId,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.student,
    this.payments = const <FeePayment>[],
    this.installments = const <FeeInstallment>[],
  });

  FeePayment? get latestPayment {
    if (payments.isEmpty) return null;
    final sorted = [...payments]
      ..sort((a, b) {
        final aT = a.paidAt ?? DateTime(0);
        final bT = b.paidAt ?? DateTime(0);
        return bT.compareTo(aT);
      });
    return sorted.first;
  }

  factory FeeRecord.fromJson(Map<String, dynamic> json) {
    return FeeRecord(
      id: safeInt(json['id']),
      studentId: safeInt(json['student_id']),
      instituteId: safeInt(json['institute_id']),
      totalAmount: safeDouble(json['total_amount']),
      paidAmount: safeDouble(json['paid_amount']),
      status: safeString(json['status']),
      date: safeDate(json['date']),
      createdAt: safeDate(json['created_at']),
      updatedAt: safeDate(json['updated_at']),
      deletedAt: safeNullableDate(json['deleted_at']),
      student: json['student'] != null
          ? Student.fromJson(json['student'])
          : null,
      payments:
          (json['payments'] as List?)
              ?.whereType<Map>()
              .map((e) => FeePayment.fromJson(e.cast<String, dynamic>()))
              .toList() ??
          const <FeePayment>[],
      installments:
          (json['installments'] as List?)
              ?.whereType<Map>()
              .map((e) => FeeInstallment.fromJson(e.cast<String, dynamic>()))
              .toList() ??
          const <FeeInstallment>[],
    );
  }

  static int safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static String safeString(dynamic value) {
    return value?.toString() ?? "";
  }

  static DateTime safeDate(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static DateTime? safeNullableDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'institute_id': instituteId,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'status': status,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'student': student?.toJson(),
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }
}

class FeePayment {
  final int id;
  final int feeId;
  final int studentId;
  final double amount;
  final String paymentMethod;
  final String? transactionId;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const FeePayment({
    required this.id,
    required this.feeId,
    required this.studentId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory FeePayment.fromJson(Map<String, dynamic> json) {
    return FeePayment(
      id: FeeRecord.safeInt(json['id']),
      feeId: FeeRecord.safeInt(json['fee_id']),
      studentId: FeeRecord.safeInt(json['student_id']),
      amount: FeeRecord.safeDouble(json['amount']),
      paymentMethod: FeeRecord.safeString(json['payment_method']),
      transactionId: json['transaction_id']?.toString(),
      paidAt: FeeRecord.safeNullableDate(json['paid_at']),
      createdAt: FeeRecord.safeNullableDate(json['created_at']),
      updatedAt: FeeRecord.safeNullableDate(json['updated_at']),
      deletedAt: FeeRecord.safeNullableDate(json['deleted_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fee_id': feeId,
    'student_id': studentId,
    'amount': amount,
    'payment_method': paymentMethod,
    'transaction_id': transactionId,
    'paid_at': paidAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };
}

class FeeListResponse {
  final List<FeeRecord> items;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final double currentMonthTotal;
  final double totalCollected;
  final double totalPending;
  final int pendingStudentsCount;

  FeeListResponse({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.currentMonthTotal,
    this.totalCollected = 0.0,
    this.totalPending = 0.0,
    this.pendingStudentsCount = 0,
  });

  factory FeeListResponse.fromJson(Map<String, dynamic> json) {
    return FeeListResponse(
      items:
          (json['items'] as List?)
              ?.map((i) => FeeRecord.fromJson(i))
              .toList() ??
          [],
      total: FeeRecord.safeInt(json['total']),
      currentPage: FeeRecord.safeInt(json['current_page']),
      lastPage: FeeRecord.safeInt(json['last_page']),
      perPage: FeeRecord.safeInt(json['per_page']),
      currentMonthTotal: FeeRecord.safeDouble(json['current_month_total']),
      totalCollected: FeeRecord.safeDouble(json['total_collected']),
      totalPending: FeeRecord.safeDouble(json['total_pending']),
      pendingStudentsCount: FeeRecord.safeInt(json['pending_students_count']),
    );
  }
}


class FeeInstallment {
  final int id;
  final int feeId;
  final int studentId;
  final String title;
  final double amount;
  final double paidAmount;
  final DateTime? dueDate;
  final String status;
  final int order;
  final String? notes;

  const FeeInstallment({
    required this.id,
    required this.feeId,
    required this.studentId,
    required this.title,
    required this.amount,
    required this.paidAmount,
    this.dueDate,
    required this.status,
    required this.order,
    this.notes,
  });

  double get dueAmount => (amount - paidAmount).clamp(0.0, double.infinity);

  factory FeeInstallment.fromJson(Map<String, dynamic> json) {
    return FeeInstallment(
      id: FeeRecord.safeInt(json['id']),
      feeId: FeeRecord.safeInt(json['fee_id']),
      studentId: FeeRecord.safeInt(json['student_id']),
      title: FeeRecord.safeString(json['title']),
      amount: FeeRecord.safeDouble(json['amount']),
      paidAmount: FeeRecord.safeDouble(json['paid_amount']),
      dueDate: FeeRecord.safeNullableDate(json['due_date']),
      status: FeeRecord.safeString(json['status']),
      order: FeeRecord.safeInt(json['order']),
      notes: json['notes']?.toString(),
    );
  }
}

class FeePromiseInfo {
  final int id;
  final String promiseDate;
  final String rawDate;
  final double amount;
  final String status;
  final String? notes;
  final bool isBroken;

  const FeePromiseInfo({
    required this.id,
    required this.promiseDate,
    required this.rawDate,
    required this.amount,
    required this.status,
    this.notes,
    required this.isBroken,
  });

  factory FeePromiseInfo.fromJson(Map<String, dynamic> json) {
    return FeePromiseInfo(
      id: FeeRecord.safeInt(json['id']),
      promiseDate: FeeRecord.safeString(json['promise_date']),
      rawDate: FeeRecord.safeString(json['raw_date']),
      amount: FeeRecord.safeDouble(json['amount']),
      status: FeeRecord.safeString(json['status']),
      notes: json['notes']?.toString(),
      isBroken: json['is_broken'] == 1 || json['is_broken'] == true,
    );
  }
}

class PendingFeeStudent {
  final int id;
  final String name;
  final String enrollmentId;
  final int? batchId;
  final String batchName;
  final double monthlyFee;
  final double totalPaid;
  final double pendingAmount;
  final String? profileImageUrl;
  final String phone;
  final String email;
  final String guardianName;
  final FeePromiseInfo? promise;
  final bool hasBrokenPromise;

  PendingFeeStudent({
    required this.id,
    required this.name,
    required this.enrollmentId,
    this.batchId,
    required this.batchName,
    required this.monthlyFee,
    required this.totalPaid,
    required this.pendingAmount,
    this.profileImageUrl,
    required this.phone,
    required this.email,
    required this.guardianName,
    this.promise,
    this.hasBrokenPromise = false,
  });

  factory PendingFeeStudent.fromJson(Map<String, dynamic> json) {
    return PendingFeeStudent(
      id: FeeRecord.safeInt(json['id']),
      name: FeeRecord.safeString(json['name']),
      enrollmentId: FeeRecord.safeString(json['enrollment_id']),
      batchId: json['batch_id'] != null ? FeeRecord.safeInt(json['batch_id']) : null,
      batchName: FeeRecord.safeString(json['batch_name']),
      monthlyFee: FeeRecord.safeDouble(json['monthly_fee']),
      totalPaid: FeeRecord.safeDouble(json['total_paid']),
      pendingAmount: FeeRecord.safeDouble(json['pending_amount']),
      profileImageUrl: json['profile_image_url']?.toString(),
      phone: FeeRecord.safeString(json['phone']),
      email: FeeRecord.safeString(json['email']),
      guardianName: FeeRecord.safeString(json['guardian_name']),
      promise: json['promise'] != null && json['promise'] is Map
          ? FeePromiseInfo.fromJson((json['promise'] as Map).cast<String, dynamic>())
          : null,
      hasBrokenPromise: json['has_broken_promise'] == 1 || json['has_broken_promise'] == true,
    );
  }
}

class PendingFeesResponse {
  final List<PendingFeeStudent> items;
  final double totalPending;
  final int pendingStudentsCount;

  PendingFeesResponse({
    required this.items,
    required this.totalPending,
    required this.pendingStudentsCount,
  });

  factory PendingFeesResponse.fromJson(Map<String, dynamic> json) {
    return PendingFeesResponse(
      items: (json['items'] as List?)
              ?.map((i) => PendingFeeStudent.fromJson(i))
              .toList() ??
          [],
      totalPending: FeeRecord.safeDouble(json['total_pending']),
      pendingStudentsCount: FeeRecord.safeInt(json['pending_students_count']),
    );
  }
}

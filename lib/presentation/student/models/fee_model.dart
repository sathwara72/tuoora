import 'package:tuoora/core/enums/app_enums.dart';

class FeeStatement {
  final int feeId;
  final String id;
  final String periodLabel;
  final String monthHeader;
  final int amountInRupees;
  final FeeStatus status;
  final String dateLabel;
  final String dueDateShort;
  final String? lateFeeLabel;

  const FeeStatement({
    required this.feeId,
    required this.id,
    required this.periodLabel,
    required this.monthHeader,
    required this.amountInRupees,
    required this.status,
    required this.dateLabel,
    required this.dueDateShort,
    this.lateFeeLabel,
  });

  bool get isPaid => status == FeeStatus.paid;
  bool get isPending => status == FeeStatus.pending;

  factory FeeStatement.fromJson(Map<String, dynamic> json) {
    final int id = (json['id'] as num?)?.toInt() ?? 0;
    final String monthYear = json['month_year']?.toString() ?? '';
    final String rawStatus = json['status']?.toString() ?? '';
    final bool isPaid = rawStatus.toLowerCase() == 'paid';
    final num paid = (json['paid_amount'] as num?) ?? 0;
    final String dueRaw = json['due_date']?.toString() ?? '';
    final String dueShort = _formatDueDateShort(dueRaw);

    final dateLabel = isPaid
        ? (dueShort.isEmpty ? 'Paid' : 'Paid · $dueShort')
        : (dueShort.isEmpty ? 'Pending' : 'Due $dueShort');

    return FeeStatement(
      feeId: id,
      id: '#$id',
      periodLabel: monthYear,
      monthHeader: monthYear.toUpperCase(),
      amountInRupees: paid.toInt(),
      status: isPaid ? FeeStatus.paid : FeeStatus.pending,
      dateLabel: dateLabel,
      dueDateShort: dueShort,
      lateFeeLabel: json['is_overdue'] == true ? 'Overdue' : null,
    );
  }

  static String _formatDueDateShort(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return iso;
    }
  }
}

class FeeSummary {
  final int totalInRupees;
  final int paidInRupees;
  final int pendingInRupees;
  final int billedMonths;
  final String pendingMonthsLabel;

  const FeeSummary({
    required this.totalInRupees,
    required this.paidInRupees,
    required this.pendingInRupees,
    required this.billedMonths,
    required this.pendingMonthsLabel,
  });

  double get paidFraction =>
      totalInRupees == 0 ? 0 : paidInRupees / totalInRupees;

  int get paidPercent => (paidFraction * 100).round();

  factory FeeSummary.fromJson(
    Map<String, dynamic> json, {
    int billedMonths = 0,
    String pendingMonthsLabel = '',
  }) {
    int asInt(dynamic v) => (v is num) ? v.toInt() : 0;
    return FeeSummary(
      totalInRupees: asInt(json['total_fees']),
      paidInRupees: asInt(json['paid_fees']),
      pendingInRupees: asInt(json['due_fees']),
      billedMonths: billedMonths,
      pendingMonthsLabel: pendingMonthsLabel,
    );
  }
}

class StudentBillingProfile {
  final String studentName;
  final String rollNumber;
  final String instituteName;
  final String instituteUpiHandle;
  final String? instituteUpiQrCodeUrl;

  const StudentBillingProfile({
    required this.studentName,
    required this.rollNumber,
    required this.instituteName,
    required this.instituteUpiHandle,
    this.instituteUpiQrCodeUrl,
  });

  bool get hasUpiPayment =>
      (instituteUpiQrCodeUrl != null && instituteUpiQrCodeUrl!.isNotEmpty) ||
      instituteUpiHandle.isNotEmpty;
}

class StudentReceipt {
  final int id;
  final String receiptNumber;
  final String amount;
  final String paymentMethod;
  final String date;
  final String studentName;
  final String rollNo;
  final String instituteName;

  const StudentReceipt({
    required this.id,
    required this.receiptNumber,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    required this.studentName,
    required this.rollNo,
    required this.instituteName,
  });

  factory StudentReceipt.fromJson(Map<String, dynamic> json) {
    return StudentReceipt(
      id: (json['id'] as num?)?.toInt() ?? 0,
      receiptNumber: json['receipt_number']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      paymentMethod: json['payment_method']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
      instituteName: json['institute_name']?.toString() ?? '',
    );
  }
}

class StudentFeesData {
  final FeeSummary summary;
  final List<FeeStatement> fees;
  final List<dynamic> allBatches;
  final dynamic selectedBatchId;
  final dynamic selectedBatch;

  const StudentFeesData({
    required this.summary,
    required this.fees,
    this.allBatches = const [],
    this.selectedBatchId,
    this.selectedBatch,
  });
}

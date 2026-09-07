class TeacherFee {
  final int id;
  final String totalAmount;
  final String paidAmount;
  final String status;
  final String? date;
  final String? studentName;
  final String? enrollmentId;

  const TeacherFee({
    required this.id,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    this.date,
    this.studentName,
    this.enrollmentId,
  });

  factory TeacherFee.fromJson(Map<String, dynamic> json) {
    final student = json['student'];
    return TeacherFee(
      id: json['id'],
      totalAmount: '${json['total_amount'] ?? 0}',
      paidAmount: '${json['paid_amount'] ?? 0}',
      status: json['status'] ?? '',
      date: json['date'],
      studentName: student is Map ? student['name'] : null,
      enrollmentId: student is Map ? student['enrollment_id'] : null,
    );
  }
}

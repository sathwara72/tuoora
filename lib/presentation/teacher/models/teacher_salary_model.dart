class TeacherSalary {
  final int id;
  final String? baseSalary;
  final String? bonus;
  final String? deductions;
  final String? netSalary;
  final String? paymentDate;
  final String? paymentMethod;
  final String? notes;
  final String status;

  const TeacherSalary({
    required this.id,
    this.baseSalary,
    this.bonus,
    this.deductions,
    this.netSalary,
    this.paymentDate,
    this.paymentMethod,
    this.notes,
    required this.status,
  });

  factory TeacherSalary.fromJson(Map<String, dynamic> json) {
    return TeacherSalary(
      id: json['id'],
      baseSalary: json['base_salary']?.toString(),
      bonus: json['bonus']?.toString(),
      deductions: json['deductions']?.toString(),
      netSalary: json['net_salary']?.toString(),
      paymentDate: json['payment_date'],
      paymentMethod: json['payment_method'],
      notes: json['notes'],
      status: json['status'] ?? '',
    );
  }
}

class TeacherSalaryListPage {
  final List<TeacherSalary> items;
  final int currentPage;
  final int lastPage;

  const TeacherSalaryListPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  factory TeacherSalaryListPage.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] ?? {};
    return TeacherSalaryListPage(
      items: (json['data'] as List? ?? [])
          .map((e) => TeacherSalary.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentPage: pagination['current_page'] ?? 1,
      lastPage: pagination['last_page'] ?? 1,
    );
  }
}

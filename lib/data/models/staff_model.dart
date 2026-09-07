class Staff {
  final int id;
  final String? employeeId;
  final String fullName;
  final String email;
  final String phone;
  final int staffRoleId;
  final int staffDepartmentId;
  final String employmentType;
  final String baseSalary;
  final String status;
  final String? profileUrl;
  final bool isLoginBlocked;
  final StaffRole? role;
  final StaffDepartment? department;
  final List<StaffDepartment> departments;
  final DateTime? createdAt;

  Staff({
    required this.id,
    this.employeeId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.staffRoleId,
    required this.staffDepartmentId,
    required this.employmentType,
    required this.baseSalary,
    required this.status,
    this.profileUrl,
    this.isLoginBlocked = false,
    this.role,
    this.department,
    this.departments = const [],
    this.createdAt,
  });

  /// All department ids this staff member belongs to. Falls back to the
  /// single [staffDepartmentId] when the backend hasn't returned the
  /// `departments` relation (e.g. older cached responses).
  List<int> get departmentIds => departments.isNotEmpty
      ? departments.map((d) => d.id).toList()
      : (staffDepartmentId != 0 ? [staffDepartmentId] : []);

  /// Comma-separated department names for display.
  String get departmentNames => departments.isNotEmpty
      ? departments.map((d) => d.name).join(', ')
      : (department?.name ?? 'N/A');

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: int.parse(json['id'].toString()),
      employeeId: json['employee_id']?.toString(),
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      staffRoleId: int.tryParse(json['staff_role_id']?.toString() ?? '') ?? 0,
      staffDepartmentId:
          int.tryParse(json['staff_department_id']?.toString() ?? '') ?? 0,
      employmentType: json['employment_type'] ?? '',
      baseSalary: json['base_salary']?.toString() ?? '0.00',
      status: json['status'] ?? 'active',
      profileUrl: json['profile_url'],
      isLoginBlocked: json['is_login_blocked'] == true ||
          json['is_login_blocked']?.toString() == '1',
      role: json['role'] != null ? StaffRole.fromJson(json['role']) : null,
      department: json['department'] != null
          ? StaffDepartment.fromJson(json['department'])
          : null,
      departments: json['departments'] != null
          ? (json['departments'] as List)
              .map((d) => StaffDepartment.fromJson(d))
              .toList()
          : const [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}

class StaffRole {
  final int id;
  final String name;

  StaffRole({required this.id, required this.name});

  factory StaffRole.fromJson(Map<String, dynamic> json) {
    return StaffRole(id: json['id'], name: json['name'] ?? '');
  }
}

class StaffDepartment {
  final int id;
  final String name;

  StaffDepartment({required this.id, required this.name});

  factory StaffDepartment.fromJson(Map<String, dynamic> json) {
    return StaffDepartment(id: json['id'], name: json['name'] ?? '');
  }
}

class StaffListResponse {
  final List<Staff> items;
  final int total;
  final int currentPage;
  final int lastPage;

  StaffListResponse({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory StaffListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final itemsList = data['items'] as List? ?? [];
    return StaffListResponse(
      items: itemsList.map((i) => Staff.fromJson(i)).toList(),
      total: data['total'] ?? 0,
      currentPage: data['current_page'] ?? 1,
      lastPage: data['last_page'] ?? 1,
    );
  }
}

class StaffSalary {
  final int id;
  final int staffId;
  final String baseSalary;
  final String bonus;
  final String deductions;
  final String netSalary;
  final String paymentDate;
  final String paymentMethod;
  final String status;
  final String? notes;
  final Staff? staff;

  StaffSalary({
    required this.id,
    required this.staffId,
    required this.baseSalary,
    required this.bonus,
    required this.deductions,
    required this.netSalary,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.staff,
  });

  factory StaffSalary.fromJson(Map<String, dynamic> json) {
    return StaffSalary(
      id: json['id'],
      staffId: json['staff_id'],
      baseSalary: json['base_salary']?.toString() ?? '0.00',
      bonus: json['bonus']?.toString() ?? '0.00',
      deductions: json['deductions']?.toString() ?? '0.00',
      netSalary: json['net_salary']?.toString() ?? '0.00',
      paymentDate: json['payment_date']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
    );
  }
}

/// Pre-fill data returned by GET /institute/salaries/preview/{staffId}.
/// The institute fetches this when staff is picked on the Add Salary form
/// so the screen can show the leaves count and suggest a base salary.
class SalaryPreview {
  final String staffName;
  final String? employeeId;
  final String baseSalary;
  final num suggestedDeductions;
  final num suggestedBonus;
  final int leaves;

  SalaryPreview({
    required this.staffName,
    this.employeeId,
    required this.baseSalary,
    required this.suggestedDeductions,
    required this.suggestedBonus,
    required this.leaves,
  });

  factory SalaryPreview.fromJson(Map<String, dynamic> json) {
    return SalaryPreview(
      staffName: json['staff_name']?.toString() ?? '',
      employeeId: json['employee_id']?.toString(),
      baseSalary: json['base_salary']?.toString() ?? '0.00',
      suggestedDeductions:
          num.tryParse(json['suggested_deductions']?.toString() ?? '0') ?? 0,
      suggestedBonus:
          num.tryParse(json['suggested_bonus']?.toString() ?? '0') ?? 0,
      leaves: int.tryParse(json['leaves']?.toString() ?? '0') ?? 0,
    );
  }
}

class SalaryListResponse {
  final List<StaffSalary> items;
  final String totalAmount;
  final int total;
  final int currentPage;
  final int lastPage;

  SalaryListResponse({
    required this.items,
    required this.totalAmount,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory SalaryListResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] ?? {};
    return SalaryListResponse(
      items: (json['data'] as List? ?? [])
          .map((i) => StaffSalary.fromJson(i))
          .toList(),
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      total: pagination['total'] ?? 0,
      currentPage: pagination['current_page'] ?? 1,
      lastPage: pagination['last_page'] ?? 1,
    );
  }
}

class StaffAttendance {
  final int id;
  final int staffId;
  final String date;
  final String status;
  final String? note;
  final Staff? staff;

  StaffAttendance({
    required this.id,
    required this.staffId,
    required this.date,
    required this.status,
    this.note,
    this.staff,
  });

  factory StaffAttendance.fromJson(Map<String, dynamic> json) {
    return StaffAttendance(
      id: int.parse(json['id'].toString()),
      staffId: int.parse(json['staff_id'].toString()),
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString(),
      staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
    );
  }
}

class AttendanceListResponse {
  final List<StaffAttendance> items;
  final int totalPresent;
  final int totalAbsent;
  final int total;
  final int currentPage;
  final int lastPage;

  AttendanceListResponse({
    required this.items,
    required this.totalPresent,
    required this.totalAbsent,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory AttendanceListResponse.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    final pagination = json['pagination'] ?? {};
    return AttendanceListResponse(
      items: (json['data'] as List? ?? [])
          .map((i) => StaffAttendance.fromJson(i))
          .toList(),
      totalPresent: summary['total_present'] ?? 0,
      totalAbsent: summary['total_absent'] ?? 0,
      total: pagination['total'] ?? 0,
      currentPage: pagination['current_page'] ?? 1,
      lastPage: pagination['last_page'] ?? 1,
    );
  }
}


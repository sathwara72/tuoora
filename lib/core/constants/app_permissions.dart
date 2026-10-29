/// Access Share (sub-access) permission keys.
///
/// Mirrors `InstituteSubAccess::PERMISSIONS` and the API rules in
/// `CheckInstituteSubAccessPermission` (php/fee_easy). When a permission is
/// added or renamed there, change it here too and gate the app with
/// `AuthService.can` / `canAny` / `canModule` using these constants.
class AppPermissions {
  AppPermissions._();

  // Modules, for AuthService.canModule
  static const students = 'students';
  static const batches = 'batches';
  static const fees = 'fees';
  static const attendance = 'attendance';
  static const reports = 'reports';
  static const staff = 'staff';

  // Students
  static const studentsView = 'students.view';
  static const studentsCreate = 'students.create';
  static const studentsEdit = 'students.edit';
  static const studentsDelete = 'students.delete';

  // Batches
  static const batchesView = 'batches.view';
  static const batchesCreate = 'batches.create';
  static const batchesEdit = 'batches.edit';
  static const batchesDelete = 'batches.delete';

  // Fees
  static const feesView = 'fees.view';
  static const feesTotals = 'fees.totals';
  static const feesCollect = 'fees.collect';
  static const feesEdit = 'fees.edit';
  static const feesDelete = 'fees.delete';

  // Student attendance
  static const attendanceView = 'attendance.view';
  static const attendanceMark = 'attendance.mark';

  // Academics
  static const academicsTimetable = 'academics.timetable';
  static const academicsHomework = 'academics.homework';
  static const academicsExams = 'academics.exams';

  // Expenses
  static const expensesManage = 'expenses.manage';

  // Reports
  static const reportsFee = 'reports.fee';
  static const reportsAttendance = 'reports.attendance';
  static const reportsPerformance = 'reports.performance';
  static const reportsStudent = 'reports.student';
  static const reportsAnalytics = 'reports.analytics';
  static const reportsProfitLoss = 'reports.profit_loss';

  // Staff
  static const staffView = 'staff.view';
  static const staffManage = 'staff.manage';
  static const staffAttendance = 'staff.attendance';
  static const staffSalaries = 'staff.salaries';

  // Communication, chat, notes
  static const communicationWhatsapp = 'communication.whatsapp';
  static const communicationBroadcast = 'communication.broadcast';
  static const chatAccess = 'chat.access';
  static const notesManage = 'notes.manage';

  /// Staff list and profiles; managing staff needs the list too.
  static const staffList = [staffView, staffManage];
}

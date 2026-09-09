import 'package:get/get.dart';

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_attendance_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_attendance_model.dart';

class TeacherSelfAttendanceController extends GetxController {
  final TeacherAttendanceRepositoryImpl _repository;

  TeacherSelfAttendanceController(this._repository);

  final isLoading = true.obs;
  final isMarking = false.obs;
  final Rxn<TeacherStaffAttendance> today = Rxn<TeacherStaffAttendance>();
  final Rxn<TeacherSelfAttendanceHistory> history =
      Rxn<TeacherSelfAttendanceHistory>();

  static const statuses = ['Present', 'Absent', 'Half Day', 'Late'];

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repository.getSelfAttendanceToday(),
        _repository.getSelfAttendanceHistory(),
      ]);
      today.value = results[0] as TeacherStaffAttendance?;
      history.value = results[1] as TeacherSelfAttendanceHistory;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markToday(String status) async {
    try {
      isMarking.value = true;
      today.value = await _repository.markSelfAttendance(status: status);
      AppSnackBar.success('Attendance marked as $status');
      final h = await _repository.getSelfAttendanceHistory();
      history.value = h;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isMarking.value = false;
    }
  }
}

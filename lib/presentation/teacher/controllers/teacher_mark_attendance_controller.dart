import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_attendance_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_attendance_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';

class TeacherMarkAttendanceController extends GetxController {
  final TeacherAttendanceRepositoryImpl _repository;

  TeacherMarkAttendanceController(this._repository);

  late final TeacherBatch batch;
  final selectedDate = DateTime.now().obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final rows = <TeacherAttendanceRow>[].obs;

  bool get isToday {
    final now = DateTime.now();
    final d = selectedDate.value;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  String get apiDate => DateFormat('yyyy-MM-dd').format(selectedDate.value);
  String get displayDate => DateFormat('dd MMM, yyyy').format(selectedDate.value);

  @override
  void onInit() {
    super.onInit();
    batch = Get.arguments as TeacherBatch;
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      rows.value = await _repository.getBatchAttendance(
        batchId: batch.id,
        date: apiDate,
      );
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDate(DateTime date) async {
    selectedDate.value = date;
    await fetchAttendance();
  }

  void setStatus(TeacherAttendanceRow row, String status) {
    if (!isToday) return;
    row.status = status;
    rows.refresh();
  }

  Future<void> submit() async {
    if (!isToday) return;
    final unset = rows.where((r) => r.status == null || r.status!.isEmpty);
    if (unset.isNotEmpty) {
      AppSnackBar.error('Please mark attendance for every student');
      return;
    }
    try {
      isSubmitting.value = true;
      await _repository.markBatchAttendance(
        batchId: batch.id,
        date: apiDate,
        attendance: rows
            .map((r) => {'student_id': r.studentId, 'status': r.status})
            .toList(),
      );
      AppSnackBar.success('Attendance saved');
      await fetchAttendance();
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }
}

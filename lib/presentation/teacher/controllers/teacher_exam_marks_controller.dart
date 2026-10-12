import 'package:get/get.dart';

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_exam_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_exam_model.dart';

class TeacherExamMarksController extends GetxController {
  final TeacherExamRepositoryImpl _repository;

  TeacherExamMarksController(this._repository);

  late final TeacherExam exam;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final rows = <TeacherExamMarkRow>[].obs;
  final searchQuery = ''.obs;

  /// Bumped when marks are changed in bulk so the text fields rebuild.
  final resetTick = 0.obs;

  @override
  void onInit() {
    super.onInit();
    exam = Get.arguments as TeacherExam;
    fetchMarks();
  }

  Future<void> fetchMarks() async {
    try {
      isLoading.value = true;
      final data = await _repository.getExamMarks(exam.id);
      rows.value = data.students;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  int get totalStudents => rows.length;
  int get absentCount => rows.where((r) => r.isAbsent).length;
  int get presentCount => rows.where((r) => !r.isAbsent).length;
  int get enteredCount =>
      rows.where((r) => r.isAbsent || r.marksObtained != null).length;

  int get passedCount => rows
      .where((r) =>
          !r.isAbsent &&
          r.marksObtained != null &&
          r.marksObtained! >= exam.passingMarks)
      .length;
  int get markedPresentCount =>
      rows.where((r) => !r.isAbsent && r.marksObtained != null).length;
  int get passRate =>
      markedPresentCount == 0 ? 0 : (passedCount * 100 / markedPresentCount).round();

  List<TeacherExamMarkRow> get filteredRows {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return rows.toList();
    return rows
        .where((r) =>
            r.studentName.toLowerCase().contains(q) ||
            (r.enrollmentId ?? '').toLowerCase().contains(q))
        .toList();
  }

  void fillPassingMarks() {
    for (final r in rows) {
      if (!r.isAbsent) r.marksObtained = exam.passingMarks;
    }
    resetTick.value++;
    rows.refresh();
    AppSnackBar.success('Filled passing marks (${exam.passingMarks.toInt()})');
  }

  void clearAll() {
    for (final r in rows) {
      r.marksObtained = null;
      r.isAbsent = false;
      r.remarks = null;
    }
    resetTick.value++;
    rows.refresh();
  }

  void updateMarks(TeacherExamMarkRow row, String value) {
    row.marksObtained = double.tryParse(value.trim());
    rows.refresh();
  }

  void updateRemarks(TeacherExamMarkRow row, String value) {
    row.remarks = value.trim().isEmpty ? null : value.trim();
  }

  void toggleAbsent(TeacherExamMarkRow row) {
    row.isAbsent = !row.isAbsent;
    if (row.isAbsent) row.marksObtained = null;
    rows.refresh();
  }

  void setAbsent(TeacherExamMarkRow row, bool isAbsent) {
    row.isAbsent = isAbsent;
    if (isAbsent) row.marksObtained = null;
    rows.refresh();
  }

  Future<void> submit() async {
    for (final r in rows) {
      if (!r.isAbsent &&
          r.marksObtained != null &&
          r.marksObtained! > exam.totalMarks) {
        AppSnackBar.error(
          "${r.studentName}'s marks (${r.marksObtained}) cannot exceed total marks (${exam.totalMarks})",
        );
        return;
      }
    }

    try {
      isSaving.value = true;
      await _repository.saveExamMarks(
        exam.id,
        rows
            .map(
              (r) => {
                'student_id': r.studentId,
                'marks_obtained': r.isAbsent ? null : r.marksObtained,
                'is_absent': r.isAbsent,
                'remarks': r.remarks,
              },
            )
            .toList(),
      );
      AppSnackBar.success('Exam marks saved successfully');
      Get.back(result: true);
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }
}

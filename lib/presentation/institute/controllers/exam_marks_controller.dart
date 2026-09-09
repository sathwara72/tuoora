import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/presentation/institute/models/exam_model.dart';

class ExamMarksController extends GetxController {
  final ExamModel exam;
  final InstituteRepositoryImpl _repository = Get.find<InstituteRepositoryImpl>();

  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final rows = <ExamMarkRow>[].obs;
  final stats = Rxn<ExamStats>();

  final Map<int, TextEditingController> marksControllers = {};
  final Map<int, TextEditingController> remarksControllers = {};

  ExamMarksController(this.exam);

  @override
  void onInit() {
    super.onInit();
    fetchMarks();
  }

  List<ExamMarkRow> get filteredRows {
    if (searchQuery.isEmpty) return rows;
    final q = searchQuery.value.toLowerCase().trim();
    return rows.where((r) {
      final name = r.studentName.toLowerCase();
      final id = (r.enrollmentId ?? r.studentId.toString()).toLowerCase();
      return name.contains(q) || id.contains(q);
    }).toList();
  }

  int get totalStudentsCount => rows.length;
  int get presentStudentsCount => rows.where((r) => !r.isAbsent).length;
  int get absentStudentsCount => rows.where((r) => r.isAbsent).length;

  int get passedStudentsCount {
    int count = 0;
    for (final r in rows) {
      if (r.isAbsent) continue;
      final text = marksControllers[r.studentId]?.text.trim() ?? '';
      final val = double.tryParse(text);
      if (val != null && val >= exam.passingMarks) {
        count++;
      }
    }
    return count;
  }

  double get passRatePercent {
    final present = presentStudentsCount;
    if (present == 0) return 0.0;
    return (passedStudentsCount / present) * 100;
  }

  void fillPassingMarks() {
    final passing = _trimZeros(exam.passingMarks);
    for (final row in rows) {
      if (!row.isAbsent) {
        final current = marksControllers[row.studentId]?.text.trim() ?? '';
        if (current.isEmpty) {
          marksControllers[row.studentId]?.text = passing;
        }
      }
    }
    rows.refresh();
  }

  void clearAllMarks() {
    for (final row in rows) {
      row.isAbsent = false;
      marksControllers[row.studentId]?.clear();
      remarksControllers[row.studentId]?.clear();
    }
    rows.refresh();
  }

  Future<void> fetchMarks() async {
    try {
      isLoading.value = true;
      final result = await _repository.getExamMarks(int.parse(exam.id));
      rows.assignAll(result.students);
      stats.value = result.stats;

      for (final row in rows) {
        marksControllers[row.studentId] = TextEditingController(
          text: row.marksObtained != null
              ? _trimZeros(row.marksObtained!)
              : '',
        );
        remarksControllers[row.studentId] = TextEditingController(
          text: row.remarks,
        );
      }
    } catch (e) {
      AppSnackBar.error('Failed to load students: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  String _trimZeros(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  void toggleAbsent(int studentId, bool value) {
    final index = rows.indexWhere((r) => r.studentId == studentId);
    if (index == -1) return;
    rows[index].isAbsent = value;
    if (value) marksControllers[studentId]?.clear();
    rows.refresh();
  }

  Future<void> saveMarks() async {
    if (isSaving.value) return;

    final marks = rows.map((row) {
      final text = marksControllers[row.studentId]?.text.trim() ?? '';
      final marksObtained = row.isAbsent
          ? null
          : (text.isEmpty ? null : double.tryParse(text));
      return {
        'student_id': row.studentId,
        'marks_obtained': marksObtained,
        'is_absent': row.isAbsent,
        'remarks': remarksControllers[row.studentId]?.text.trim(),
      };
    }).toList();

    try {
      isSaving.value = true;
      final updatedStats = await _repository.saveExamMarks(
        int.parse(exam.id),
        marks,
      );
      stats.value = updatedStats;

      Get.back(result: true);
      AppSnackBar.success('Marks saved successfully');
    } catch (e) {
      AppSnackBar.error('Failed to save marks: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    for (final c in marksControllers.values) {
      c.dispose();
    }
    for (final c in remarksControllers.values) {
      c.dispose();
    }
    super.onClose();
  }
}

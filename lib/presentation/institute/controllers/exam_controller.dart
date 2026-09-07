import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/exam_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/api/api_exception.dart';

class ExamController extends GetxController {
  final BatchModel batch;
  final InstituteRepositoryImpl _repository = Get.find<InstituteRepositoryImpl>();

  final exams = <ExamModel>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  ExamController(this.batch);

  @override
  void onInit() {
    super.onInit();
    fetchExams();

    titleController.addListener(() {
      if (triedToSave.value && titleError.value != null) {
        titleError.value = null;
      }
    });

    ever(examDate, (_) {
      if (triedToSave.value && dateError.value != null) {
        dateError.value = null;
      }
    });
  }

  Future<void> fetchExams() async {
    try {
      isLoading.value = true;
      final response = await _repository.getExams(int.parse(batch.id));
      exams.assignAll(response);
    } catch (e) {
      AppSnackBar.error('Failed to fetch exams: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  List<ExamModel> get filteredExams {
    if (searchQuery.isEmpty) return exams;
    final q = searchQuery.value.toLowerCase();
    return exams
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              (e.subject ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  // ── Create / Edit Form State ──────────────────────────────────────────
  String? editingExamId;
  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final totalMarksController = TextEditingController(text: '100');
  final passingMarksController = TextEditingController(text: '35');
  final examDate = Rxn<DateTime>();
  final examType = ExamType.other.obs;

  final triedToSave = false.obs;
  final titleError = RxnString();
  final dateError = RxnString();
  final totalMarksError = RxnString();
  final passingMarksError = RxnString();

  bool get isEditing => editingExamId != null;

  void startCreate() {
    clearForm();
  }

  void startEdit(ExamModel exam) {
    editingExamId = exam.id;
    titleController.text = exam.title;
    subjectController.text = exam.subject ?? '';
    descriptionController.text = exam.description ?? '';
    totalMarksController.text = _trimZeros(exam.totalMarks);
    passingMarksController.text = _trimZeros(exam.passingMarks);
    examDate.value = exam.examDate;
    examType.value = exam.examType;
  }

  String _trimZeros(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  bool validateForm() {
    bool isValid = true;

    final tErr = ValidationUtils.validateRequired(
      titleController.text,
      'Title',
    );
    titleError.value = tErr;
    if (tErr != null) isValid = false;

    final dErr = ValidationUtils.validateDateSelection(
      examDate.value,
      'exam date',
    );
    dateError.value = dErr;
    if (dErr != null) isValid = false;

    final total = double.tryParse(totalMarksController.text.trim());
    if (total == null || total <= 0) {
      totalMarksError.value = 'Enter a valid total marks';
      isValid = false;
    } else {
      totalMarksError.value = null;
    }

    final passing = double.tryParse(passingMarksController.text.trim());
    if (passing == null || passing < 0) {
      passingMarksError.value = 'Enter a valid passing marks';
      isValid = false;
    } else if (total != null && passing > total) {
      passingMarksError.value = 'Cannot exceed total marks';
      isValid = false;
    } else {
      passingMarksError.value = null;
    }

    return isValid;
  }

  Future<void> submitForm() async {
    triedToSave.value = true;
    if (!validateForm()) return;

    final data = <String, dynamic>{
      'batch_id': batch.id,
      'title': titleController.text.trim(),
      'subject': subjectController.text.trim().isEmpty
          ? null
          : subjectController.text.trim(),
      'exam_type': examType.value,
      'exam_date': DateFormat('yyyy-MM-dd').format(examDate.value!),
      'total_marks': totalMarksController.text.trim(),
      'passing_marks': passingMarksController.text.trim(),
      'description': descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    };

    try {
      isSaving.value = true;
      if (isEditing) {
        await _repository.updateExam(int.parse(editingExamId!), data);
      } else {
        await _repository.createExam(data);
      }
      await fetchExams();

      final wasEditing = isEditing;
      clearForm();
      Get.back();

      AppSnackBar.success(
        wasEditing ? 'Exam updated successfully' : 'Exam created successfully',
      );
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
        AppSnackBar.error('Please fix the errors below');
      } else {
        AppSnackBar.error('Failed to save exam: ${e.toString()}');
      }
    } finally {
      isSaving.value = false;
    }
  }

  void _handleValidationErrors(Map<String, dynamic> errors) {
    if (errors.containsKey('title')) {
      titleError.value = (errors['title'] as List).first.toString();
    }
    if (errors.containsKey('exam_date')) {
      dateError.value = (errors['exam_date'] as List).first.toString();
    }
    if (errors.containsKey('total_marks')) {
      totalMarksError.value = (errors['total_marks'] as List).first.toString();
    }
    if (errors.containsKey('passing_marks')) {
      passingMarksError.value =
          (errors['passing_marks'] as List).first.toString();
    }
  }

  void deleteExamWithConfirmation(ExamModel exam) {
    CommonDialog.showDeleteConfirmation(
      title: 'Delete Exam',
      description:
          'Are you sure you want to delete this exam? This will also remove any marks entered for it.',
      onConfirm: () async {
        try {
          Get.dialog(
            const Center(child: CommonLoading()),
            barrierDismissible: false,
          );
          await _repository.deleteExam(int.parse(exam.id));
          exams.removeWhere((e) => e.id == exam.id);

          Get.back(); // close loading dialog
          Get.back(); // pop the exam marks/detail screen back to the list

          AppSnackBar.success('Exam deleted', title: 'Deleted');
        } catch (e) {
          Get.back(); // close loading dialog
          AppSnackBar.error('Failed to delete exam: ${e.toString()}');
        }
      },
    );
  }

  void clearForm() {
    editingExamId = null;
    titleController.clear();
    subjectController.clear();
    descriptionController.clear();
    totalMarksController.text = '100';
    passingMarksController.text = '35';
    examDate.value = null;
    examType.value = ExamType.other;
    triedToSave.value = false;
    titleError.value = null;
    dateError.value = null;
    totalMarksError.value = null;
    passingMarksError.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    totalMarksController.dispose();
    passingMarksController.dispose();
    super.onClose();
  }
}

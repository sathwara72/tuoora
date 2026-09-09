import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_exam_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_exam_model.dart';

class TeacherAddExamController extends GetxController {
  final TeacherExamRepositoryImpl _repository;

  TeacherAddExamController(this._repository);

  static const examTypes = [
    'unit_test',
    'mid_term',
    'final',
    'quiz',
    'assignment',
    'other',
  ];

  late final TeacherBatch batch;
  TeacherExam? editingExam;
  bool get isEditing => editingExam != null;

  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final totalMarksController = TextEditingController();
  final passingMarksController = TextEditingController();
  final descriptionController = TextEditingController();

  final examType = 'other'.obs;
  final examDate = Rxn<DateTime>();
  final isLoading = false.obs;

  final titleError = RxnString();
  final totalMarksError = RxnString();
  final passingMarksError = RxnString();
  final dateError = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TeacherExam) {
      editingExam = args;
      batch = TeacherBatch(
        id: args.batchId,
        name: args.batchName ?? '',
        status: 'active',
        teacherCanViewFees: false,
      );
      titleController.text = args.title;
      subjectController.text = args.subject ?? '';
      totalMarksController.text = args.totalMarks == args.totalMarks.roundToDouble()
          ? args.totalMarks.toInt().toString()
          : args.totalMarks.toString();
      passingMarksController.text =
          args.passingMarks == args.passingMarks.roundToDouble()
              ? args.passingMarks.toInt().toString()
              : args.passingMarks.toString();
      descriptionController.text = args.description ?? '';
      examType.value = args.examType ?? 'other';
      examDate.value = DateTime.tryParse(args.examDate);
    } else {
      batch = args as TeacherBatch;
    }
  }

  void selectExamType(String type) => examType.value = type;

  void pickExamDate(DateTime date) {
    examDate.value = date;
    dateError.value = null;
  }

  bool _validate() {
    var isValid = true;
    titleError.value = ValidationUtils.validateRequired(
      titleController.text.trim(),
      'Title',
    );
    if (titleError.value != null) isValid = false;

    if (totalMarksController.text.trim().isEmpty) {
      totalMarksError.value = 'Total marks required';
      isValid = false;
    } else {
      totalMarksError.value = null;
    }

    if (passingMarksController.text.trim().isEmpty) {
      passingMarksError.value = 'Passing marks required';
      isValid = false;
    } else {
      final total = double.tryParse(totalMarksController.text.trim());
      final passing = double.tryParse(passingMarksController.text.trim());
      if (total != null && passing != null && passing > total) {
        passingMarksError.value = 'Cannot exceed total marks';
        isValid = false;
      } else {
        passingMarksError.value = null;
      }
    }

    if (examDate.value == null) {
      dateError.value = 'Exam date is required';
      isValid = false;
    } else {
      dateError.value = null;
    }
    return isValid;
  }

  Future<void> submit() async {
    if (!_validate()) return;
    try {
      isLoading.value = true;
      final data = {
        'title': titleController.text.trim(),
        'subject': subjectController.text.trim(),
        'exam_type': examType.value,
        'exam_date': DateFormat('yyyy-MM-dd').format(examDate.value!),
        'total_marks': double.tryParse(totalMarksController.text.trim()),
        'passing_marks': double.tryParse(passingMarksController.text.trim()),
        'description': descriptionController.text.trim(),
      };
      if (isEditing) {
        await _repository.updateExam(editingExam!.id, data);
        AppSnackBar.success('Exam updated');
      } else {
        await _repository.createExam({...data, 'batch_id': batch.id});
        AppSnackBar.success('Exam created');
      }
      Get.back(result: true);
    } catch (e) {
      if (e is ValidationException) {
        AppSnackBar.error(e.errors.values.first.first.toString());
      } else {
        AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    subjectController.dispose();
    totalMarksController.dispose();
    passingMarksController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

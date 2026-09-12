import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_homework_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_homework_model.dart';

class TeacherAddHomeworkController extends GetxController {
  final TeacherHomeworkRepositoryImpl _repository;

  TeacherAddHomeworkController(this._repository);

  late final TeacherBatch batch;
  TeacherHomework? editingHomework;
  bool get isEditing => editingHomework != null;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueDate = Rxn<DateTime>();
  final selectedAttachment = Rxn<String>();
  final isLoading = false.obs;

  final titleError = RxnString();
  final descriptionError = RxnString();
  final dateError = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TeacherHomework) {
      editingHomework = args;
      titleController.text = args.title;
      descriptionController.text = args.description;
      dueDate.value = DateTime.tryParse(args.dueDate);
      batch = TeacherBatch(
        id: args.batchId,
        name: args.batchName ?? '',
        status: 'active',
        teacherCanViewFees: false,
      );
    } else {
      batch = args as TeacherBatch;
    }
  }

  Future<void> pickDueDate(DateTime picked) async {
    dueDate.value = picked;
    dateError.value = null;
  }

  Future<void> pickAttachment() async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.any, allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        selectedAttachment.value = result.files.single.path;
      }
    } catch (e) {
      AppSnackBar.error('Failed to pick file: $e');
    }
  }

  void removeAttachment() => selectedAttachment.value = null;

  bool _validate() {
    var isValid = true;
    titleError.value = ValidationUtils.validateRequired(
      titleController.text.trim(),
      'Title',
    );
    if (titleError.value != null) isValid = false;

    descriptionError.value = ValidationUtils.validateRequired(
      descriptionController.text.trim(),
      'Description',
    );
    if (descriptionError.value != null) isValid = false;

    if (dueDate.value == null) {
      dateError.value = 'Due date is required';
      isValid = false;
    } else {
      dateError.value = null;
    }
    return isValid;
  }

  Future<void> submit() async {
    if (isLoading.value) return;
    if (!_validate()) return;
    try {
      isLoading.value = true;
      final data = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'due_date': DateFormat('yyyy-MM-dd').format(dueDate.value!),
      };
      if (isEditing) {
        await _repository.updateHomework(editingHomework!.id, data);
        Get.back(result: true);
        AppSnackBar.success('Homework updated');
      } else {
        await _repository.createHomework(
          {...data, 'batch_id': batch.id},
          attachmentPath: selectedAttachment.value,
        );
        Get.back(result: true);
        AppSnackBar.success('Homework created');
      }
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

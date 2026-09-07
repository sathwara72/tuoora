import 'package:tuoora/data/models/staff_model.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/school_class_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';

class BatchClassesController extends GetxController {
  final BatchModel batch;
  final InstituteRepositoryImpl _repository =
      Get.find<InstituteRepositoryImpl>();

  BatchClassesController(this.batch);

  final classes = <SchoolClassModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  final staffList = <Staff>[].obs;
  final isLoadingStaff = false.obs;

  // Add/Edit Class dialog state
  final editingClassId = Rxn<int>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedTeacherIds = <int>[].obs;
  final triedToSave = false.obs;
  final nameError = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
    fetchStaff();
  }

  Future<void> fetchClasses() async {
    try {
      isLoading.value = true;
      final response = await _repository.listClasses(int.parse(batch.id));
      classes.assignAll(response);
    } catch (e) {
      AppSnackBar.error('Failed to load classes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStaff() async {
    try {
      isLoadingStaff.value = true;
      final response = await _repository.listStaff();
      staffList.assignAll(response.items);
    } catch (e) {
      AppSnackBar.error('Failed to load staff: $e');
    } finally {
      isLoadingStaff.value = false;
    }
  }

  void toggleTeacher(int staffId) {
    if (selectedTeacherIds.contains(staffId)) {
      selectedTeacherIds.remove(staffId);
    } else {
      selectedTeacherIds.add(staffId);
    }
  }

  void prepareForAdd() {
    editingClassId.value = null;
    nameController.clear();
    descriptionController.clear();
    selectedTeacherIds.clear();
    triedToSave.value = false;
    nameError.value = null;
  }

  void prepareForEdit(SchoolClassModel schoolClass) {
    editingClassId.value = schoolClass.id;
    nameController.text = schoolClass.name;
    descriptionController.text = schoolClass.description ?? '';
    selectedTeacherIds.assignAll(schoolClass.teachers.map((t) => t.id));
    triedToSave.value = false;
    nameError.value = null;
  }

  Future<void> saveClass() async {
    triedToSave.value = true;
    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Class name is required';
      return;
    }
    nameError.value = null;

    final data = {
      'batch_id': batch.id,
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'teacher_ids': selectedTeacherIds.toList(),
    };

    try {
      isSaving.value = true;
      if (editingClassId.value != null) {
        final updated = await _repository.updateClass(
          editingClassId.value!,
          data,
        );
        final index = classes.indexWhere((c) => c.id == updated.id);
        if (index != -1) classes[index] = updated;
        AppSnackBar.success('Class updated successfully');
      } else {
        final created = await _repository.createClass(data);
        classes.insert(0, created);
        AppSnackBar.success('Class created successfully');
      }
      Get.back();
    } catch (e) {
      AppSnackBar.error('Failed to save class: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteClass(int id) async {
    try {
      isLoading.value = true;
      await _repository.deleteClass(id);
      classes.removeWhere((c) => c.id == id);
      AppSnackBar.success('Class deleted successfully');
    } catch (e) {
      AppSnackBar.error('Failed to delete class: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

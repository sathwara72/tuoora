import 'dart:async';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_batch_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';

class TeacherAssignStudentsController extends GetxController {
  final TeacherBatchRepositoryImpl _repository;

  TeacherAssignStudentsController(this._repository);

  late final TeacherBatch batch;

  final RxList<TeacherBatchStudent> availableStudents = <TeacherBatchStudent>[].obs;
  final RxSet<int> selectedStudentIds = <int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString searchQuery = ''.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TeacherBatch) {
      batch = args;
    } else if (args is Map && args['batch'] is TeacherBatch) {
      batch = args['batch'] as TeacherBatch;
    } else {
      batch = const TeacherBatch(id: 0, name: 'Batch', status: 'active', teacherCanViewFees: false);
    }
    fetchAvailableStudents();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchAvailableStudents();
    });
  }

  Future<void> fetchAvailableStudents() async {
    isLoading.value = true;
    try {
      final result = await _repository.getAvailableStudents(
        batch.id,
        search: searchQuery.value,
      );
      availableStudents.assignAll(result);
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSelection(int studentId) {
    if (selectedStudentIds.contains(studentId)) {
      selectedStudentIds.remove(studentId);
    } else {
      selectedStudentIds.add(studentId);
    }
  }

  void selectAll() {
    if (selectedStudentIds.length == availableStudents.length) {
      selectedStudentIds.clear();
    } else {
      selectedStudentIds.assignAll(availableStudents.map((s) => s.id));
    }
  }

  Future<void> assignSelectedStudents() async {
    if (selectedStudentIds.isEmpty) {
      AppSnackBar.error('Please select at least one student to assign.');
      return;
    }

    isSubmitting.value = true;
    try {
      await _repository.assignStudentsToBatch(batch.id, selectedStudentIds.toList());
      AppSnackBar.success(
        '${selectedStudentIds.length} student(s) assigned to ${batch.name} successfully.',
      );
      Get.back(result: true);
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
}

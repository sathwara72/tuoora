import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_exam_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_exam_model.dart';

class TeacherBatchExamsController extends GetxController {
  final TeacherExamRepositoryImpl _repository;

  TeacherBatchExamsController(this._repository);

  late final TeacherBatch batch;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final exams = <TeacherExam>[].obs;
  final total = 0.obs;

  /// 'all' | 'scheduled' | 'completed'
  final filter = 'all'.obs;
  final searchQuery = ''.obs;

  int _page = 1;
  int _lastPage = 1;
  bool get hasMore => _page < _lastPage;

  @override
  void onInit() {
    super.onInit();
    batch = Get.arguments as TeacherBatch;
    fetchExams();
    debounce(searchQuery, (_) => fetchExams(), time: const Duration(milliseconds: 400));
  }

  void setFilter(String value) {
    if (filter.value == value) return;
    filter.value = value;
    fetchExams();
  }

  Future<void> fetchExams() async {
    try {
      isLoading.value = true;
      final page = await _repository.getExams(
        batchId: batch.id,
        status: filter.value == 'all' ? null : filter.value,
        search: searchQuery.value.trim(),
      );
      exams.value = page.items;
      total.value = page.total;
      _page = page.currentPage;
      _lastPage = page.lastPage;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore) return;
    try {
      isLoadingMore.value = true;
      final page = await _repository.getExams(
        batchId: batch.id,
        status: filter.value == 'all' ? null : filter.value,
        search: searchQuery.value.trim(),
        page: _page + 1,
      );
      exams.addAll(page.items);
      _page = page.currentPage;
      _lastPage = page.lastPage;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> addExam() async {
    final created = await Get.toNamed(AppRoutes.teacherAddExam, arguments: batch);
    if (created == true) fetchExams();
  }

  Future<void> editExam(TeacherExam exam) async {
    final updated = await Get.toNamed(AppRoutes.teacherAddExam, arguments: exam);
    if (updated == true) fetchExams();
  }

  Future<void> confirmDeleteExam(TeacherExam exam) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Exam'),
        content: Text(
          'Are you sure you want to delete "${exam.title}"? All student marks for this exam will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteExam(exam);
    }
  }

  Future<void> deleteExam(TeacherExam exam) async {
    try {
      await _repository.deleteExam(exam.id);
      AppSnackBar.success('Exam deleted');
      fetchExams();
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> openMarks(TeacherExam exam) async {
    final updated = await Get.toNamed(AppRoutes.teacherExamMarks, arguments: exam);
    if (updated == true) fetchExams();
  }
}

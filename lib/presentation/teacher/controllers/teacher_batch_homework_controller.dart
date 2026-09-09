import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_homework_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_homework_model.dart';

class TeacherBatchHomeworkController extends GetxController {
  final TeacherHomeworkRepositoryImpl _repository;

  TeacherBatchHomeworkController(this._repository);

  late final TeacherBatch batch;
  final isLoading = true.obs;
  final homeworks = <TeacherHomework>[].obs;

  @override
  void onInit() {
    super.onInit();
    batch = Get.arguments as TeacherBatch;
    fetchHomeworks();
  }

  Future<void> fetchHomeworks() async {
    try {
      isLoading.value = true;
      final page = await _repository.getHomeworks(batchId: batch.id);
      homeworks.value = page.items;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addHomework() async {
    final created = await Get.toNamed(AppRoutes.teacherAddHomework, arguments: batch);
    if (created == true) fetchHomeworks();
  }

  Future<void> editHomework(TeacherHomework homework) async {
    final updated = await Get.toNamed(AppRoutes.teacherAddHomework, arguments: homework);
    if (updated == true) fetchHomeworks();
  }

  Future<void> deleteHomework(TeacherHomework homework) async {
    try {
      await _repository.deleteHomework(homework.id);
      AppSnackBar.success('Homework deleted');
      fetchHomeworks();
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void openGrading(TeacherHomework homework) {
    Get.toNamed(AppRoutes.teacherHomeworkGrading, arguments: homework);
  }
}

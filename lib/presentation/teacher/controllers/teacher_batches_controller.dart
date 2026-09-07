import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_batch_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';

class TeacherBatchesController extends GetxController {
  final TeacherBatchRepositoryImpl _repository;

  TeacherBatchesController(this._repository);

  final isLoading = true.obs;
  final batches = <TeacherBatch>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    try {
      isLoading.value = true;
      batches.value = await _repository.getBatches();
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void openBatch(TeacherBatch batch) {
    Get.toNamed(AppRoutes.teacherBatchDetails, arguments: batch);
  }
}

import 'package:get/get.dart';

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_batch_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';

class TeacherBatchDetailsController extends GetxController {
  final TeacherBatchRepositoryImpl _repository;

  TeacherBatchDetailsController(this._repository);

  final isLoading = true.obs;
  final Rxn<TeacherBatchDetail> detail = Rxn<TeacherBatchDetail>();

  late final TeacherBatch initialBatch;

  @override
  void onInit() {
    super.onInit();
    initialBatch = Get.arguments as TeacherBatch;
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      isLoading.value = true;
      detail.value = await _repository.getBatchDetail(initialBatch.id);
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  TeacherBatch get batch => detail.value?.batch ?? initialBatch;
}

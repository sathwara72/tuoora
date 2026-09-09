import 'package:get/get.dart';

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_fee_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_fee_model.dart';

class TeacherFeesController extends GetxController {
  final TeacherFeeRepositoryImpl _repository;

  TeacherFeesController(this._repository);

  late final TeacherBatch batch;
  final isLoading = true.obs;
  final fees = <TeacherFee>[].obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    batch = Get.arguments as TeacherBatch;
    fetchFees();
  }

  Future<void> fetchFees() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      fees.value = await _repository.getFees(batch.id);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      AppSnackBar.error(errorMessage.value!);
    } finally {
      isLoading.value = false;
    }
  }
}

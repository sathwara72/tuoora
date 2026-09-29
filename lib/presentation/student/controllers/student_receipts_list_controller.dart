import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/student_fees_repository.dart';
import 'package:tuoora/presentation/student/controllers/fees_controller.dart';
import 'package:tuoora/presentation/student/models/fee_model.dart';

class StudentReceiptsListController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<StudentReceipt> receipts = <StudentReceipt>[].obs;

  late final StudentFeesRepository _repository;

  @override
  void onInit() {
    super.onInit();
    _repository = StudentFeesRepository(Get.find<ApiClient>());
    loadReceipts();
  }

  Future<void> loadReceipts() async {
    try {
      isLoading.value = true;
      final list = await _repository.getReceipts();
      receipts.assignAll(list);
    } catch (_) {
      AppSnackBar.error(AppStrings.failedToLoadReceipts);
    } finally {
      isLoading.value = false;
    }
  }

  /// Opens the receipt screen for [receipt]. Delegates the fetch +
  /// download wiring to [FeesController] so there's a single source of
  /// truth for the receipt screen.
  void openReceipt(StudentReceipt receipt) {
    if (!Get.isRegistered<FeesController>()) {
      Get.put(FeesController());
    }
    Get.find<FeesController>().openReceiptDirect(receipt);
  }
}

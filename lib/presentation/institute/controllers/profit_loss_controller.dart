import 'package:get/get.dart';
import 'package:tuoora/core/services/download_service.dart';
import 'package:tuoora/data/models/financial_period.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/presentation/institute/models/profit_loss_model.dart';

class ProfitLossController extends GetxController {
  final InstituteRepositoryImpl _repository =
      Get.find<InstituteRepositoryImpl>();
  final DownloadService _downloadService = Get.find<DownloadService>();

  final period = FinancialPeriod.financialYear().obs;
  final report = Rxn<ProfitLossReport>();
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    ever(period, (_) => load());
    load();
  }

  void setPeriod(FinancialPeriod value) => period.value = value;

  Future<void> load() async {
    try {
      isLoading.value = true;
      error.value = null;
      report.value = await _repository.getProfitLoss(period.value);
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      error.value = message.toLowerCase().contains('access denied')
          ? "You don't have permission to view Profit & Loss."
          : message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportPdf() async {
    final label = period.value.label.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    await _downloadService.download(
      label: 'Preparing Profit & Loss report…',
      fileName: 'Profit_Loss_$label.pdf',
      successMessage: 'Profit & Loss report downloaded',
      fetch: () => _repository.exportProfitLoss(period.value),
    );
  }
}

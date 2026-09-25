import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/download_service.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/student_fees_repository.dart';
import 'package:tuoora/data/repositories/student_institute_repository.dart';
import 'package:tuoora/presentation/student/models/fee_model.dart';
import 'package:tuoora/core/widgets/pdf_viewer_popup.dart';

class FeesController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isReceiptLoading = false.obs;
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;

  final Rx<FeeSummary> summary = const FeeSummary(
    totalInRupees: 0,
    paidInRupees: 0,
    pendingInRupees: 0,
    billedMonths: 0,
    pendingMonthsLabel: '',
  ).obs;

  final RxList<FeeStatement> statements = <FeeStatement>[].obs;
  final Rxn<dynamic> selectedBatchId = Rxn<dynamic>();
  final RxList<dynamic> allBatches = <dynamic>[].obs;
  final Rxn<FeeStatement> selectedStatement = Rxn<FeeStatement>();
  final Rxn<StudentReceipt> currentReceipt = Rxn<StudentReceipt>();

  final Rx<StudentBillingProfile> billingProfile = const StudentBillingProfile(
    studentName: '',
    rollNumber: '',
    instituteName: '',
    instituteUpiHandle: '',
  ).obs;

  late final StudentFeesRepository _repository;
  late final StudentInstituteRepository _instituteRepository;

  @override
  void onInit() {
    super.onInit();
    _repository = StudentFeesRepository(Get.find<ApiClient>());
    _instituteRepository = StudentInstituteRepository(Get.find<ApiClient>());
    loadFees();
    _loadBillingProfile();
  }

  Future<void> loadFees({dynamic batchId}) async {
    try {
      isLoading.value = true;
      if (batchId != null) {
        selectedBatchId.value = batchId;
      }
      final data = await _repository.getFees(batchId: selectedBatchId.value);
      statements.assignAll(data.fees);
      summary.value = data.summary;
      allBatches.assignAll(data.allBatches);
      if (selectedBatchId.value == null && data.selectedBatchId != null) {
        selectedBatchId.value = data.selectedBatchId;
      }
    } catch (_) {
      AppSnackBar.error(AppStrings.errFailedLoadFees);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> switchBatch(dynamic batchId) async {
    selectedBatchId.value = batchId;
    await loadFees(batchId: batchId);
  }

  Future<void> _loadBillingProfile() async {
    try {
      final inst = await _instituteRepository.getInstitute();
      final paymentInfo = await _repository.getPaymentInfo();
      billingProfile.value = StudentBillingProfile(
        studentName: billingProfile.value.studentName,
        rollNumber: billingProfile.value.rollNumber,
        instituteName: inst.name,
        instituteUpiHandle: paymentInfo['upi_id'] ?? '',
        instituteUpiQrCodeUrl: paymentInfo['upi_qr_code_url'],
      );
    } catch (_) {}
  }

  Future<void> openReceipt(FeeStatement statement) async {
    selectedStatement.value = statement;
    currentReceipt.value = null;
    Get.toNamed(AppRoutes.studentFeeReceipt);
    await _fetchReceipt(statement.feeId);
  }

  Future<void> openReceiptById(int feeId) async {
    selectedStatement.value = null;
    currentReceipt.value = null;
    Get.toNamed(AppRoutes.studentFeeReceipt);
    await _fetchReceipt(feeId);
  }

  Future<void> _fetchReceipt(int feeId) async {
    try {
      isReceiptLoading.value = true;
      currentReceipt.value = await _repository.getReceipt(feeId);
    } catch (_) {
      AppSnackBar.error(AppStrings.failedToLoadReceipt);
    } finally {
      isReceiptLoading.value = false;
    }
  }

  Future<void> downloadCurrentReceipt() async {
    final receipt = currentReceipt.value;
    if (receipt == null) return;
    await _downloadReceipt(receipt);
  }

  Future<void> _downloadReceipt(StudentReceipt receipt) async {
    if (isDownloading.value) return;
    isDownloading.value = true;
    downloadProgress.value = 0.0;
    final fileName = receipt.receiptNumber.isNotEmpty
        ? '${receipt.receiptNumber}.pdf'
        : 'receipt-${receipt.id}.pdf';
    try {
      final path = await Get.find<DownloadService>().download(
        label: AppStrings.pleaseWaitYourReceiptIsBeing,
        fileName: fileName,
        fetch: () async => Uint8List.fromList(
          await _repository.downloadFeeReceipt(
            receipt.id,
            onProgress: (p) => downloadProgress.value = p,
          ),
        ),
      );
      if (path != null) {
        PdfViewerPopup.show(path: path);
      }
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  void openPayFees() {
    Get.toNamed(AppRoutes.studentPayFees);
  }

  Future<void> copyUpiHandle() async {
    final handle = billingProfile.value.instituteUpiHandle;
    if (handle.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: handle));
    AppSnackBar.success(handle, title: AppStrings.studentPayFeesCopyHint);
  }
}

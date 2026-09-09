import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/utils/date_format_utils.dart';
import 'package:tuoora/presentation/institute/controllers/batch_details_controller.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/api/api_exception.dart';

class BatchController extends GetxController {
  final InstituteRepositoryImpl _repository;

  BatchController(this._repository);

  final batchesList = <BatchModel>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;

  // Debounced search for the batches list (separate from [searchQuery]
  // which is used by the assign-students flow).
  final batchSearchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    batchNameController.addListener(() => _clearError(batchNameError));
    batchFeeController.addListener(() => _clearError(feeError));
    debounce(
      batchSearchQuery,
      (_) => loadBatches(isRefresh: true),
      time: const Duration(milliseconds: 500),
    );
  }

  void onBatchSearchChanged(String query) {
    batchSearchQuery.value = query;
  }

  void _clearError(RxnString error) {
    if (triedToSave.value && error.value != null) {
      error.value = null;
    }
  }

  final isEditMode = false.obs;
  final batchNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final batchFeeController = TextEditingController();
  final selectedDays = <String>[].obs;
  final selectedStudentIds = <String>[].obs;
  final searchQuery = ''.obs;
  final currentEditingBatchId = ''.obs;
  final allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Last date fees are due for this batch — drives the automated fee
  // reminder emails (see backend SendFeeReminders command).
  final selectedFeesLastDate = Rxn<DateTime>();

  final triedToSave = false.obs;
  final batchNameError = RxnString();
  final feeError = RxnString();
  final daysError = RxnString();
  final feesLastDateError = RxnString();

  bool validateForm() {
    bool isValid = true;

    final nameVal = ValidationUtils.validateRequired(
      batchNameController.text,
      'Batch name',
    );
    batchNameError.value = nameVal;
    if (nameVal != null) isValid = false;

    final feeVal = ValidationUtils.validateAmount(
      batchFeeController.text,
      'Batch fee',
    );
    feeError.value = feeVal;
    if (feeVal != null) isValid = false;

    final daysVal = ValidationUtils.validateDaysSelection(
      selectedDays.toList(),
    );
    daysError.value = daysVal;
    if (daysVal != null) isValid = false;

    if (selectedFeesLastDate.value == null) {
      feesLastDateError.value = 'Please select the fees last date';
      isValid = false;
    } else {
      feesLastDateError.value = null;
    }

    return isValid;
  }

  Future<void> loadBatches({bool isRefresh = true}) async {
    if (isLoading.value || isMoreLoading.value) return;

    if (isRefresh) {
      currentPage.value = 1;
      if (batchesList.isEmpty) {
        isLoading.value = true;
      }
    } else {
      if (currentPage.value > lastPage.value) return;
      isMoreLoading.value = true;
    }

    try {
      final response = await _repository.listBatches(
        page: currentPage.value,
        search: batchSearchQuery.value.trim().isEmpty
            ? null
            : batchSearchQuery.value.trim(),
      );
      final uiBatches = response.items.map((b) => b.toUIModel()).toList();

      if (isRefresh) {
        batchesList.assignAll(uiBatches);
      } else {
        batchesList.addAll(uiBatches);
      }

      lastPage.value = response.lastPage;
      currentPage.value++;
    } catch (e) {
      AppSnackBar.error('Failed to load batches: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  void initAddMode() {
    isEditMode.value = false;
    batchNameController.clear();
    descriptionController.clear();
    batchFeeController.clear();
    selectedDays.clear();
    selectedStudentIds.clear();
    searchQuery.value = '';
    currentEditingBatchId.value = '';
    selectedFeesLastDate.value = null;
    triedToSave.value = false;
    batchNameError.value = null;
    feeError.value = null;
    daysError.value = null;
    feesLastDateError.value = null;
  }

  void initEditMode(BatchModel batch) {
    isEditMode.value = true;
    currentEditingBatchId.value = batch.id;
    batchNameController.text = batch.title;
    descriptionController.text = batch.description;
    batchFeeController.text = batch.baseFee.toStringAsFixed(0);
    selectedFeesLastDate.value = batch.feesLastDate != null
        ? DateTime.tryParse(batch.feesLastDate!)
        : null;

    selectedDays.assignAll(DateFormatUtils.normalizeDays(batch.days));
    searchQuery.value = '';
    triedToSave.value = false;
    batchNameError.value = null;
    feeError.value = null;
    daysError.value = null;
    feesLastDateError.value = null;
  }

  Future<void> selectFeesLastDate(BuildContext context) async {
    final DateTime? picked = await AppPickers.date(
      context,
      initialDate: selectedFeesLastDate.value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      selectedFeesLastDate.value = picked;
      _clearError(feesLastDateError);
    }
  }

  void toggleDay(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
    _clearError(daysError);
  }

  void toggleStudent(String id) {
    if (selectedStudentIds.contains(id)) {
      selectedStudentIds.remove(id);
    } else {
      selectedStudentIds.add(id);
    }
  }

  void deleteBatchWithConfirmation(String id) {
    CommonDialog.showDeleteConfirmation(
      title: AppStrings.deleteBatch,
      description: AppStrings.areYouSureYouWantTo,
      onConfirm: () async {
        try {
          isLoading.value = true;
          Get.dialog(
            const Center(child: CommonLoading()),
            barrierDismissible: false,
          );
          await _repository.deleteBatch(int.parse(id));
          batchesList.removeWhere((batch) => batch.id == id);

          Get.back(); // close loading dialog
          Get.back(); // Pop the BatchDetailsScreen

          AppSnackBar.success(
            AppStrings.batchDeletedSuccessfully,
            title: AppStrings.deleted,
          );
        } catch (e) {
          Get.back(); // close loading dialog
          AppSnackBar.error(e.toString());
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Future<void> saveBatch(BuildContext context) async {
    triedToSave.value = true;
    if (!validateForm()) return;

    final cleanDays = DateFormatUtils.normalizeDays(selectedDays);
    final data = {
      'name': batchNameController.text.trim(),
      'description': descriptionController.text.trim(),
      'fees': batchFeeController.text.trim(),
      'fees_last_date': DateFormat(
        'yyyy-MM-dd',
      ).format(selectedFeesLastDate.value!),
      'days': cleanDays,
    };

    try {
      isLoading.value = true;
      if (isEditMode.value) {
        final updatedBatch = await _repository.updateBatch(
          int.parse(currentEditingBatchId.value),
          data,
        );
        final uiModel = updatedBatch.toUIModel();
        final index = batchesList.indexWhere(
          (b) => b.id == currentEditingBatchId.value,
        );
        if (index != -1) {
          batchesList[index] = uiModel;
        }
        if (Get.isRegistered<BatchDetailsController>(
          tag: currentEditingBatchId.value,
        )) {
          Get.find<BatchDetailsController>(
            tag: currentEditingBatchId.value,
          ).updateBatch(uiModel);
        }
      } else {
        final newBatch = await _repository.createBatch(data);
        batchesList.insert(0, newBatch.toUIModel());
      }

      batchesList.refresh();

      // Return back to previous screen
      Get.back();

      AppSnackBar.success(
        'Successfully saved ${batchNameController.text}',
        title: isEditMode.value ? 'Batch Updated' : 'Batch Created',
      );
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
        AppSnackBar.error(AppStrings.validationErrorsBelow);
      } else {
        AppSnackBar.error(e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _handleValidationErrors(Map<String, dynamic> errors) {
    if (errors.containsKey('name')) {
      batchNameError.value = (errors['name'] as List).first.toString();
    }
    if (errors.containsKey('fees')) {
      feeError.value = (errors['fees'] as List).first.toString();
    }
    if (errors.containsKey('days')) {
      daysError.value = (errors['days'] as List).first.toString();
    }
    if (errors.containsKey('fees_last_date')) {
      feesLastDateError.value = (errors['fees_last_date'] as List)
          .first
          .toString();
    }
  }

  void applyStudentAssignment() {
    // This part might need API support for assigning students to batch
    // For now keeping it local or showing a placeholder message
    Get.back();
    AppSnackBar.warning(
      AppStrings.studentAssignmentIsCurrentlyManagedVia,
      title: AppStrings.notice,
    );
  }

  @override
  void onClose() {
    batchNameController.dispose();
    descriptionController.dispose();
    batchFeeController.dispose();
    super.onClose();
  }
}

import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/data/models/daily_update_model.dart';
import 'package:tuoora/data/repositories_impl/daily_update_repository_impl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tuoora/data/models/batch_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';

class UpdatesController extends GetxController {
  final DailyUpdateRepositoryImpl _updateRepository;
  final InstituteRepositoryImpl _instituteRepository;

  UpdatesController(this._updateRepository, this._instituteRepository);

  final updatesList = <DailyUpdate>[].obs;
  final isLoading = false.obs;
  final isCreating = false.obs;

  // Create Update State
  final selectedCategory = UpdateCategory.Academic.obs;
  final selectedAudience = UpdateTargetType.all.obs;
  final selectedBatch = Rxn<Batch>();
  final selectedHolidayDate = Rxn<DateTime>();

  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final attachments = <String>[].obs;
  final appNotificationEnabled = true.obs;
  final whatsappEnabled = false.obs;

  final triedToSave = false.obs;
  final subjectError = RxnString();
  final messageError = RxnString();
  final holidayDateError = RxnString();

  bool validateForm() {
    bool isValid = true;

    if (subjectController.text.trim().isEmpty) {
      subjectError.value = 'Topic is required';
      isValid = false;
    } else {
      subjectError.value = null;
    }

    if (messageController.text.trim().isEmpty) {
      messageError.value = 'Message content is required';
      isValid = false;
    } else {
      messageError.value = null;
    }

    if (selectedCategory.value == UpdateCategory.Holiday && selectedHolidayDate.value == null) {
      holidayDateError.value = 'Holiday date is required';
      isValid = false;
    } else {
      holidayDateError.value = null;
    }

    return isValid;
  }

  final availableBatches = <Batch>[].obs;
  final isLoadingBatches = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUpdates();
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    try {
      isLoadingBatches.value = true;
      int page = 1;
      int lastPage = 1;
      final allBatches = <Batch>[];

      do {
        final response = await _instituteRepository.listBatches(page: page);
        allBatches.addAll(response.items);
        lastPage = response.lastPage;
        page++;
      } while (page <= lastPage);

      availableBatches.assignAll(allBatches);
      if (availableBatches.isNotEmpty && selectedBatch.value == null) {
        selectedBatch.value = availableBatches.first;
      }
    } catch (e) {
      AppSnackBar.error('Failed to load batches: $e');
    } finally {
      isLoadingBatches.value = false;
    }
  }

  final deletingUpdateIds = <int>{}.obs;

  /// Owner-only: deletes a daily update and drops it from the list.
  Future<bool> deleteUpdate(DailyUpdate update) async {
    final id = update.id;
    if (id == null || deletingUpdateIds.contains(id)) return false;
    try {
      deletingUpdateIds.add(id);
      final message = await _updateRepository.deleteDailyUpdate(id);
      updatesList.removeWhere((u) => u.id == id);
      AppSnackBar.success(message);
      return true;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      deletingUpdateIds.remove(id);
    }
  }

  Future<void> fetchUpdates() async {
    isLoading.value = true;
    try {
      final updates = await _updateRepository.listDailyUpdates();
      updatesList.assignAll(updates);
    } catch (e) {
      AppSnackBar.error('Failed to load updates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAttachments() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
      );

      if (result != null) {
        attachments.addAll(result.paths.whereType<String>());
      }
    } catch (e) {
      AppSnackBar.error('Could not pick files: $e');
    }
  }

  void removeAttachment(int index) {
    attachments.removeAt(index);
  }

  Future<void> broadcastUpdate() async {
    triedToSave.value = true;
    if (!validateForm()) return;

    final targetsBatch = selectedAudience.value == UpdateTargetType.batch;
    if (targetsBatch && selectedBatch.value == null) {
      AppSnackBar.error(AppStrings.pleaseSelectABatchForThis);
      return;
    }

    try {
      isCreating.value = true;
      final dailyUpdate = DailyUpdate(
        targetType: selectedAudience.value,
        topic: subjectController.text,
        description: messageController.text,
        category: selectedCategory.value,
        batchId: targetsBatch ? selectedBatch.value?.id : null,
        date: selectedCategory.value == UpdateCategory.Holiday ? selectedHolidayDate.value : null,
      );

      await _updateRepository.createDailyUpdate(dailyUpdate.toJson());

      await fetchUpdates();

      // Reset fields
      subjectController.clear();
      messageController.clear();
      attachments.clear();
      selectedCategory.value = UpdateCategory.Academic;
      selectedAudience.value = UpdateTargetType.all;
      if (availableBatches.isNotEmpty) {
        selectedBatch.value = availableBatches.first;
      }
      selectedHolidayDate.value = null;
      triedToSave.value = false;
      subjectError.value = null;
      messageError.value = null;

      Get.back();
      AppSnackBar.success(AppStrings.updateBroadcastedSuccessfully);
    } catch (e) {
      AppSnackBar.error('Failed to broadcast update: $e');
    } finally {
      isCreating.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}

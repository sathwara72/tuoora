import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/data/models/staff_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/school_class_model.dart';
import 'package:tuoora/presentation/institute/models/timetable_model.dart';

class TimetableController extends GetxController {
  final BatchModel? initialBatch;
  final InstituteRepositoryImpl _repository = Get.find<InstituteRepositoryImpl>();

  TimetableController([this.initialBatch]);

  // Specific batch if opened from Batch Details
  final currentBatch = Rxn<BatchModel>();

  // Full list of institute batches
  final batchesList = <BatchModel>[].obs;
  final isLoadingBatches = false.obs;

  // Filter in the timetable view
  final selectedFilterBatchId = RxnString();
  final selectedDay = DayOfWeek.monday.obs;

  // Timetable slots
  final slots = <TimetableSlot>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Staff picker
  final staffList = <Staff>[].obs;
  final isLoadingStaff = false.obs;
  final selectedStaffId = Rxn<int>();

  // Form State (Add / Edit)
  final editingSlotId = RxnString();
  final selectedFormBatchId = RxnString();
  final batchClasses = <SchoolClassModel>[].obs;
  final isLoadingClasses = false.obs;
  final selectedClassId = RxnString();

  final subjectController = TextEditingController();
  final roomNoController = TextEditingController();
  final descriptionController = TextEditingController();
  final formDay = DayOfWeek.monday.obs;
  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();

  // Validation
  final triedToSave = false.obs;
  final batchError = RxnString();
  final isBatchLocked = false.obs;
  final subjectError = RxnString();
  final timeError = RxnString();

  bool get isEditing => editingSlotId.value != null;

  @override
  void onInit() {
    super.onInit();
    initialize(initialBatch);

    subjectController.addListener(() {
      if (triedToSave.value && subjectError.value != null) {
        subjectError.value = null;
      }
    });
  }

  void initialize([BatchModel? batch]) {
    selectedDay.value = DayOfWeek.monday;
    currentBatch.value = batch ?? initialBatch;
    if (currentBatch.value != null) {
      selectedFilterBatchId.value = currentBatch.value!.id;
      selectedFormBatchId.value = currentBatch.value!.id;
    } else {
      selectedFilterBatchId.value = null;
    }

    fetchBatches();
    fetchStaffForAssignment();
    fetchTimetable();
  }

  Future<void> fetchBatches() async {
    try {
      isLoadingBatches.value = true;
      final response = await _repository.listBatches(page: 1);
      batchesList.assignAll(response.items.map((b) => b.toUIModel()));
      if (response.lastPage > 1) {
        for (int p = 2; p <= response.lastPage && p <= 5; p++) {
          final nextRes = await _repository.listBatches(page: p);
          batchesList.addAll(nextRes.items.map((b) => b.toUIModel()));
        }
      }
    } catch (_) {
      // Non-fatal
    } finally {
      isLoadingBatches.value = false;
    }
  }

  Future<void> fetchStaffForAssignment() async {
    if (staffList.isNotEmpty) return;
    try {
      isLoadingStaff.value = true;
      final response = await _repository.listStaff();
      staffList.assignAll(response.items);
    } catch (_) {
      // Non-fatal
    } finally {
      isLoadingStaff.value = false;
    }
  }

  Future<void> fetchTimetable() async {
    try {
      isLoading.value = true;
      int? batchId;
      if (currentBatch.value != null) {
        batchId = int.tryParse(currentBatch.value!.id);
      } else if (selectedFilterBatchId.value != null) {
        batchId = int.tryParse(selectedFilterBatchId.value!);
      }
      final response = await _repository.getTimetable(batchId: batchId);
      slots.assignAll(response);
    } catch (e) {
      AppSnackBar.error('Failed to fetch timetable: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void selectFilterBatch(String? batchId) {
    selectedFilterBatchId.value = batchId;
    fetchTimetable();
  }

  void selectDay(String day) {
    selectedDay.value = day.toLowerCase();
  }

  List<TimetableSlot> get slotsForSelectedDay {
    final dayVal = selectedDay.value.toLowerCase();
    final filtered = slots.where((s) {
      final matchesDay = s.dayOfWeek.toLowerCase() == dayVal;
      final matchesBatch = selectedFilterBatchId.value == null ||
          s.batchId == selectedFilterBatchId.value;
      return matchesDay && matchesBatch;
    }).toList();

    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  List<TimetableSlot> get allSortedSlots {
    final filtered = slots.where((s) {
      return selectedFilterBatchId.value == null ||
          s.batchId == selectedFilterBatchId.value;
    }).toList();

    const dayOrder = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };

    filtered.sort((a, b) {
      final dayA = dayOrder[a.dayOfWeek.toLowerCase()] ?? 8;
      final dayB = dayOrder[b.dayOfWeek.toLowerCase()] ?? 8;
      if (dayA != dayB) {
        return dayA.compareTo(dayB);
      }
      return a.startTime.compareTo(b.startTime);
    });

    return filtered;
  }

  int countForDay(String day) {
    final dayVal = day.toLowerCase();
    return slots.where((s) {
      final matchesDay = s.dayOfWeek.toLowerCase() == dayVal;
      final matchesBatch = selectedFilterBatchId.value == null ||
          s.batchId == selectedFilterBatchId.value;
      return matchesDay && matchesBatch;
    }).length;
  }

  /// Active days for the selected batch or all 7 days
  List<String> get availableDays {
    final bId = selectedFormBatchId.value;
    if (bId != null) {
      final batch = batchesList.firstWhereOrNull((b) => b.id == bId) ?? currentBatch.value;
      if (batch != null && batch.days.isNotEmpty) {
        const shortDayToDayOfWeek = {
          'Mon': DayOfWeek.monday,
          'Tue': DayOfWeek.tuesday,
          'Wed': DayOfWeek.wednesday,
          'Thu': DayOfWeek.thursday,
          'Fri': DayOfWeek.friday,
          'Sat': DayOfWeek.saturday,
          'Sun': DayOfWeek.sunday,
        };
        final mapped = batch.days
            .map((d) => shortDayToDayOfWeek[d])
            .whereType<String>()
            .toList();
        if (mapped.isNotEmpty) return mapped;
      }
    }
    return DayOfWeek.values;
  }

  // ── Form interactions ──────────────────────────────────────────────────

  Future<void> selectFormBatch(String? batchId) async {
    selectedFormBatchId.value = batchId;
    batchError.value = null;
    selectedClassId.value = null;
    if (batchId != null) {
      await fetchClassesForBatch(batchId);
    } else {
      batchClasses.clear();
    }
  }

  Future<void> fetchClassesForBatch(String batchId) async {
    final bId = int.tryParse(batchId);
    if (bId == null) return;
    try {
      isLoadingClasses.value = true;
      final classes = await _repository.listClasses(bId);
      batchClasses.assignAll(classes);
      if (isEditing) {
        _syncSelectedClassWithSubject();
      }
    } catch (_) {
      batchClasses.clear();
    } finally {
      isLoadingClasses.value = false;
    }
  }

  void _syncSelectedClassWithSubject([String? targetSubject]) {
    final subject = (targetSubject ?? subjectController.text).trim();
    if (subject.isEmpty) {
      selectedClassId.value = null;
      return;
    }

    final batch = batchesList.firstWhereOrNull((b) => b.id == selectedFormBatchId.value) ?? currentBatch.value;

    final classMatch = batchClasses.firstWhereOrNull(
      (c) => c.name.trim().toLowerCase() == subject.toLowerCase(),
    );
    if (classMatch != null) {
      selectedClassId.value = classMatch.id.toString();
      return;
    }

    if (batch != null && batch.subject.trim().toLowerCase() == subject.toLowerCase()) {
      selectedClassId.value = '__batch_subject__';
      return;
    }

    selectedClassId.value = subject;
  }

  void selectClass(String? classId) {
    selectedClassId.value = classId;
    if (classId == null) return;
    if (classId == '__batch_subject__') {
      final batch = batchesList.firstWhereOrNull((b) => b.id == selectedFormBatchId.value) ?? currentBatch.value;
      if (batch != null && batch.subject.trim().isNotEmpty) {
        subjectController.text = batch.subject.trim();
        subjectError.value = null;
        if (batch.staffId != null) {
          selectedStaffId.value = batch.staffId;
        }
      }
      return;
    }
    if (classId == '__custom__') {
      return;
    }
    final found = batchClasses.firstWhereOrNull((c) => c.id.toString() == classId);
    if (found != null) {
      subjectController.text = found.name;
      subjectError.value = null;
      if (found.teachers.isNotEmpty) {
        selectedStaffId.value = found.teachers.first.id;
      }
      return;
    }
    subjectController.text = classId;
    subjectError.value = null;
  }

  void selectStaff(int? id) => selectedStaffId.value = id;

  void startCreate([BatchModel? batch, bool? lockBatch]) {
    clearForm();
    final effectiveBatch = batch ?? (lockBatch == false ? null : currentBatch.value);
    if (effectiveBatch != null) {
      currentBatch.value = effectiveBatch;
      selectedFormBatchId.value = effectiveBatch.id;
      isBatchLocked.value = lockBatch ?? true;
      fetchClassesForBatch(effectiveBatch.id);
    } else {
      isBatchLocked.value = false;
      selectedFormBatchId.value = null;
      batchClasses.clear();
    }
    selectedClassId.value = null;
    formDay.value = selectedDay.value;
    fetchStaffForAssignment();
    fetchBatches();
  }

  void startEdit(TimetableSlot slot, {bool? isLocked}) {
    editingSlotId.value = slot.id;
    selectedFormBatchId.value = slot.batchId;
    isBatchLocked.value = isLocked ?? (currentBatch.value != null);
    subjectController.text = slot.subject;
    roomNoController.text = slot.roomNo ?? '';
    descriptionController.text = slot.description ?? '';
    formDay.value = slot.dayOfWeek;
    startTime.value = _parseTimeOfDay(slot.startTime);
    endTime.value = _parseTimeOfDay(slot.endTime);
    selectedStaffId.value = slot.staffId;
    _syncSelectedClassWithSubject(slot.subject);
    fetchClassesForBatch(slot.batchId);
    fetchStaffForAssignment();
    fetchBatches();
  }

  TimeOfDay? _parseTimeOfDay(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String formatTimeRange(String start, String end) {
    String formatSingle(String raw) {
      if (raw.isEmpty) return '';
      if (raw.toUpperCase().contains('AM') || raw.toUpperCase().contains('PM')) {
        return raw;
      }
      final parts = raw.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          final period = h >= 12 ? 'PM' : 'AM';
          final hour12 = h % 12 == 0 ? 12 : h % 12;
          final hourStr = hour12.toString().padLeft(2, '0');
          final minStr = m.toString().padLeft(2, '0');
          return '$hourStr:$minStr $period';
        }
      }
      return raw;
    }

    final s = formatSingle(start);
    final e = formatSingle(end);
    if (s.isEmpty && e.isEmpty) return '';
    if (s.isEmpty) return e;
    if (e.isEmpty) return s;
    return '$s - $e';
  }

  bool validateForm() {
    bool isValid = true;

    if (selectedFormBatchId.value == null || selectedFormBatchId.value!.isEmpty) {
      batchError.value = 'Please select a batch';
      isValid = false;
    } else {
      batchError.value = null;
    }

    final sErr = ValidationUtils.validateRequired(
      subjectController.text,
      'Subject',
    );
    subjectError.value = sErr;
    if (sErr != null) isValid = false;

    if (startTime.value == null || endTime.value == null) {
      timeError.value = 'Select a start and end time';
      isValid = false;
    } else {
      final startMinutes = startTime.value!.hour * 60 + startTime.value!.minute;
      final endMinutes = endTime.value!.hour * 60 + endTime.value!.minute;
      if (endMinutes <= startMinutes) {
        timeError.value = 'End time must be after start time';
        isValid = false;
      } else {
        timeError.value = null;
      }
    }

    return isValid;
  }

  Future<void> submitForm() async {
    triedToSave.value = true;
    if (!validateForm()) return;

    final data = <String, dynamic>{
      'batch_id': selectedFormBatchId.value,
      'staff_id': selectedStaffId.value,
      'subject': subjectController.text.trim(),
      'day_of_week': formDay.value.toLowerCase(),
      'start_time': _formatTime(startTime.value!),
      'end_time': _formatTime(endTime.value!),
      'room_no': roomNoController.text.trim().isEmpty
          ? null
          : roomNoController.text.trim(),
      'description': descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
    };

    try {
      isSaving.value = true;
      if (isEditing) {
        await _repository.updateTimetableSlot(int.parse(editingSlotId.value!), data);
      } else {
        await _repository.createTimetableSlot(data);
      }

      await fetchTimetable();

      final wasEditing = isEditing;
      clearForm();
      Get.back();

      AppSnackBar.success(
        wasEditing ? 'Schedule updated successfully' : 'Schedule added successfully',
      );
    } catch (e) {
      if (e is ValidationException) {
        AppSnackBar.error('Please fix the errors below');
      } else {
        AppSnackBar.error('Failed to save schedule: ${e.toString()}');
      }
    } finally {
      isSaving.value = false;
    }
  }

  void deleteSlotWithConfirmation(TimetableSlot slot) {
    CommonDialog.showDeleteConfirmation(
      title: 'Delete Schedule',
      description:
          'Are you sure you want to remove this lecture slot from the timetable?',
      onConfirm: () async {
        try {
          Get.dialog(
            const Center(child: CommonLoading()),
            barrierDismissible: false,
          );
          await _repository.deleteTimetableSlot(int.parse(slot.id));
          slots.removeWhere((s) => s.id == slot.id);

          Get.back(); // close loading dialog
          AppSnackBar.success('Schedule deleted', title: 'Deleted');
        } catch (e) {
          Get.back(); // close loading dialog
          AppSnackBar.error('Failed to delete schedule: ${e.toString()}');
        }
      },
    );
  }

  void clearForm() {
    editingSlotId.value = null;
    selectedFormBatchId.value = null;
    isBatchLocked.value = false;
    subjectController.clear();
    roomNoController.clear();
    descriptionController.clear();
    startTime.value = null;
    endTime.value = null;
    selectedStaffId.value = null;
    selectedClassId.value = '__custom__';
    batchClasses.clear();
    triedToSave.value = false;
    batchError.value = null;
    subjectError.value = null;
    timeError.value = null;
  }

  @override
  void onClose() {
    subjectController.dispose();
    roomNoController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

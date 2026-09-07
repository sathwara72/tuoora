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
import 'package:tuoora/presentation/institute/models/timetable_model.dart';

class TimetableController extends GetxController {
  final BatchModel batch;
  final InstituteRepositoryImpl _repository = Get.find<InstituteRepositoryImpl>();

  final slots = <TimetableSlot>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  TimetableController(this.batch);

  @override
  void onInit() {
    super.onInit();
    fetchTimetable();

    subjectController.addListener(() {
      if (triedToSave.value && subjectError.value != null) {
        subjectError.value = null;
      }
    });
  }

  Future<void> fetchTimetable() async {
    try {
      isLoading.value = true;
      final response = await _repository.getTimetable(int.parse(batch.id));
      slots.assignAll(response);
    } catch (e) {
      AppSnackBar.error('Failed to fetch timetable: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  /// All slots across every day, ordered by day-of-week then start time —
  /// used now that the schedule list shows the whole week at once instead
  /// of being filtered by a day tab.
  List<TimetableSlot> get sortedSlots {
    final sorted = [...slots];
    sorted.sort((a, b) {
      final dayCompare = DayOfWeek.values
          .indexOf(a.dayOfWeek)
          .compareTo(DayOfWeek.values.indexOf(b.dayOfWeek));
      if (dayCompare != 0) return dayCompare;
      return a.startTime.compareTo(b.startTime);
    });
    return sorted;
  }

  static const Map<String, String> _shortDayToDayOfWeek = {
    'Mon': DayOfWeek.monday,
    'Tue': DayOfWeek.tuesday,
    'Wed': DayOfWeek.wednesday,
    'Thu': DayOfWeek.thursday,
    'Fri': DayOfWeek.friday,
    'Sat': DayOfWeek.saturday,
    'Sun': DayOfWeek.sunday,
  };

  /// Days this batch actually runs on (from its "Active Days" setting),
  /// so the schedule form can't create a slot on a day the batch is closed.
  /// Falls back to every day if the batch has none configured.
  List<String> get availableDays {
    final mapped = batch.days
        .map((d) => _shortDayToDayOfWeek[d])
        .whereType<String>()
        .toList();
    return mapped.isEmpty ? DayOfWeek.values : mapped;
  }

  // ── Staff picker (for assigning a faculty member to a slot) ────────────
  final staffList = <Staff>[].obs;
  final isLoadingStaff = false.obs;
  final selectedStaffId = Rxn<int>();

  Future<void> fetchStaffForAssignment() async {
    if (staffList.isNotEmpty) return;
    try {
      isLoadingStaff.value = true;
      final response = await _repository.listStaff();
      staffList.assignAll(response.items);
    } catch (_) {
      // Non-fatal — staff assignment is optional on a timetable slot.
    } finally {
      isLoadingStaff.value = false;
    }
  }

  void selectStaff(int? id) => selectedStaffId.value = id;

  // ── Create / Edit form state ────────────────────────────────────────────
  String? editingSlotId;
  final subjectController = TextEditingController();
  final roomNoController = TextEditingController();
  final descriptionController = TextEditingController();
  final formDay = DayOfWeek.monday.obs;
  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();

  final triedToSave = false.obs;
  final subjectError = RxnString();
  final timeError = RxnString();

  bool get isEditing => editingSlotId != null;

  void startCreate() {
    clearForm();
    formDay.value = availableDays.first;
    fetchStaffForAssignment();
  }

  void startEdit(TimetableSlot slot) {
    editingSlotId = slot.id;
    subjectController.text = slot.subject;
    roomNoController.text = slot.roomNo ?? '';
    descriptionController.text = slot.description ?? '';
    formDay.value = slot.dayOfWeek;
    startTime.value = _parseTimeOfDay(slot.startTime);
    endTime.value = _parseTimeOfDay(slot.endTime);
    selectedStaffId.value = slot.staffId;
    fetchStaffForAssignment();
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

  bool validateForm() {
    bool isValid = true;

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
      'batch_id': batch.id,
      'staff_id': selectedStaffId.value,
      'subject': subjectController.text.trim(),
      'day_of_week': formDay.value,
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
        await _repository.updateTimetableSlot(int.parse(editingSlotId!), data);
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
    editingSlotId = null;
    subjectController.clear();
    roomNoController.clear();
    descriptionController.clear();
    startTime.value = null;
    endTime.value = null;
    selectedStaffId.value = null;
    triedToSave.value = false;
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

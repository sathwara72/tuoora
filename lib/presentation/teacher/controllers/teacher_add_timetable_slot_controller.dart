import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_timetable_repository_impl.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_timetable_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_timetable_model.dart';

class TeacherAddTimetableSlotController extends GetxController {
  final TeacherTimetableRepositoryImpl _repository;

  TeacherAddTimetableSlotController(this._repository);

  late final TeacherBatch batch;
  TeacherTimetableSlot? editingSlot;
  bool get isEditing => editingSlot != null;

  final subjectController = TextEditingController();
  final roomController = TextEditingController();
  final descriptionController = TextEditingController();

  final dayOfWeek = ''.obs;
  final startTime = Rxn<TimeOfDay>();
  final endTime = Rxn<TimeOfDay>();
  final isLoading = false.obs;

  final subjectError = RxnString();
  final timeError = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    batch = args['batch'] as TeacherBatch;
    final slot = args['slot'] as TeacherTimetableSlot?;
    if (slot != null) {
      editingSlot = slot;
      subjectController.text = slot.subject;
      roomController.text = slot.roomNo ?? '';
      descriptionController.text = slot.description ?? '';
      dayOfWeek.value = slot.dayOfWeek;
      startTime.value = _parseTime(slot.startTime);
      endTime.value = _parseTime(slot.endTime);
    } else {
      dayOfWeek.value = (args['day'] as String?) ?? TeacherBatchTimetableController.days.first;
    }
  }

  TimeOfDay? _parseTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

  void selectDay(String day) => dayOfWeek.value = day;

  void pickStartTime(TimeOfDay time) {
    startTime.value = time;
    timeError.value = null;
  }

  void pickEndTime(TimeOfDay time) {
    endTime.value = time;
    timeError.value = null;
  }

  bool _validate() {
    var isValid = true;
    subjectError.value = ValidationUtils.validateRequired(
      subjectController.text.trim(),
      'Subject',
    );
    if (subjectError.value != null) isValid = false;

    if (startTime.value == null || endTime.value == null) {
      timeError.value = 'Start and end time are required';
      isValid = false;
    } else {
      timeError.value = null;
    }
    return isValid;
  }

  Future<void> submit() async {
    if (!_validate()) return;
    try {
      isLoading.value = true;
      final data = {
        'subject': subjectController.text.trim(),
        'day_of_week': dayOfWeek.value,
        'start_time': _formatTime(startTime.value!),
        'end_time': _formatTime(endTime.value!),
        'room_no': roomController.text.trim(),
        'description': descriptionController.text.trim(),
      };
      if (isEditing) {
        await _repository.updateSlot(editingSlot!.id, data);
        AppSnackBar.success('Slot updated');
      } else {
        await _repository.createSlot({...data, 'batch_id': batch.id});
        AppSnackBar.success('Slot added');
      }
      Get.back(result: true);
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    roomController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_timetable_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_timetable_model.dart';

class TeacherBatchTimetableController extends GetxController {
  final TeacherTimetableRepositoryImpl _repository;

  TeacherBatchTimetableController(this._repository);

  static const days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];

  late final TeacherBatch batch;
  final isLoading = true.obs;
  final allSlots = <TeacherTimetableSlot>[].obs;
  final selectedDay = ''.obs;

  List<TeacherTimetableSlot> get allSortedSlots {
    final list = List<TeacherTimetableSlot>.from(allSlots);
    const dayOrder = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };
    list.sort((a, b) {
      final dayA = dayOrder[a.dayOfWeek.toLowerCase()] ?? 8;
      final dayB = dayOrder[b.dayOfWeek.toLowerCase()] ?? 8;
      if (dayA != dayB) {
        return dayA.compareTo(dayB);
      }
      return a.startTime.compareTo(b.startTime);
    });
    return list;
  }

  String formatTimeRange(String? start, String? end) {
    if ((start == null || start.isEmpty) && (end == null || end.isEmpty)) {
      return '';
    }
    final formattedStart = _formatSingleTime(start);
    final formattedEnd = _formatSingleTime(end);
    if (formattedStart.isNotEmpty && formattedEnd.isNotEmpty) {
      return '$formattedStart - $formattedEnd';
    }
    return formattedStart.isNotEmpty ? formattedStart : formattedEnd;
  }

  String _formatSingleTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) return '';
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        int h = int.parse(parts[0]);
        final m = int.parse(parts[1].split(' ').first);
        final isPm = h >= 12;
        final hourOfPeriod = h % 12 == 0 ? 12 : h % 12;
        final period = isPm ? 'PM' : 'AM';
        return '${hourOfPeriod.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
      }
    } catch (_) {}
    return timeStr;
  }

  @override
  void onInit() {
    super.onInit();
    batch = Get.arguments as TeacherBatch;
    selectedDay.value = days[0]; // Monday
    fetchTimetable();
  }

  Future<void> fetchTimetable() async {
    try {
      isLoading.value = true;
      allSlots.value = await _repository.getTimetable(batchId: batch.id);
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void selectDay(String day) => selectedDay.value = day;

  Future<void> addSlot() async {
    final created = await Get.toNamed(
      AppRoutes.teacherAddTimetableSlot,
      arguments: {'batch': batch, 'day': selectedDay.value},
    );
    if (created == true) fetchTimetable();
  }

  Future<void> editSlot(TeacherTimetableSlot slot) async {
    final updated = await Get.toNamed(
      AppRoutes.teacherAddTimetableSlot,
      arguments: {'batch': batch, 'slot': slot},
    );
    if (updated == true) fetchTimetable();
  }

  Future<void> confirmDeleteSlot(TeacherTimetableSlot slot) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Timetable Slot'),
        content: Text(
          'Are you sure you want to delete the ${slot.subject} slot (${slot.timeSlot ?? "${slot.startTime} - ${slot.endTime}"})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteSlot(slot);
    }
  }

  Future<void> deleteSlot(TeacherTimetableSlot slot) async {
    try {
      await _repository.deleteSlot(slot.id);
      AppSnackBar.success('Slot deleted');
      fetchTimetable();
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

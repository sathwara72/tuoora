import 'dart:async';

import 'package:get/get.dart';

import 'package:tuoora/data/repositories_impl/teacher_timetable_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_timetable_model.dart';

enum ClassPhase { ongoing, upcoming, done }

class TeacherDashboardController extends GetxController {
  final TeacherTimetableRepositoryImpl _repository;

  TeacherDashboardController(this._repository);

  static const _dayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  final isLoading = true.obs;
  final todaySlots = <TeacherTimetableSlot>[].obs;

  /// Ticks every minute so Ongoing / Upcoming / Done stay current.
  final now = DateTime.now().obs;
  Timer? _ticker;

  @override
  void onInit() {
    super.onInit();
    fetchToday();
    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => now.value = DateTime.now(),
    );
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  Future<void> fetchToday() async {
    try {
      isLoading.value = true;
      final day = _dayKeys[DateTime.now().weekday - 1];
      final slots = await _repository.getTimetable(day: day);
      slots.sort((a, b) => a.startTime.compareTo(b.startTime));
      todaySlots.value = slots;
    } catch (_) {
      // The dashboard should still work if the schedule can't be loaded.
      todaySlots.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  static int? _minutes(String raw) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw.trim());
    if (m == null) return null;
    return int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
  }

  ClassPhase phaseOf(TeacherTimetableSlot slot) {
    final start = _minutes(slot.startTime);
    final end = _minutes(slot.endTime);
    final t = now.value.hour * 60 + now.value.minute;
    if (end != null && t >= end) return ClassPhase.done;
    if (start != null && t >= start) return ClassPhase.ongoing;
    return ClassPhase.upcoming;
  }

  /// Ongoing / upcoming classes first (in time order), finished ones last.
  List<TeacherTimetableSlot> get orderedSlots {
    final active = <TeacherTimetableSlot>[];
    final done = <TeacherTimetableSlot>[];
    for (final s in todaySlots) {
      (phaseOf(s) == ClassPhase.done ? done : active).add(s);
    }
    return [...active, ...done];
  }

  int get remainingCount =>
      todaySlots.where((s) => phaseOf(s) != ClassPhase.done).length;

  static String formatTime(String raw) {
    final mins = _minutes(raw);
    if (mins == null) return raw;
    final h = mins ~/ 60;
    final m = mins % 60;
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${m.toString().padLeft(2, '0')} ${h >= 12 ? 'PM' : 'AM'}';
  }
}

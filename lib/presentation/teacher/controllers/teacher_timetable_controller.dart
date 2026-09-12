import 'package:get/get.dart';

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_batch_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_timetable_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_timetable_model.dart';

class TeacherTimetableController extends GetxController {
  final TeacherTimetableRepositoryImpl _timetableRepo;
  final TeacherBatchRepositoryImpl _batchRepo;

  TeacherTimetableController(this._timetableRepo, this._batchRepo);

  static const List<String> days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];

  final isLoading = true.obs;
  final allSlots = <TeacherTimetableSlot>[].obs;
  final batches = <TeacherBatch>[].obs;
  final selectedFilterBatchId = RxnInt();
  final selectedDay = 'monday'.obs;

  @override
  void onInit() {
    super.onInit();
    selectedDay.value = 'monday';
    fetchTimetable();
  }

  Future<void> fetchTimetable() async {
    try {
      isLoading.value = true;
      final fetchedBatches = await _batchRepo.getBatches();
      batches.value = fetchedBatches;

      List<TeacherTimetableSlot> slots = [];
      try {
        slots = await _timetableRepo.getTimetable();
      } catch (_) {
        slots = [];
      }

      if (slots.isEmpty && fetchedBatches.isNotEmpty) {
        final results = await Future.wait(
          fetchedBatches.map(
            (b) => _timetableRepo
                .getTimetable(batchId: b.id)
                .catchError((_) => <TeacherTimetableSlot>[]),
          ),
        );
        slots = results.expand((list) => list).toList();
      }

      allSlots.value = slots;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  List<TeacherTimetableSlot> get slotsForSelectedDay {
    final dayKey = selectedDay.value.toLowerCase();
    final batchFilter = selectedFilterBatchId.value;

    final filtered = allSlots.where((slot) {
      final matchesDay = slot.dayOfWeek.toLowerCase() == dayKey;
      final matchesBatch = batchFilter == null || slot.batchId == batchFilter;
      return matchesDay && matchesBatch;
    }).toList();

    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  void selectDay(String day) {
    selectedDay.value = day.toLowerCase();
  }

  void selectFilterBatch(int? id) {
    selectedFilterBatchId.value = id;
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
}

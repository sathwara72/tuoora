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
    'sunday',
  ];

  late final TeacherBatch batch;
  final isLoading = true.obs;
  final allSlots = <TeacherTimetableSlot>[].obs;
  final selectedDay = ''.obs;

  List<TeacherTimetableSlot> get slotsForSelectedDay => allSlots
      .where((s) => s.dayOfWeek == selectedDay.value)
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  @override
  void onInit() {
    super.onInit();
    batch = Get.arguments as TeacherBatch;
    selectedDay.value = days[(DateTime.now().weekday - 1) % 7];
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

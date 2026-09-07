import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/student_timetable_repository.dart';
import 'package:tuoora/presentation/institute/models/timetable_model.dart' show DayOfWeek;
import 'package:tuoora/presentation/student/models/student_timetable_model.dart';

class StudentTimetableController extends GetxController {
  final RxList<StudentTimetableSlot> slots = <StudentTimetableSlot>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedDay = DayOfWeek.today().obs;

  late StudentTimetableRepository _repository;

  @override
  void onInit() {
    super.onInit();
    _repository = StudentTimetableRepository(Get.find<ApiClient>());
    loadTimetable();
  }

  Future<void> loadTimetable() async {
    try {
      isLoading.value = true;
      final data = await _repository.getTimetable(day: 'all');
      slots.assignAll(data);
    } catch (e) {
      AppSnackBar.error('Failed to load timetable');
    } finally {
      isLoading.value = false;
    }
  }

  void selectDay(String day) => selectedDay.value = day;

  List<StudentTimetableSlot> get slotsForSelectedDay {
    final filtered = slots
        .where((s) => s.dayOfWeek == selectedDay.value)
        .toList();
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }
}

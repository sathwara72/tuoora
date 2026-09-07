import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/student_birthday_repository.dart';
import 'package:tuoora/presentation/student/models/student_birthday_model.dart';

class StudentBirthdayController extends GetxController {
  final RxList<StudentBirthday> birthdays = <StudentBirthday>[].obs;
  final RxBool isLoading = true.obs;

  late StudentBirthdayRepository _repository;

  @override
  void onInit() {
    super.onInit();
    _repository = StudentBirthdayRepository(Get.find<ApiClient>());
    loadBirthdays();
  }

  Future<void> loadBirthdays() async {
    try {
      isLoading.value = true;
      final data = await _repository.getBatchBirthdays();
      birthdays.assignAll(data);
    } catch (e) {
      AppSnackBar.error('Failed to load birthdays');
    } finally {
      isLoading.value = false;
    }
  }

  List<StudentBirthday> get today =>
      birthdays.where((b) => b.isBirthdayToday).toList();

  List<StudentBirthday> get upcoming =>
      birthdays.where((b) => !b.isBirthdayToday).toList();
}

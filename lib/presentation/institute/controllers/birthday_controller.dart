import 'package:get/get.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/presentation/institute/models/birthday_model.dart';

class BirthdayController extends GetxController {
  final InstituteRepositoryImpl _repository;

  BirthdayController(this._repository);

  final RxList<BirthdayModel> birthdays = <BirthdayModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxSet<int> sendingWishFor = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBirthdays();
  }

  Future<void> fetchBirthdays() async {
    try {
      isLoading.value = true;
      final data = await _repository.getBirthdays();
      birthdays.assignAll(data);
    } catch (e) {
      AppSnackBar.error('Failed to load birthdays');
    } finally {
      isLoading.value = false;
    }
  }

  List<BirthdayModel> get today =>
      birthdays.where((b) => b.isBirthdayToday).toList();

  List<BirthdayModel> get upcoming =>
      birthdays.where((b) => !b.isBirthdayToday).toList();

  Future<void> sendWish(BirthdayModel student) async {
    if (sendingWishFor.contains(student.id)) return;

    try {
      sendingWishFor.add(student.id);
      await _repository.sendBirthdayWish(
        studentId: student.id,
        studentName: student.name,
      );
      AppSnackBar.success('Wish sent to ${student.name}!');
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      sendingWishFor.remove(student.id);
    }
  }
}

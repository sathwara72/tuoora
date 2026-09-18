import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/data/repositories_impl/teacher_batch_repository_impl.dart';
import 'package:tuoora/data/repositories_impl/teacher_profile_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_profile_model.dart';

class TeacherProfileController extends GetxController {
  final TeacherProfileRepositoryImpl _repository;

  TeacherProfileController(this._repository);

  final isLoading = true.obs;
  final isUploadingAvatar = false.obs;
  final Rxn<TeacherProfile> profile = Rxn<TeacherProfile>();
  final batches = <TeacherBatch>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _repository.getProfile(),
        Get.find<TeacherBatchRepositoryImpl>().getBatches().catchError((_) => <TeacherBatch>[]),
      ]);
      profile.value = results[0] as TeacherProfile;
      batches.value = results[1] as List<TeacherBatch>;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeAvatar() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      isUploadingAvatar.value = true;
      profile.value = await _repository.updateAvatar(picked.path);
      AppSnackBar.success('Profile photo updated');
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await Get.find<AuthRepository>().logout('TEACHER');
    } catch (_) {}
    await Get.find<AuthService>().clearSession();
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  Future<void> deleteAccount() async {
    try {
      CommonLoading.show();
      await _repository.deleteAccount();
      await Get.find<AuthService>().clearSession();
      Get.offAllNamed(AppRoutes.roleSelection);
      AppSnackBar.success(AppStrings.accountDeletedSuccessfully);
    } catch (e) {
      AppSnackBar.error(
        e.toString().replaceAll('Exception: ', ''),
        title: AppStrings.accountDeletionFailed,
      );
    } finally {
      CommonLoading.dismiss();
    }
  }
}

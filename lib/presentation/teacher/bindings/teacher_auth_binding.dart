import 'package:get/get.dart';

import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/data/repositories_impl/auth_repository_impl.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_forgot_password_controller.dart';

class TeacherAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient());
    if (!Get.isRegistered<AuthRepository>()) {
      final authRepo = AuthRepository(Get.find<ApiClient>());
      Get.put<AuthRepositoryImpl>(authRepo, permanent: true);
      Get.put<AuthRepository>(authRepo, permanent: true);
    } else if (!Get.isRegistered<AuthRepositoryImpl>()) {
      Get.put<AuthRepositoryImpl>(Get.find<AuthRepository>(), permanent: true);
    }
    Get.lazyPut(() => TeacherForgotPasswordController());
  }
}

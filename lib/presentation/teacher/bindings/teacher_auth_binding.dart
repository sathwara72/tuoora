import 'package:get/get.dart';

import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_forgot_password_controller.dart';

class TeacherAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient());
    Get.lazyPut(() => AuthRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(() => TeacherForgotPasswordController());
  }
}

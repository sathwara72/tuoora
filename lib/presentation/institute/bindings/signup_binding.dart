import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/data/repositories_impl/auth_repository_impl.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/data/repositories/institute_repository.dart';
import 'package:get/get.dart';
import 'package:tuoora/presentation/institute/controllers/signup_controller.dart';

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      final authRepo = AuthRepository(Get.find<ApiClient>());
      Get.put<AuthRepositoryImpl>(authRepo, permanent: true);
      Get.put<AuthRepository>(authRepo, permanent: true);
    } else if (!Get.isRegistered<AuthRepositoryImpl>()) {
      Get.put<AuthRepositoryImpl>(Get.find<AuthRepository>(), permanent: true);
    }
    Get.lazyPut<InstituteRepository>(() => InstituteRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut<SignupController>(() => SignupController());
  }
}


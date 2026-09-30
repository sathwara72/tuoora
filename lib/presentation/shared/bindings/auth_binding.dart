import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/data/repositories_impl/auth_repository_impl.dart';
import 'package:tuoora/presentation/shared/controllers/login_controller.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRepository>()) {
      final authRepo = AuthRepository(Get.find<ApiClient>());
      Get.put<AuthRepositoryImpl>(authRepo, permanent: true);
      Get.put<AuthRepository>(authRepo, permanent: true);
    } else if (!Get.isRegistered<AuthRepositoryImpl>()) {
      Get.put<AuthRepositoryImpl>(Get.find<AuthRepository>(), permanent: true);
    }
    Get.lazyPut(() => LoginController(Get.find<AuthRepository>()), fenix: true);
  }
}


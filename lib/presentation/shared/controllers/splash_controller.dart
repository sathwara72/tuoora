import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onReady() {
    super.onReady();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = _authService.currentUser;
    final isProfileSetup = user?.isProfileSetup ?? true;

    // Auto-resume into the app only for a fully onboarded account.
    if (_authService.isAuthenticated && isProfileSetup) {
      _navigateToDashboard(user?.role);
      return;
    }

    // Authenticated but profile setup not finished.
    if (_authService.isAuthenticated && !isProfileSetup) {
      if (_authService.isLoggedIn && user?.role == 'INSTITUTE') {
        // The user has already signed in with their credentials — resume
        // profile setup so they can finish onboarding.
        Get.offAllNamed(AppRoutes.instituteProfileSetup);
        return;
      }
      // Session came only from OTP verification (the user never logged in).
      // Force a login; the login response's is_profile_setup flag then routes
      // them onward. clearSession keeps the remembered email for prefill.
      await _authService.clearSession();
    }

    // Not authenticated. If the user previously selected a role,
    // take them back to that role's login screen. Otherwise, show Role Selection.
    final lastRole = GetStorage().read('last_selected_role');
    if (lastRole != null) {
      Get.offAllNamed(AppRoutes.login, arguments: lastRole);
    } else {
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }

  void _navigateToDashboard(String? role) {
    if (role == 'STUDENT') {
      Get.offAllNamed(AppRoutes.studentDashboard);
    } else if (role == 'INSTITUTE') {
      Get.offAllNamed(AppRoutes.instituteDashboard);
    } else if (role == 'TEACHER') {
      final mustChangePassword =
          _authService.currentUser?.mustChangePassword ?? false;
      if (mustChangePassword) {
        Get.offAllNamed(AppRoutes.teacherChangePassword, arguments: true);
      } else {
        Get.offAllNamed(AppRoutes.teacherDashboard);
      }
    } else {
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }
}

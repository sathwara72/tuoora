import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';

class TeacherChangePasswordController extends GetxController {
  final _authRepository = Get.find<AuthRepository>();
  final _authService = Get.find<AuthService>();

  bool _isForced = false;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isCurrentPasswordVisible = false.obs;
  final isNewPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;

  final currentPasswordError = RxnString();
  final newPasswordError = RxnString();
  final confirmPasswordError = RxnString();

  bool get isForced => _isForced;

  @override
  void onInit() {
    super.onInit();
    _isForced = Get.arguments == true;
  }

  void toggleCurrentPasswordVisibility() =>
      isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  void toggleNewPasswordVisibility() =>
      isNewPasswordVisible.value = !isNewPasswordVisible.value;
  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  Future<void> updatePassword() async {
    final current = currentPasswordController.text;
    final newPass = newPasswordController.text;
    final confirm = confirmPasswordController.text;

    _resetErrors();

    if (!_isForced) {
      final currentErr = ValidationUtils.validateRequired(
        current,
        'Current password',
      );
      currentPasswordError.value = currentErr;
      if (currentErr != null) return;
    }

    final newErr = ValidationUtils.validatePassword(newPass);
    newPasswordError.value = newErr;
    if (newErr != null) return;

    final confirmErr = ValidationUtils.validateConfirmPassword(
      newPass,
      confirm,
    );
    confirmPasswordError.value = confirmErr;
    if (confirmErr != null) return;

    isLoading.value = true;
    try {
      final data = <String, dynamic>{
        'password': newPass,
        'password_confirmation': confirm,
      };
      if (!_isForced) {
        data['current_password'] = current;
      }
      await _authRepository.teacherChangePassword(data);

      final user = _authService.currentUser;
      if (user != null) {
        await _authService.saveSession(
          user.copyWith(mustChangePassword: false),
          stayAuthenticated: _authService.shouldStayAuthenticated,
          loggedIn: true,
          role: 'TEACHER',
        );
      }

      AppSnackBar.success(AppStrings.passwordUpdated);
      _clearFields();

      if (_isForced) {
        Get.offAllNamed(AppRoutes.teacherDashboard);
      } else {
        Get.back();
      }
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
      } else {
        AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _handleValidationErrors(Map<String, dynamic> errors) {
    if (errors.containsKey('current_password')) {
      currentPasswordError.value = (errors['current_password'] as List).first
          .toString();
    }
    if (errors.containsKey('password')) {
      newPasswordError.value = (errors['password'] as List).first.toString();
    }
    if (errors.containsKey('password_confirmation')) {
      confirmPasswordError.value = (errors['password_confirmation'] as List)
          .first
          .toString();
    }
  }

  void _resetErrors() {
    currentPasswordError.value = null;
    newPasswordError.value = null;
    confirmPasswordError.value = null;
  }

  void _clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

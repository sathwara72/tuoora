import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';

class TeacherForgotPasswordController extends GetxController {
  final _authRepository = Get.find<AuthRepository>();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isResending = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final timerSeconds = 60.obs;
  final canResend = false.obs;
  Timer? _timer;

  final emailError = RxnString();
  final otpError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = 'Email is required';
      return;
    }
    if (!GetUtils.isEmail(email)) {
      emailError.value = 'Enter a valid email';
      return;
    }
    emailError.value = null;

    isLoading.value = true;
    try {
      final message = await _authRepository.teacherForgotPassword(email);
      AppSnackBar.success(message);
      Get.toNamed(AppRoutes.teacherResetPassword, arguments: email);
      startTimer();
    } catch (e) {
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    otpError.value = otp.isEmpty ? 'OTP is required' : null;
    passwordError.value = password.isEmpty ? 'Password is required' : null;
    confirmPasswordError.value = confirmPassword.isEmpty
        ? 'Confirm your password'
        : null;
    if (otpError.value != null ||
        passwordError.value != null ||
        confirmPasswordError.value != null) {
      return;
    }

    final pwdValidation = ValidationUtils.validatePassword(password);
    if (pwdValidation != null) {
      passwordError.value = pwdValidation;
      return;
    }

    if (password != confirmPassword) {
      confirmPasswordError.value = 'Passwords do not match';
      return;
    }

    isLoading.value = true;
    try {
      final message = await _authRepository.teacherResetPassword({
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': confirmPassword,
      });
      isLoading.value = false;
      AppSnackBar.success(message);
      Get.offAllNamed(AppRoutes.login, arguments: 'TEACHER');
    } catch (e) {
      isLoading.value = false;
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void startTimer() {
    canResend.value = false;
    timerSeconds.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        canResend.value = true;
        _timer?.cancel();
      }
    });
  }

  Future<void> resendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    isResending.value = true;
    try {
      await _authRepository.teacherForgotPassword(email);
      AppSnackBar.success(AppStrings.msgOtpResent);
      startTimer();
    } catch (e) {
      AppSnackBar.error(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is String) {
      emailController.text = Get.arguments;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

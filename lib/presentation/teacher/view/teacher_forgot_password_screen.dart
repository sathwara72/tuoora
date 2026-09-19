import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/forgot_password_layout.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_forgot_password_controller.dart';

class TeacherForgotPasswordScreen
    extends GetView<TeacherForgotPasswordController> {
  const TeacherForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ForgotPasswordLayout(
      emailController: controller.emailController,
      emailError: controller.emailError,
      isLoading: controller.isLoading,
      onSend: controller.sendOtp,
    );
  }
}

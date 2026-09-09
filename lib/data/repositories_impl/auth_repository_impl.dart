import 'package:tuoora/data/models/user_model.dart';

abstract class AuthRepositoryImpl {
  Future<User> loginInstitute(
    String email,
    String password, {
    String? device,
    String? os,
  });
  Future<User> loginStudent(String email, String password);
  Future<User> loginTeacher(String email, String password);
  Future<void> logout(String role);

  Future<({String accessToken, String refreshToken})?> refreshAccessToken(
    String refreshToken,
  );

  // Forgot Password
  Future<String> forgotPassword(String email);
  Future<String> resetPassword(Map<String, dynamic> data);

  // Teacher-specific auth (separate endpoints from Institute's)
  Future<String> teacherForgotPassword(String email);
  Future<String> teacherResetPassword(Map<String, dynamic> data);
  Future<void> teacherChangePassword(Map<String, dynamic> data);
  Future<User> switchTeacherInstitute(int instituteId);
}

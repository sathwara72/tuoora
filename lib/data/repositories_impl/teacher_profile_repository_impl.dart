import 'package:tuoora/presentation/teacher/models/teacher_profile_model.dart';

abstract class TeacherProfileRepositoryImpl {
  Future<TeacherProfile> getProfile();
  Future<TeacherProfile> updateAvatar(String filePath);
}

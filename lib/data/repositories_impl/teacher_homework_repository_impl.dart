import 'package:tuoora/presentation/teacher/models/teacher_homework_model.dart';

abstract class TeacherHomeworkRepositoryImpl {
  Future<TeacherHomeworkListPage> getHomeworks({
    required int batchId,
    int page = 1,
  });

  Future<TeacherHomework> createHomework(
    Map<String, dynamic> data, {
    String? attachmentPath,
  });

  Future<TeacherHomeworkDetail> getHomeworkDetail(int id);

  Future<TeacherHomework> updateHomework(int id, Map<String, dynamic> data);

  Future<void> deleteHomework(int id);

  Future<void> submitGrades(int id, List<Map<String, dynamic>> grades);
}

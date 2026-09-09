import 'package:tuoora/presentation/teacher/models/teacher_exam_model.dart';

abstract class TeacherExamRepositoryImpl {
  Future<TeacherExamListPage> getExams({
    required int batchId,
    String? status,
    int page = 1,
  });

  Future<TeacherExam> createExam(Map<String, dynamic> data);

  Future<TeacherExam> updateExam(int id, Map<String, dynamic> data);

  Future<void> deleteExam(int id);

  Future<TeacherExamMarksData> getExamMarks(int id);

  Future<void> saveExamMarks(
    int id,
    List<Map<String, dynamic>> marks, {
    bool markStatusAsCompleted = true,
  });
}

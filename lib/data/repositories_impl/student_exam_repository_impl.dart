import 'package:tuoora/presentation/student/models/student_exam_model.dart';

abstract class StudentExamRepositoryImpl {
  Future<StudentExamListData> getExams();
  Future<StudentExamDetail> getExamDetail(int id);
}

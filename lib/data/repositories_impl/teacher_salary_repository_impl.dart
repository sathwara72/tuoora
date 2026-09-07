import 'package:tuoora/presentation/teacher/models/teacher_salary_model.dart';

abstract class TeacherSalaryRepositoryImpl {
  Future<TeacherSalaryListPage> getSalaries({
    int? month,
    int? year,
    int page = 1,
  });

  Future<List<int>> downloadSalarySlip(int id);
}

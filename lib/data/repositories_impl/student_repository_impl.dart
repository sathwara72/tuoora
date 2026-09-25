import 'package:tuoora/data/models/student_model.dart';

abstract class StudentRepositoryImpl {
  Future<List<Student>> listStudents({String? search, int? page});
  Future<Student> createStudent(Map<String, dynamic> data);
  Future<Student> getStudentById(int id);
  Future<Student> updateStudent(int id, Map<String, dynamic> data);
  Future<bool> deleteStudent(int id);
  Future<void> sendFeeReminder(dynamic id);
  Future<String> sendPassword(dynamic id);
  Future<void> resetPassword(dynamic id, String password);
  Future<void> payInstallment(
    int installmentId, {
    required double amount,
    String paymentMethod = 'Cash',
  });
}


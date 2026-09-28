import 'package:tuoora/data/models/student_model.dart';

abstract class StudentRepositoryImpl {
  Future<List<Student>> listStudents({String? search, int? page, bool unassigned = false});
  Future<Student> createStudent(Map<String, dynamic> data);
  Future<Student> getStudentById(dynamic id, {dynamic batchId});
  Future<Student> updateStudent(int id, Map<String, dynamic> data);
  Future<bool> deleteStudent(int id);
  Future<void> sendFeeReminder(dynamic id);
  Future<String> sendPassword(dynamic id);
  Future<void> resetPassword(dynamic id, String password);
  Future<bool> toggleBlock(dynamic id, bool blocked);
  Future<bool> toggleFeeReminderMute(dynamic id, bool muted);
  Future<void> payInstallment(
    int installmentId, {
    required double amount,
    String paymentMethod = 'Cash',
  });
}


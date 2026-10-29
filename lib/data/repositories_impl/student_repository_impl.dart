import 'package:tuoora/data/models/student_model.dart';
import 'package:tuoora/data/models/subject_performance_model.dart';

abstract class StudentRepositoryImpl {
  Future<List<Student>> listStudents({String? search, int? page, bool unassigned = false});
  Future<Student> createStudent(Map<String, dynamic> data);
  Future<Student> getStudentById(dynamic id, {dynamic batchId});
  Future<SubjectPerformance> getSubjectPerformance(dynamic id, {dynamic batchId});
  Future<Student> updateStudent(int id, Map<String, dynamic> data);
  Future<bool> deleteStudent(int id);
  Future<void> sendFeeReminder(dynamic id);
  Future<String> sendPassword(dynamic id);
  Future<void> resetPassword(dynamic id, String password);
  Future<bool> toggleBlock(dynamic id, bool blocked);
  Future<bool> toggleFeeReminderMute(dynamic id, bool muted);
  /// Replaces a fee's milestones: rows with an `id` are updated, rows
  /// without one are added, missing ones are removed. Returns the message.
  /// Deletes a fee record that has no payments (422 otherwise).
  Future<String> deleteFee(int feeId);
  Future<String> updateInstallments(
    int feeId,
    List<Map<String, dynamic>> installments,
  );
  Future<void> payInstallment(
    int installmentId, {
    required double amount,
    String paymentMethod = 'Cash',
  });
}


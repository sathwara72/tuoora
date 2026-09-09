import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';

abstract class TeacherBatchRepositoryImpl {
  Future<List<TeacherBatch>> getBatches();
  Future<TeacherBatchDetail> getBatchDetail(int id);
  Future<List<TeacherBatchStudent>> getBatchStudents(int batchId);
  Future<List<TeacherBatchStudent>> getAvailableStudents(int batchId, {String? search});
  Future<void> assignStudentsToBatch(int batchId, List<int> studentIds);
  Future<void> registerStudentToBatch(int batchId, Map<String, dynamic> studentData);
  Future<void> updateBatchStudent(int batchId, int studentId, Map<String, dynamic> studentData);
  Future<void> removeStudentFromBatch(int batchId, int studentId);
}

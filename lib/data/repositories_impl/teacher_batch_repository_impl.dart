import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';

abstract class TeacherBatchRepositoryImpl {
  Future<List<TeacherBatch>> getBatches();
  Future<TeacherBatchDetail> getBatchDetail(int id);
}

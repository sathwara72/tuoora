import 'package:tuoora/presentation/teacher/models/teacher_fee_model.dart';

abstract class TeacherFeeRepositoryImpl {
  Future<List<TeacherFee>> getFees(int batchId);
}

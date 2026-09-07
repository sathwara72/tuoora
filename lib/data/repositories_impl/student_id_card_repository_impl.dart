import 'package:tuoora/presentation/student/models/student_id_card_model.dart';

abstract class StudentIdCardRepositoryImpl {
  Future<StudentIdCard> getIdCard();
}

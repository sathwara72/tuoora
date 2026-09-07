import 'package:tuoora/presentation/student/models/student_birthday_model.dart';

abstract class StudentBirthdayRepositoryImpl {
  Future<List<StudentBirthday>> getBatchBirthdays();
}

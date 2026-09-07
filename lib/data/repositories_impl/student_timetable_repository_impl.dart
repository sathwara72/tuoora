import 'package:tuoora/presentation/student/models/student_timetable_model.dart';

abstract class StudentTimetableRepositoryImpl {
  Future<List<StudentTimetableSlot>> getTimetable({String day = 'all'});
}

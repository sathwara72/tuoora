import 'package:tuoora/presentation/teacher/models/teacher_timetable_model.dart';

abstract class TeacherTimetableRepositoryImpl {
  Future<List<TeacherTimetableSlot>> getTimetable({
    required int batchId,
    String? day,
  });

  Future<TeacherTimetableSlot> createSlot(Map<String, dynamic> data);

  Future<TeacherTimetableSlot> updateSlot(int id, Map<String, dynamic> data);

  Future<void> deleteSlot(int id);
}

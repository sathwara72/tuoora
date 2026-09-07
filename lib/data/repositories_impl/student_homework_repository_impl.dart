import 'package:tuoora/presentation/student/models/assignment_model.dart';
import 'package:tuoora/data/models/student_homework_attachment_model.dart';

class StudentHomeworkData {
  final AssignmentSummary summary;
  final List<Assignment> pending;
  final List<Assignment> completed;

  StudentHomeworkData({
    required this.summary,
    required this.pending,
    required this.completed,
  });
}

abstract class StudentHomeworkRepositoryImpl {
  Future<StudentHomeworkData> getHomeworks();
  Future<Assignment> getHomeworkDetail(int id);
  Future<StudentHomeworkAttachmentModel> getHomeworkAttachment(int id);
  Future<List<int>> downloadAttachment(int id, {void Function(double)? onProgress});
  Future<void> submitHomework(int id, {String? note, String? attachmentPath});
}

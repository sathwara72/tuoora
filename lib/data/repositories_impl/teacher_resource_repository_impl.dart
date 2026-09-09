import 'package:tuoora/presentation/teacher/models/teacher_resource_model.dart';

abstract class TeacherResourceRepositoryImpl {
  Future<List<TeacherResource>> getBatchResources(int batchId);

  Future<TeacherResource> uploadResource({
    required int batchId,
    required String title,
    String? subject,
    String? description,
    required String filePath,
  });

  Future<List<int>> downloadResource(int resourceId);

  Future<void> deleteResource(int resourceId);
}

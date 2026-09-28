import 'package:get/get.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_batch_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';

class TeacherBatchStudentsController extends GetxController {
  final TeacherBatchRepositoryImpl _repository;

  TeacherBatchStudentsController(this._repository);

  late final TeacherBatch batch;

  final RxList<TeacherBatchStudent> students = <TeacherBatchStudent>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is TeacherBatch) {
      batch = args;
    } else if (args is Map && args['batch'] is TeacherBatch) {
      batch = args['batch'] as TeacherBatch;
    } else {
      batch = const TeacherBatch(id: 0, name: 'Batch', status: 'active', teacherCanViewFees: false);
    }
    fetchStudents();
  }

  List<TeacherBatchStudent> get filteredStudents {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return students;
    return students.where((s) {
      final name = s.name.toLowerCase();
      final enrollment = (s.enrollmentId ?? '').toLowerCase();
      final phone = (s.phone ?? '').toLowerCase();
      return name.contains(q) || enrollment.contains(q) || phone.contains(q);
    }).toList();
  }

  Future<void> fetchStudents() async {
    isLoading.value = true;
    try {
      final result = await _repository.getBatchStudents(batch.id);
      students.assignAll(result);
    } catch (e) {
      AppSnackBar.error(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:get/get.dart';

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_homework_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_homework_model.dart';

class TeacherHomeworkGradingController extends GetxController {
  final TeacherHomeworkRepositoryImpl _repository;

  TeacherHomeworkGradingController(this._repository);

  late final TeacherHomework homework;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final submissions = <TeacherHomeworkSubmission>[].obs;

  static const statuses = ['Pending', 'Submitted', 'Reviewed'];

  @override
  void onInit() {
    super.onInit();
    homework = Get.arguments as TeacherHomework;
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      isLoading.value = true;
      final detail = await _repository.getHomeworkDetail(homework.id);
      submissions.value = detail.submissions;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void updateScore(TeacherHomeworkSubmission submission, String value) {
    if (submission.status.toLowerCase() == 'pending') return;
    submission.score = double.tryParse(value);
    submissions.refresh();
  }

  void updateStatus(TeacherHomeworkSubmission submission, String status) {
    submission.status = status;
    if (status.toLowerCase() == 'pending') {
      submission.score = null;
    }
    submissions.refresh();
  }

  Future<void> submitGrades() async {
    if (isSaving.value) return;
    try {
      isSaving.value = true;
      await _repository.submitGrades(
        homework.id,
        submissions
            .map(
              (s) => {
                'student_id': s.studentId,
                'score': s.status.toLowerCase() == 'pending' ? null : s.score,
                'status': s.status,
              },
            )
            .toList(),
      );
      Get.back(result: true);
      AppSnackBar.success('Grades saved');
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }
}

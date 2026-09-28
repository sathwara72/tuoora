import 'package:get/get.dart';

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories_impl/teacher_homework_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_homework_model.dart';

class TeacherHomeworkGradingController extends GetxController {
  final TeacherHomeworkRepositoryImpl _repository;

  TeacherHomeworkGradingController(this._repository);

  static const maxScore = 10;

  late TeacherHomework homework;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final submissions = <TeacherHomeworkSubmission>[].obs;

  /// 'all' | 'submitted' | 'pending' | 'reviewed'
  final filter = 'all'.obs;

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
      homework = detail.homework;
      submissions.value = detail.submissions;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  bool get homeworkClosed => homework.isClosed;

  static bool isPendingStatus(TeacherHomeworkSubmission s) =>
      s.status.toLowerCase() == 'pending';

  int get totalCount => submissions.length;
  int get reviewedCount =>
      submissions.where((s) => s.status.toLowerCase() == 'reviewed').length;
  int get pendingCount => submissions.where(isPendingStatus).length;
  int get submittedCount => totalCount - pendingCount;
  // Submitted but not yet reviewed (matches the web legend).
  int get awaitingReviewCount => submittedCount - reviewedCount;
  double get completion => totalCount == 0 ? 0 : submittedCount / totalCount;

  List<TeacherHomeworkSubmission> get filteredSubmissions {
    switch (filter.value) {
      case 'submitted':
        return submissions.where((s) {
          final st = s.status.toLowerCase();
          return st == 'submitted' || st == 'late';
        }).toList();
      case 'pending':
        return submissions.where(isPendingStatus).toList();
      case 'reviewed':
        return submissions
            .where((s) => s.status.toLowerCase() == 'reviewed')
            .toList();
      default:
        return submissions.toList();
    }
  }

  bool canGrade(TeacherHomeworkSubmission s) => !homeworkClosed && !isPendingStatus(s);

  void changeScore(TeacherHomeworkSubmission s, int delta) {
    if (!canGrade(s)) return;
    final next = ((s.score ?? 0).round() + delta).clamp(0, maxScore);
    s.score = next.toDouble();
    submissions.refresh();
  }

  Future<void> submitGrades() async {
    if (isSaving.value || homeworkClosed) return;
    try {
      isSaving.value = true;
      await _repository.submitGrades(
        homework.id,
        submissions
            .where((s) => !isPendingStatus(s))
            .map(
              (s) => {
                'student_id': s.studentId,
                'score': s.score ?? 0,
                'status': s.status,
              },
            )
            .toList(),
      );
      Get.back(result: true);
      AppSnackBar.success('Grades published');
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isSaving.value = false;
    }
  }
}

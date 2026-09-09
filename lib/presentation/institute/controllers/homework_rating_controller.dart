import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/presentation/institute/models/homework_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:get/get.dart';

import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/presentation/institute/controllers/batch_details_controller.dart';

class HomeworkRatingController extends GetxController {
  final HomeworkModel homework;

  final filterIndex = 0.obs; // 0: All, 1: Submitted, 2: Pending
  final submissions = <HomeworkSubmission>[].obs;
  final isLoading = false.obs;
  final isFetchingDetails = false.obs;
  final _repository = Get.find<InstituteRepositoryImpl>();

  HomeworkRatingController(this.homework);

  @override
  void onInit() {
    super.onInit();
    submissions.assignAll(homework.submissions);
    _fetchHomeworkDetails();
    if (Get.isRegistered<InstituteController>()) {
      final inst = Get.find<InstituteController>();
      if (inst.students.isEmpty) {
        inst.fetchStudents();
      }
    }
  }

  String getEnrollmentIdForStudent(HomeworkSubmission sub) {
    final direct = sub.enrollmentId?.trim() ?? '';
    if (direct.isNotEmpty) {
      return direct;
    }

    // 1. Try resolving from BatchDetailsController if available
    try {
      if (Get.isRegistered<BatchDetailsController>(tag: homework.batchId)) {
        final bdc = Get.find<BatchDetailsController>(tag: homework.batchId);
        final match = bdc.assignedStudents.firstWhereOrNull(
          (bs) =>
              bs.student.id == sub.studentId ||
              (sub.studentName.isNotEmpty &&
                  bs.student.name.trim().toLowerCase() ==
                      sub.studentName.trim().toLowerCase()),
        );
        if (match != null) {
          final enId = match.student.enrollmentID?.toString().trim() ?? '';
          if (enId.isNotEmpty) return enId;
          if (match.student.idHash.trim().isNotEmpty) {
            return match.student.idHash.trim();
          }
        }
      }
    } catch (_) {}

    // 2. Try resolving from InstituteController
    try {
      if (Get.isRegistered<InstituteController>()) {
        final inst = Get.find<InstituteController>();
        final match = inst.students.firstWhereOrNull(
          (s) =>
              s.id == sub.studentId ||
              (sub.studentName.isNotEmpty &&
                  s.name.trim().toLowerCase() ==
                      sub.studentName.trim().toLowerCase()),
        );
        if (match != null) {
          final enId = match.enrollmentID?.toString().trim() ?? '';
          if (enId.isNotEmpty) return enId;
          if (match.idHash.trim().isNotEmpty) {
            return match.idHash.trim();
          }
        }
      }
    } catch (_) {}

    return sub.studentId.toString();
  }

  Future<void> _fetchHomeworkDetails() async {
    try {
      isFetchingDetails.value = true;
      final detailedHomework = await _repository.getHomeworkDetails(int.parse(homework.id));
      submissions.assignAll(detailedHomework.submissions);
    } catch (e) {
      AppSnackBar.error('Failed to load student list');
    } finally {
      isFetchingDetails.value = false;
    }
  }

  bool get canEdit => homework.isActive;

  List<HomeworkSubmission> get filteredSubmissions {
    if (filterIndex.value == 0) return submissions;
    if (filterIndex.value == 1) {
      return submissions.where((s) => s.status.toLowerCase() == 'submitted').toList();
    }
    if (filterIndex.value == 2) {
      return submissions.where((s) => s.status.toLowerCase() == 'pending').toList();
    }
    if (filterIndex.value == 3) {
      return submissions.where((s) => s.status.toLowerCase() == 'reviewed').toList();
    }
    return submissions;
  }

  void updateScore(String studentId, double newScore) {
    if (!canEdit) return;

    // Ensure range 0-10
    if (newScore < 0 || newScore > 10) return;

    final index = submissions.indexWhere(
      (s) => s.studentId.toString() == studentId,
    );
    if (index != -1) {
      submissions[index].score = newScore;
      submissions.refresh();
    }
  }

  Future<void> submitRatings() async {
    if (!canEdit) return;

    try {
      isLoading.value = true;

      final scores = submissions
          .where((s) => s.isSubmitted)
          .map((s) => {'student_id': s.studentId, 'score': s.score.toInt()})
          .toList();

      if (scores.isEmpty) {
        AppSnackBar.warning(AppStrings.noSubmissionsToRate);
        return;
      }

      final data = {'scores': scores};
      await _repository.submitHomeworkScore(int.parse(homework.id), data);

      Get.back(result: true);
      AppSnackBar.success(AppStrings.ratingsSubmitted);
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToSubmitRatings);
    } finally {
      isLoading.value = false;
    }
  }

}


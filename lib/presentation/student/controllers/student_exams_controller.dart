import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/student_exam_repository.dart';
import 'package:tuoora/presentation/student/models/student_exam_model.dart';

class StudentExamsController extends GetxController {
  final RxInt activeTab = 0.obs; // 0: Upcoming, 1: Results

  final RxList<StudentExamListItem> upcoming = <StudentExamListItem>[].obs;
  final RxList<StudentExamListItem> results = <StudentExamListItem>[].obs;
  final Rxn<StudentExamOverallStats> overallStats =
      Rxn<StudentExamOverallStats>();

  final Rxn<StudentExamDetail> selectedExam = Rxn<StudentExamDetail>();

  final RxBool isLoading = true.obs;
  final RxBool isDetailLoading = false.obs;

  late StudentExamRepository _repository;

  @override
  void onInit() {
    super.onInit();
    _repository = StudentExamRepository(Get.find<ApiClient>());
    loadExams();
  }

  Future<void> loadExams() async {
    try {
      isLoading.value = true;
      final data = await _repository.getExams();

      upcoming.assignAll(data.exams.where((e) => e.isScheduled));
      results.assignAll(data.exams.where((e) => !e.isScheduled));
      overallStats.value = data.overallStats;
    } catch (e) {
      AppSnackBar.error('Failed to load exams');
    } finally {
      isLoading.value = false;
    }
  }

  void selectTab(int index) {
    if (index < 0 || index > 1 || activeTab.value == index) return;
    activeTab.value = index;
  }

  List<StudentExamListItem> get activeItems =>
      activeTab.value == 0 ? upcoming : results;

  Future<void> openExam(StudentExamListItem exam) async {
    selectedExam.value = null;
    Get.toNamed(AppRoutes.studentExamDetail);

    try {
      isDetailLoading.value = true;
      final detail = await _repository.getExamDetail(int.parse(exam.id));
      selectedExam.value = detail;
    } catch (e) {
      AppSnackBar.error('Failed to load exam details');
    } finally {
      isDetailLoading.value = false;
    }
  }
}

import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/presentation/institute/controllers/batch_controller.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_performance_model.dart';
import 'package:tuoora/presentation/institute/models/report_models.dart';
import 'package:tuoora/core/services/download_service.dart';
import 'package:tuoora/presentation/institute/models/student_performance_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:get/get.dart';

class ReportsController extends GetxController {
  final BatchController batchController = Get.find<BatchController>();
  final InstituteController instituteController =
      Get.find<InstituteController>();
  final InstituteRepositoryImpl _repository =
      Get.find<InstituteRepositoryImpl>();
  final DownloadService _downloadService = Get.find<DownloadService>();

  final batchPerformances = <BatchPerformance>[].obs;

  // Fee Data
  final feeReport = Rxn<FeeReportResponse>();
  final isFeeLoading = false.obs;

  final attendanceReport = Rxn<AttendanceReportResponse>();
  final isAttendanceLoading = false.obs;

  final performanceReport = Rxn<PerformanceReportResponse>();
  final isPerformanceLoading = false.obs;

  final batchFeeDetail = Rxn<BatchFeeDetailResponse>();
  final batchAttendanceDetail = Rxn<BatchAttendanceDetailResponse>();
  final batchPerformanceDetail = Rxn<BatchPerformanceDetailResponse>();

  final analytics = Rxn<AnalyticsResponse>();
  final isAnalyticsLoading = false.obs;
  final analyticsMonths = 6.obs;

  final isBatchDetailLoading = false.obs;
  final overallAttendance = '92%'.obs;
  final attendanceTrend = '2% decrease from last week'.obs;

  final selectedBatchId = Rxn<int>();
  final selectedReportType = 'Fee'.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllReports();
  }

  void loadAllReports() {
    loadPerformanceData();
    loadFeeReport();
    loadAttendanceReport();
    loadPerformanceReport();
  }

  Future<void> loadFeeReport() async {
    try {
      isFeeLoading.value = true;
      feeReport.value = await _repository.getFeeReport();
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadFeeReport);
    } finally {
      isFeeLoading.value = false;
    }
  }

  Future<void> loadAttendanceReport() async {
    try {
      isAttendanceLoading.value = true;
      attendanceReport.value = await _repository.getAttendanceReport();
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadAttendanceReport);
    } finally {
      isAttendanceLoading.value = false;
    }
  }

  Future<void> loadPerformanceReport() async {
    try {
      isPerformanceLoading.value = true;
      performanceReport.value = await _repository.getPerformanceReport();
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadPerformanceReport);
    } finally {
      isPerformanceLoading.value = false;
    }
  }

  Future<void> loadAnalytics({int? months}) async {
    try {
      if (months != null) analyticsMonths.value = months;
      isAnalyticsLoading.value = true;
      analytics.value = await _repository.getAnalytics(
        months: analyticsMonths.value,
      );
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadAnalytics);
    } finally {
      isAnalyticsLoading.value = false;
    }
  }

  Future<void> loadBatchDetail(int batchId, String type) async {
    try {
      selectedBatchId.value = batchId;
      selectedReportType.value = type;
      isBatchDetailLoading.value = true;

      if (type == 'Fee') {
        batchFeeDetail.value = await _repository.getBatchFeeReport(batchId);
      } else if (type == 'Attendance') {
        batchAttendanceDetail.value = await _repository
            .getBatchAttendanceReport(batchId);
      } else if (type == 'Performance') {
        batchPerformanceDetail.value = await _repository
            .getBatchPerformanceReport(batchId);
      }
    } catch (e) {
      AppSnackBar.error(AppStrings.failedToLoadBatchDetails);
    } finally {
      isBatchDetailLoading.value = false;
    }
  }

  Future<void> exportReport(String type) async {
    final fileName =
        '${type}_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await _downloadService.download(
      label: 'Preparing $type report…',
      fileName: fileName,
      successMessage: AppStrings.reportDownloadedSuccess,
      fetch: () {
        if (type == 'Fee') return _repository.exportFeeReport();
        if (type == 'Attendance') return _repository.exportAttendanceReport();
        return _repository.exportPerformanceReport();
      },
    );
  }

  void loadPerformanceData() {
    isPerformanceLoading.value = true;

    final List<BatchPerformance> data = batchController.batchesList.map((
      batch,
    ) {
      final studentCountStr = batch.studentCount.split(' ')[0];
      final studentCount = int.tryParse(studentCountStr) ?? 0;

      final List<StudentPerformance> students = instituteController.students
          .take(studentCount)
          .map((s) {
            final index = instituteController.students.indexOf(s);
            final rating = 7.0 + (index % 4) * 0.75;
            return StudentPerformance(
              studentId: s.id.toString(),
              studentName: s.name,
              averageRating: rating,
            );
          })
          .toList();

      double totalRating = 0;
      for (var s in students) {
        totalRating += s.averageRating;
      }
      final batchAvg = students.isEmpty ? 0.0 : totalRating / students.length;

      return BatchPerformance(
        batchId: batch.id,
        batchName: batch.title,
        averageRating: batchAvg,
        totalStudents: studentCount,
        studentPerformances: students,
      );
    }).toList();

    batchPerformances.assignAll(data);
    isPerformanceLoading.value = false;
  }

  double get overallAveragePerformance {
    if (batchPerformances.isEmpty) return 0.0;
    double total = 0;
    for (var b in batchPerformances) {
      total += b.averageRating;
    }
    return total / batchPerformances.length;
  }

  BatchPerformance? getBatchPerformance(String batchId) {
    return batchPerformances.firstWhereOrNull((b) => b.batchId == batchId);
  }
}


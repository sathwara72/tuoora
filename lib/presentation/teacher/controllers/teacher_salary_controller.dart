import 'dart:typed_data';

import 'package:get/get.dart';

import 'package:tuoora/core/services/download_service.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/pdf_viewer_popup.dart';
import 'package:tuoora/data/repositories_impl/teacher_salary_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_salary_model.dart';

class TeacherSalaryController extends GetxController {
  final TeacherSalaryRepositoryImpl _repository;

  TeacherSalaryController(this._repository);

  final isLoading = true.obs;
  final downloadingId = RxnInt();
  final salaries = <TeacherSalary>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSalaries();
  }

  Future<void> fetchSalaries() async {
    try {
      isLoading.value = true;
      final page = await _repository.getSalaries();
      salaries.value = page.items;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> viewSlip(TeacherSalary salary) async {
    if (downloadingId.value != null) return;
    downloadingId.value = salary.id;
    try {
      final path = await Get.find<DownloadService>().download(
        label: 'salary slip',
        fileName: 'salary-slip-${salary.id}.pdf',
        fetch: () async =>
            Uint8List.fromList(await _repository.downloadSalarySlip(salary.id)),
      );
      if (path != null) {
        PdfViewerPopup.show(path: path, title: 'Salary Slip');
      }
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      downloadingId.value = null;
    }
  }
}

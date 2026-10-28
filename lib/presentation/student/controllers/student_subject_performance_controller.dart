import 'package:get/get.dart';
import 'package:tuoora/core/api/api_client.dart';
import 'package:tuoora/core/constants/api_constants.dart';
import 'package:tuoora/data/models/subject_performance_model.dart';

class StudentSubjectPerformanceController extends GetxController {
  final isLoading = true.obs;
  final error = RxnString();
  final performance = const SubjectPerformance().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      error.value = null;
      final response = await Get.find<ApiClient>().get(
        ApiConstants.studentSubjectPerformance,
      );
      if (response.status.hasError) {
        final body = response.body;
        throw Exception(
          (body is Map ? body['message'] : null) ??
              'Could not load subject performance',
        );
      }
      final body = response.body;
      performance.value = SubjectPerformance.fromJson(
        body is Map ? body['data'] : null,
      );
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}

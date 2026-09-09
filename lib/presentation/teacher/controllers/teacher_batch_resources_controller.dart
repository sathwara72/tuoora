import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tuoora/core/services/download_service.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/pdf_viewer_popup.dart';
import 'package:tuoora/data/repositories_impl/teacher_resource_repository_impl.dart';
import 'package:tuoora/presentation/teacher/models/teacher_batch_model.dart';
import 'package:tuoora/presentation/teacher/models/teacher_resource_model.dart';

class TeacherBatchResourcesController extends GetxController {
  final TeacherResourceRepositoryImpl _repository;

  TeacherBatchResourcesController(this._repository);

  late final TeacherBatch batch;

  final RxList<TeacherResource> resources = <TeacherResource>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isUploading = false.obs;
  final RxnInt downloadingId = RxnInt();
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
    fetchResources();
  }

  List<TeacherResource> get filteredResources {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return resources;
    return resources.where((r) {
      final t = r.title.toLowerCase();
      final s = (r.subject ?? '').toLowerCase();
      final f = (r.fileName ?? '').toLowerCase();
      return t.contains(q) || s.contains(q) || f.contains(q);
    }).toList();
  }

  Future<void> fetchResources() async {
    isLoading.value = true;
    try {
      final list = await _repository.getBatchResources(batch.id);
      resources.assignAll(list);
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadNewResource({
    required String title,
    String? subject,
    String? description,
    required String filePath,
  }) async {
    isUploading.value = true;
    try {
      final res = await _repository.uploadResource(
        batchId: batch.id,
        title: title,
        subject: subject,
        description: description,
        filePath: filePath,
      );
      resources.insert(0, res);
      AppSnackBar.success('Study material uploaded successfully.');
      return true;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> downloadOrView(TeacherResource resource) async {
    if (downloadingId.value != null) return;
    downloadingId.value = resource.id;

    try {
      final fileName = resource.fileName ?? 'resource_${resource.id}.pdf';

      if (Get.isRegistered<DownloadService>()) {
        final path = await Get.find<DownloadService>().download(
          label: 'Downloading ${resource.title}',
          fileName: fileName,
          fetch: () async => Uint8List.fromList(
            await _repository.downloadResource(resource.id),
          ),
        );

        if (path != null && resource.isPdf) {
          PdfViewerPopup.show(path: path, title: resource.title);
        }
      } else if (resource.fileUrl != null && resource.fileUrl!.isNotEmpty) {
        final uri = Uri.parse(resource.fileUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      // Fallback to direct fileUrl if download stream error
      if (resource.fileUrl != null && resource.fileUrl!.isNotEmpty) {
        try {
          final uri = Uri.parse(resource.fileUrl!);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          AppSnackBar.error('Failed to open resource.');
        }
      } else {
        AppSnackBar.error('Failed to download resource: $e');
      }
    } finally {
      downloadingId.value = null;
    }
  }

  Future<bool> deleteResource(TeacherResource resource) async {
    try {
      await _repository.deleteResource(resource.id);
      resources.removeWhere((r) => r.id == resource.id);
      AppSnackBar.success('Resource deleted successfully.');
      return true;
    } catch (e) {
      AppSnackBar.error(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}

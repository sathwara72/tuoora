import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/resource_model.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/core/widgets/resource_mode_toggle.dart';

class ResourcesController extends GetxController {
  final BatchModel batch;
  final InstituteRepositoryImpl _repository =
      Get.find<InstituteRepositoryImpl>();

  final resources = <ResourceModel>[].obs;

  void removeResource(String id) {
    resources.removeWhere((r) => r.id == id);
  }

  final isLoading = false.obs;

  ResourcesController(this.batch);

  @override
  void onInit() {
    super.onInit();
    fetchResources();
  }

  Future<void> fetchResources() async {
    try {
      isLoading.value = true;
      final response = await _repository.getResources(int.parse(batch.id));
      resources.assignAll(response);
    } catch (e) {
      AppSnackBar.error('Failed to fetch resources: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Dialog Controllers
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkUrlController = TextEditingController();
  final selectedFileName = ''.obs;
  final selectedFilePath = ''.obs;
  final selectedType = ResourceType.document.obs;
  final isLinkMode = false.obs;

  final triedToSave = false.obs;
  final subjectError = RxnString();
  final fileError = RxnString();

  void setUploadMode(bool link) {
    isLinkMode.value = link;
    fileError.value = null;
  }

  bool validateForm() {
    bool isValid = true;

    if (subjectController.text.trim().isEmpty) {
      subjectError.value = 'Title is required';
      isValid = false;
    } else {
      subjectError.value = null;
    }

    if (isLinkMode.value) {
      if (!isValidHttpUrl(linkUrlController.text)) {
        fileError.value = 'Please enter a valid link (https://...)';
        isValid = false;
      } else {
        fileError.value = null;
      }
    } else if (selectedFilePath.isEmpty) {
      fileError.value = 'Please select a file';
      isValid = false;
    } else {
      fileError.value = null;
    }

    return isValid;
  }

  // Allowed extensions per resource category. Anything outside these three
  // sets (audio, archives, executables, etc.) is rejected at the picker.
  static const Set<String> _imageExts = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'heic',
    'bmp',
  };
  static const Set<String> _videoExts = {
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'm4v',
  };
  static const Set<String> _documentExts = {
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'txt',
    'csv',
    'rtf',
  };

  // Size caps in MB per category.
  static const double _imageMaxMb = 5;
  static const double _documentMaxMb = 10;
  static const double _videoMaxMb = 20;

  Future<void> pickFile() async {
    try {
      // Restrict the picker to allowed extensions so the OS file chooser
      // hides obviously-invalid files (e.g. audio, archives).
      final List<String> allowed = [
        ..._imageExts,
        ..._videoExts,
        ..._documentExts,
      ];
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowed,
      );

      if (result == null || result.files.single.path == null) return;
      final file = result.files.single;
      final String ext = file.name.contains('.')
          ? file.name.split('.').last.toLowerCase()
          : '';

      // Belt-and-braces: validate type again in case the OS picker ignored
      // [allowedExtensions] (some Android pickers do).
      final ResourceType? category = _categoryFor(ext);
      if (category == null) {
        AppSnackBar.error(
          AppStrings.onlyImageVideoAndDocumentFiles,
          title: AppStrings.unsupportedFileType,
        );
        return;
      }

      // Size check against the category cap.
      final double sizeMb = file.size / (1024 * 1024);
      final double limit = _limitFor(category);
      if (sizeMb > limit) {
        AppSnackBar.error(
          '${_labelFor(category)} files must be under ${limit.toStringAsFixed(0)} MB. '
          'Selected file is ${sizeMb.toStringAsFixed(2)} MB.',
          title: AppStrings.fileTooLarge,
        );
        return;
      }

      selectedType.value = category;
      selectedFilePath.value = file.path!;
      selectedFileName.value = file.name;
      fileError.value = null;
    } catch (e) {
      AppSnackBar.error('Failed to pick file: ${e.toString()}');
    }
  }

  ResourceType? _categoryFor(String ext) {
    if (_imageExts.contains(ext)) return ResourceType.image;
    if (_videoExts.contains(ext)) return ResourceType.video;
    if (_documentExts.contains(ext)) return ResourceType.document;
    return null;
  }

  double _limitFor(ResourceType type) {
    switch (type) {
      case ResourceType.image:
        return _imageMaxMb;
      case ResourceType.video:
        return _videoMaxMb;
      case ResourceType.document:
      case ResourceType.youtube:
        return _documentMaxMb;
    }
  }

  String _labelFor(ResourceType type) {
    switch (type) {
      case ResourceType.image:
        return 'Image';
      case ResourceType.video:
        return 'Video';
      case ResourceType.document:
        return 'Document';
      case ResourceType.youtube:
        return 'Link';
    }
  }

  Future<void> uploadResource() async {
    triedToSave.value = true;
    if (!validateForm()) return;

    try {
      Get.dialog(
        const Center(child: CommonLoading()),
        barrierDismissible: false,
      );

      final Map<String, dynamic> data;
      if (isLinkMode.value) {
        data = {
          'batch_id': batch.id,
          'title': subjectController.text,
          'description': descriptionController.text,
          'resource_type': 'link',
          'link_url': linkUrlController.text.trim(),
        };
      } else {
        final String typeStr = selectedType.value == ResourceType.image
            ? 'image'
            : (selectedType.value == ResourceType.video ? 'video' : 'document');
        data = {
          'batch_id': batch.id,
          'title': subjectController.text,
          'description': descriptionController.text,
          'resource_type': 'file',
          'file_type': typeStr,
          'file': selectedFilePath.value,
        };
      }

      final responseData = await _repository.uploadResource(data);

      final newResource = ResourceModel.fromJson(responseData);
      resources.insert(0, newResource);

      clearForm();

      // Close loading dialog
      Get.back();
      // Close creation dialog
      Get.back();

      AppSnackBar.success(AppStrings.resourceUploadedSuccessfully);
    } catch (e) {
      // Close loader if open
      Get.back();
      AppSnackBar.error('Failed to upload resource: ${e.toString()}');
    }
  }

  void clearForm() {
    subjectController.clear();
    descriptionController.clear();
    linkUrlController.clear();
    selectedFileName.value = '';
    selectedFilePath.value = '';
    isLinkMode.value = false;
    triedToSave.value = false;
    subjectError.value = null;
    fileError.value = null;
  }

  @override
  void onClose() {
    subjectController.dispose();
    descriptionController.dispose();
    linkUrlController.dispose();
    super.onClose();
  }
}

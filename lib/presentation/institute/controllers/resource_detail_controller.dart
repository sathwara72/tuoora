import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/download_service.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:tuoora/presentation/institute/controllers/resources_controller.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:chewie/chewie.dart';

class ResourceDetailController extends GetxController {
  final InstituteRepositoryImpl _repository;
  final DownloadService _downloadService = Get.find<DownloadService>();

  ResourceDetailController(this._repository);

  final isPlaying = false.obs;
  final progress = 0.0.obs;
  final downloadProgress = 0.0.obs;
  final isDownloading = false.obs;
  final isLoading = false.obs;

  // Video Player
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  final isVideoInitialized = false.obs;

  Future<void> initializeVideo(String url) async {
    try {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await videoPlayerController?.initialize();
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: videoPlayerController?.value.aspectRatio,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        placeholder: const CommonLoading(color: AppColors.white),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: AppColors.white),
            ),
          );
        },
      );
      isVideoInitialized.value = true;
    } catch (e) {
      if (kDebugMode) {
        print('Video Initialization Error: $e');
      }
    }
  }

  void togglePlay() {
    isPlaying.value = !isPlaying.value;
  }

  Future<void> downloadResource(
    int resourceId,
    String fileName,
    String? extension,
  ) async {
    isDownloading.value = true;
    downloadProgress.value = 0.0;

    final fullFileName = extension != null && !fileName.contains('.')
        ? '$fileName.$extension'
        : fileName;

    try {
      await _downloadService.download(
        label: 'Downloading $fileName…',
        fileName: fullFileName,
        fetch: () => _repository.downloadResource(
          resourceId,
          onProgress: (p) => downloadProgress.value = p,
        ),
      );
    } finally {
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  Future<void> deleteResource(String resourceId, String batchId) async {
    try {
      isLoading.value = true;
      await _repository.deleteResource(int.parse(resourceId));

      if (Get.isRegistered<ResourcesController>(tag: batchId)) {
        Get.find<ResourcesController>(tag: batchId).removeResource(resourceId);
      }

      Get.back();
      AppSnackBar.success(AppStrings.resourceDeletedSuccessfully);
    } catch (e) {
      AppSnackBar.error('Failed to delete resource: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.onClose();
  }
}

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/presentation/institute/models/resource_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_bottom_button.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/presentation/institute/controllers/resource_detail_controller.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:tuoora/presentation/institute/view/in_app_resource_viewer.dart';

class ResourceDetailScreen extends StatelessWidget {
  const ResourceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ResourceModel resource = Get.arguments;
    final controller = Get.put(
      ResourceDetailController(Get.find<InstituteRepositoryImpl>()),
      tag: resource.id,
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              Column(
                children: [
                  InstituteAppBar(
                    title: AppStrings.instResourceDetailTitle,
                    onBackTap: () => Get.back(),
                    actions: [_buildDeleteAction(controller, resource)],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.x16.add(AppSpacing.y16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPreviewThumbnail(resource),
                          AppSpacing.v32,
                          Text(
                            resource.subject,
                            style: AppTextStyles.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          AppSpacing.v12,
                          Text(
                            resource.description,
                            style: AppTextStyles.outfit(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          AppSpacing.v40,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (controller.isLoading.value)
                const Center(child: CommonLoading()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => InstituteBottomButton(
          label: controller.isDownloading.value
              ? 'Downloading (${(controller.downloadProgress.value * 100).toInt()}%)'
              : AppStrings.instDownloadResourceBtn,
          icon: controller.isDownloading.value ? null : Icons.download_rounded,
          onTap: controller.isDownloading.value
              ? null
              : () => controller.downloadResource(
                  int.parse(resource.id),
                  resource.displayFileName,
                  resource.fileName.contains('.')
                      ? resource.fileName.split('.').last
                      : null,
                ),
        ),
      ),
    );
  }

  // Single tappable thumbnail. For images we show a real thumbnail; for
  // videos and documents we render an icon + filename on a tinted card.
  // Tapping opens the right player in the in-app viewer (see [_openViewer]).
  Widget _buildPreviewThumbnail(ResourceModel resource) {
    final Color accent = _accentFor(resource.type);
    final bool hasUrl =
        resource.fileUrl != null && resource.fileUrl!.isNotEmpty;

    return GestureDetector(
      onTap: hasUrl ? () => _openViewer(resource) : null,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildThumbnailBackdrop(resource, accent),
            // Centered play / fullscreen affordance.
            if (hasUrl)
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    resource.type == ResourceType.video
                        ? Icons.play_arrow_rounded
                        : Icons.fullscreen_rounded,
                    color: AppColors.white,
                    size: 36,
                  ),
                ),
              ),
            // Filename footer strip on non-image previews.
            if (resource.type != ResourceType.image)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Text(
                    resource.displayFileName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailBackdrop(ResourceModel resource, Color accent) {
    if (resource.type == ResourceType.image &&
        resource.fileUrl != null &&
        resource.fileUrl!.isNotEmpty) {
      return AppNetworkImage(
        url: resource.fileUrl!,
        fit: BoxFit.cover,
        placeholder: Container(
          color: accent.withValues(alpha: 0.08),
          child: const CommonLoading(),
        ),
        errorWidget: Container(
          color: accent.withValues(alpha: 0.08),
          child: Icon(Icons.broken_image_rounded, color: accent, size: 56),
        ),
      );
    }
    return Container(
      color: accent.withValues(alpha: 0.08),
      child: Center(
        child: Icon(_iconFor(resource.type), color: accent, size: 80),
      ),
    );
  }

  void _openViewer(ResourceModel resource) {
    final url = resource.type == ResourceType.youtube
        ? (resource.youtubeUrl ?? resource.fileUrl)
        : resource.fileUrl;
    if (url == null || url.isEmpty) return;
    Widget viewer;
    switch (resource.type) {
      case ResourceType.image:
        viewer = InAppResourceViewer.image(
          url: url,
          title: resource.displayFileName,
        );
        break;
      case ResourceType.video:
        viewer = InAppResourceViewer.video(
          url: url,
          title: resource.displayFileName,
        );
        break;
      case ResourceType.document:
      case ResourceType.youtube:
        viewer = InAppResourceViewer.web(
          url: url,
          title: resource.displayFileName,
        );
        break;
    }
    Get.to(() => viewer, fullscreenDialog: true, transition: Transition.fadeIn);
  }

  IconData _iconFor(ResourceType type) {
    switch (type) {
      case ResourceType.image:
        return Icons.image_rounded;
      case ResourceType.video:
        return Icons.play_circle_outline_rounded;
      case ResourceType.document:
        return Icons.description_rounded;
      case ResourceType.youtube:
        return Icons.link_rounded;
    }
  }

  Color _accentFor(ResourceType type) {
    switch (type) {
      case ResourceType.image:
        return Colors.purple;
      case ResourceType.video:
        return Colors.orange;
      case ResourceType.document:
        return AppColors.primaryBrand;
      case ResourceType.youtube:
        return Colors.red;
    }
  }

  Widget _buildDeleteAction(
    ResourceDetailController controller,
    ResourceModel resource,
  ) {
    return IconButton(
      onPressed: () {
        CommonDialog.showDeleteConfirmation(
          title: AppStrings.deleteResource,
          description: AppStrings.resourceDetailAreYouSureYouWantTo,
          onConfirm: () =>
              controller.deleteResource(resource.id, resource.batchId),
        );
      },
      icon: const AppActionIcon(asset: AppImages.icDelete),
    );
  }
}

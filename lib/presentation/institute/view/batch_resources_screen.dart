import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/enums/app_enums.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/presentation/institute/controllers/resources_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/resource_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';

class BatchResourcesScreen extends StatelessWidget {
  const BatchResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BatchModel batch = Get.arguments;
    final controller = Get.put(ResourcesController(batch), tag: batch.id);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: 'Materials',
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryBrand,
                onRefresh: () => controller.fetchResources(),
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.resources.isEmpty) {
                    return const Center(child: CommonLoading());
                  }
                  if (controller.resources.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: const AppEmptyView(
                          icon: Icons.folder_open_outlined,
                          title: 'No Materials Found',
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.all16.add(
                      const EdgeInsets.only(bottom: 80),
                    ),
                    itemCount: controller.resources.length,
                    itemBuilder: (context, index) =>
                        _buildResourceItem(controller.resources[index], index),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SubscriptionGuard.runAddAction(
          () => _showUploadDialog(context, controller),
        ),
        backgroundColor: SubscriptionGuard.blocksAdd
            ? AppColors.textMuted
            : AppColors.primaryBrand,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  static const List<Color> _stripePalette = <Color>[
    AppColors.instBrandOrange,
    AppColors.successGreen,
    AppColors.orangeTag,
    AppColors.subjectPhysics,
    AppColors.successGreen,
  ];

  Widget _buildResourceItem(ResourceModel resource, int index) {
    final Color stripe = _stripePalette[index % _stripePalette.length];
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.instituteResourceDetail, arguments: resource),
      child: Container(
        margin: AppSpacing.bottom10,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: stripe),
                Expanded(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: _getResourceColor(
                              resource.type,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.cardRadius,
                            ),
                          ),
                          child: Icon(
                            _getResourceIcon(resource.type),
                            color: _getResourceColor(resource.type),
                            size: 24,
                          ),
                        ),
                        AppSpacing.h16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.subject,
                                style: AppTextStyles.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              AppSpacing.v4,
                              Text(
                                resource.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.outfit(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              AppSpacing.v8,
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: AppColors.textMuted,
                                  ),
                                  AppSpacing.h4,
                                  Text(
                                    DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(resource.uploadedAt),
                                    style: AppTextStyles.outfit(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context, ResourcesController controller) {
    CommonDialog.show(
      title: AppStrings.instUploadContentHeader,
      confirmText: AppStrings.instUploadBtn,
      onConfirm: () => controller.uploadResource(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AppInputField(
              label: AppStrings.instNoteTitleLabel,
              controller: controller.subjectController,
              hint: AppStrings.enterTitle,
              errorText: controller.triedToSave.value
                  ? controller.subjectError.value
                  : null,
            ),
          ),
          AppSpacing.v16,
          AppInputField(
            label: AppStrings.instBatchDescLabel,
            controller: controller.descriptionController,
            hint: AppStrings.hintEnterDescription,
            maxLines: 3,
          ),
          AppSpacing.v24,
          const InstituteLabel(AppStrings.attachments),
          AppSpacing.v4,
          _buildAttachmentButton(controller),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(ResourcesController controller) {
    return Obx(() {
      final fileName = controller.selectedFileName.value;
      final hasError =
          controller.triedToSave.value && controller.fileError.value != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.pickFile(),
            child: Container(
              padding: AppSpacing.all16,
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? Colors.redAccent : Colors.transparent,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_file_rounded,
                    color: AppColors.fieldLabel,
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Text(
                      fileName.isEmpty
                          ? AppStrings.instAttachFileHint
                          : fileName,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: fileName.isEmpty
                            ? FontWeight.w500
                            : FontWeight.w700,
                        color: fileName.isEmpty
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                controller.fileError.value!,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      );
    });
  }

  IconData _getResourceIcon(ResourceType type) {
    switch (type) {
      case ResourceType.image:
        return Icons.image_outlined;
      case ResourceType.video:
        return Icons.video_library_outlined;
      case ResourceType.document:
        return Icons.description_outlined;
    }
  }

  Color _getResourceColor(ResourceType type) {
    switch (type) {
      case ResourceType.image:
        return Colors.purple;
      case ResourceType.video:
        return Colors.orange;
      case ResourceType.document:
        return AppColors.primaryBrand;
    }
  }
}

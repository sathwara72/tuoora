import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/presentation/institute/controllers/homework_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/widgets/app_action_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddHomeworkScreen extends StatelessWidget {
  const AddHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BatchModel batch = Get.arguments;
    final controller = Get.find<HomeworkController>(tag: batch.id);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.instAddHomeworkTitle,
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.x16.add(AppSpacing.y16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(
                      () => AppInputField(
                        label: AppStrings.instHomeworkSubjectLabel,
                        controller: controller.titleController,
                        hint: AppStrings.instBatchSubjectHint,
                        errorText: controller.titleError.value,
                      ),
                    ),
                    AppSpacing.v24,
                    const InstituteLabel(AppStrings.instDueDateLabel),
                    _buildDatePicker(context, controller),
                    AppSpacing.v24,
                    _buildLateSubmissionToggle(controller),
                    AppSpacing.v24,
                    AppInputField(
                      label: AppStrings.instInstructionDetailsLabel,
                      controller: controller.descriptionController,
                      hint: AppStrings.instInstructionDetailsHint,
                      maxLines: 5,
                    ),
                    AppSpacing.v24,
                    const InstituteLabel(AppStrings.instResourceMaterialsLabel),
                    _buildResourceUpload(controller),
                    AppSpacing.v32,
                    _buildSaveButton(context, controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, HomeworkController controller) {
    return GestureDetector(
      onTap: () async {
        final date = await AppPickers.date(
          context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          controller.dueDate.value = date;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSpacing.all16,
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: controller.dateError.value != null
                    ? AppColors.bohoRed
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.textMuted,
                ),
                AppSpacing.h12,
                Obx(
                  () => Text(
                    controller.dueDate.value == null
                        ? AppStrings.instDueDateHint
                        : DateFormat(
                            'MM/dd/yyyy',
                          ).format(controller.dueDate.value!),
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      color: controller.dueDate.value == null
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                      fontWeight: controller.dueDate.value == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.dateError.value != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  controller.dateError.value!,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildLateSubmissionToggle(HomeworkController controller) {
    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.instAllowLateSubmissionLabel,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.v4,
                Text(
                  AppStrings.instAllowLateSubmissionDesc,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: controller.allowLateSubmission.value,
              onChanged: (v) => controller.allowLateSubmission.value = v,
              activeTrackColor: AppColors.primaryBrand,
              activeThumbColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceUpload(HomeworkController controller) {
    return Obx(
      () => GestureDetector(
        onTap: controller.selectedAttachment.value == null
            ? controller.pickAttachment
            : null,
        child: Container(
          padding: AppSpacing.all32,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.successBg,
              style: BorderStyle.solid,
            ),
          ),
          child: controller.selectedAttachment.value == null
              ? Column(
                  children: [
                    Container(
                      padding: AppSpacing.all12,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBrand,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: AppColors.white),
                    ),
                    AppSpacing.v12,
                    Text(
                      AppStrings.instAddAttachmentBtn,
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.v4,
                    Text(
                      AppStrings.instAddAttachmentDesc,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const Icon(
                      Icons.insert_drive_file_outlined,
                      color: AppColors.primaryBrand,
                      size: 40,
                    ),
                    AppSpacing.v12,
                    Text(
                      controller.selectedAttachment.value!.split('/').last,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.v12,
                    TextButton.icon(
                      onPressed: controller.removeAttachment,
                      icon: const AppActionIcon(asset: AppImages.icDelete),
                      label: Text(
                        AppStrings.labelRemove,
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bohoRed,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, HomeworkController controller) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          label: AppStrings.instCreateHomeworkBtn,
          isLoading: controller.isLoading.value,
          onPressed: () {
            controller.createHomework();
          },
        ),
      ),
    );
  }
}

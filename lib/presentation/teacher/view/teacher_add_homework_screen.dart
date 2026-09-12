import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_add_homework_controller.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherAddHomeworkScreen extends GetView<TeacherAddHomeworkController> {
  const TeacherAddHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(title: controller.isEditing ? 'Edit Homework' : 'New Homework'),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.x16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('Title'),
                    Obx(
                      () => _field(
                        controller: controller.titleController,
                        hint: 'e.g. Chapter 3 exercises',
                        errorText: controller.titleError.value,
                      ),
                    ),
                    AppSpacing.v16,
                    _label('Description'),
                    Obx(
                      () => _field(
                        controller: controller.descriptionController,
                        hint: 'Instructions for students',
                        errorText: controller.descriptionError.value,
                        maxLines: 4,
                      ),
                    ),
                    AppSpacing.v16,
                    _label('Due Date'),
                    Obx(
                      () => GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.dueDate.value ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                          );
                          if (picked != null) controller.pickDueDate(picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.fieldBg,
                            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            border: Border.all(
                              color: controller.dateError.value != null
                                  ? Colors.redAccent
                                  : AppColors.fieldBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryBrand),
                              AppSpacing.h8,
                              Text(
                                controller.dueDate.value != null
                                    ? DateFormat('dd MMM, yyyy').format(controller.dueDate.value!)
                                    : 'Select due date',
                                style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!controller.isEditing) ...[
                      AppSpacing.v16,
                      _label('Attachment (optional)'),
                      Obx(
                        () => GestureDetector(
                          onTap: controller.selectedAttachment.value == null
                              ? controller.pickAttachment
                              : controller.removeAttachment,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.fieldBg,
                              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                              border: Border.all(color: AppColors.fieldBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  controller.selectedAttachment.value == null
                                      ? Icons.attach_file_rounded
                                      : Icons.close_rounded,
                                  size: 16,
                                  color: AppColors.primaryBrand,
                                ),
                                AppSpacing.h8,
                                Expanded(
                                  child: Text(
                                    controller.selectedAttachment.value?.split('/').last ??
                                        'Attach a file',
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.outfit(fontSize: 13, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    AppSpacing.v32,
                    Obx(
                      () => AppButton(
                        label: controller.isEditing ? 'Save Changes' : 'Create Homework',
                        onPressed: controller.isLoading.value ? null : controller.submit,
                        isLoading: controller.isLoading.value,
                      ),
                    ),
                    AppSpacing.v24,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s8),
        child: Text(
          text,
          style: AppTextStyles.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.fieldLabel,
            letterSpacing: 1.0,
          ),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    String? errorText,
    int maxLines = 1,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: hasError ? Colors.redAccent : AppColors.fieldBorder),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.outfit(fontSize: 14, color: AppColors.fieldLabel),
              border: InputBorder.none,
              contentPadding: AppSpacing.all16,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: AppTextStyles.outfit(fontSize: 12, color: Colors.redAccent),
            ),
          ),
      ],
    );
  }
}

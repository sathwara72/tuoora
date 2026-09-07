import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/presentation/institute/controllers/exam_controller.dart';
import 'package:tuoora/presentation/institute/models/exam_model.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddExamScreen extends StatelessWidget {
  const AddExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String batchId = Get.arguments as String;
    final controller = Get.find<ExamController>(tag: batchId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: controller.isEditing ? 'Edit Exam' : 'Add Exam',
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
                        label: 'EXAM TITLE',
                        controller: controller.titleController,
                        hint: 'e.g. Mid Term Mathematics',
                        errorText: controller.titleError.value,
                      ),
                    ),
                    AppSpacing.v24,
                    AppInputField(
                      label: 'SUBJECT (OPTIONAL)',
                      controller: controller.subjectController,
                      hint: 'Defaults to batch subject',
                    ),
                    AppSpacing.v24,
                    const InstituteLabel('EXAM TYPE'),
                    AppSpacing.v8,
                    _buildExamTypeChips(controller),
                    AppSpacing.v24,
                    const InstituteLabel('EXAM DATE'),
                    _buildDatePicker(context, controller),
                    AppSpacing.v24,
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => AppInputField(
                              label: 'TOTAL MARKS',
                              controller: controller.totalMarksController,
                              hint: '100',
                              keyboardType: TextInputType.number,
                              errorText: controller.totalMarksError.value,
                            ),
                          ),
                        ),
                        AppSpacing.h16,
                        Expanded(
                          child: Obx(
                            () => AppInputField(
                              label: 'PASSING MARKS',
                              controller: controller.passingMarksController,
                              hint: '35',
                              keyboardType: TextInputType.number,
                              errorText: controller.passingMarksError.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.v24,
                    AppInputField(
                      label: 'DESCRIPTION (OPTIONAL)',
                      controller: controller.descriptionController,
                      hint: 'Syllabus, instructions, or notes',
                      maxLines: 4,
                    ),
                    AppSpacing.v32,
                    _buildSaveButton(controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamTypeChips(ExamController controller) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ExamType.values.map((type) {
          final isSelected = controller.examType.value == type;
          return GestureDetector(
            onTap: () => controller.examType.value = type,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBrand : AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBrand
                      : AppColors.fieldBorder,
                ),
              ),
              child: Text(
                ExamType.labelFor(type),
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, ExamController controller) {
    return GestureDetector(
      onTap: () async {
        final date = await AppPickers.date(
          context,
          initialDate: controller.examDate.value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          controller.examDate.value = date;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Container(
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
                  Text(
                    controller.examDate.value == null
                        ? 'Select exam date'
                        : DateFormat(
                            'MM/dd/yyyy',
                          ).format(controller.examDate.value!),
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      color: controller.examDate.value == null
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                      fontWeight: controller.examDate.value == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                ],
              ),
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

  Widget _buildSaveButton(ExamController controller) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          label: controller.isEditing ? 'Save Changes' : 'Create Exam',
          isLoading: controller.isSaving.value,
          onPressed: () => controller.submitForm(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_add_exam_controller.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherAddExamScreen extends GetView<TeacherAddExamController> {
  const TeacherAddExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // controller.isEditing is a plain (non-.obs) getter set once in onInit —
    // read it directly here, not inside an Obx (nothing about it is reactive).
    final title = controller.isEditing ? 'Edit Exam' : 'New Exam';
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(title: title),
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
                        hint: 'e.g. Unit Test 1',
                        errorText: controller.titleError.value,
                      ),
                    ),
                    AppSpacing.v16,
                    _label('Subject (optional)'),
                    _field(controller: controller.subjectController, hint: 'e.g. Mathematics'),
                    AppSpacing.v16,
                    _label('Exam Type'),
                    Obx(
                      () => Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: TeacherAddExamController.examTypes.map((type) {
                          final isSelected = controller.examType.value == type;
                          return GestureDetector(
                            onTap: () => controller.selectExamType(type),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryBrand : AppColors.fieldBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryBrand : AppColors.fieldBorder,
                                ),
                              ),
                              child: Text(
                                type.replaceAll('_', ' '),
                                style: AppTextStyles.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    AppSpacing.v16,
                    _label('Exam Date'),
                    Obx(
                      () => GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: controller.examDate.value ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                          );
                          if (picked != null) controller.pickExamDate(picked);
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
                                controller.examDate.value != null
                                    ? DateFormat('dd MMM, yyyy').format(controller.examDate.value!)
                                    : 'Select exam date',
                                style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.v16,
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Total Marks'),
                              Obx(
                                () => _field(
                                  controller: controller.totalMarksController,
                                  hint: '100',
                                  keyboardType: TextInputType.number,
                                  errorText: controller.totalMarksError.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.h12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Passing Marks'),
                              Obx(
                                () => _field(
                                  controller: controller.passingMarksController,
                                  hint: '35',
                                  keyboardType: TextInputType.number,
                                  errorText: controller.passingMarksError.value,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.v16,
                    _label('Description (optional)'),
                    _field(
                      controller: controller.descriptionController,
                      hint: 'Syllabus, instructions, etc.',
                      maxLines: 3,
                    ),
                    AppSpacing.v32,
                    Obx(
                      () => AppButton(
                        label: controller.isEditing ? 'Save Changes' : 'Create Exam',
                        onPressed: controller.submit,
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
    TextInputType? keyboardType,
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
            keyboardType: keyboardType,
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

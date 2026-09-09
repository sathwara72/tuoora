import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_exam_marks_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_exam_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherExamMarksScreen extends GetView<TeacherExamMarksController> {
  const TeacherExamMarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(title: 'Marks · ${controller.exam.title}'),
            Expanded(
              child: Obx(() {
                // Real reactive reads (isLoading, rows.isEmpty/length) — this
                // Obx rebuilds the whole list whenever rows.refresh() fires,
                // so individual rows below don't need their own Obx wrapper.
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.rows.isEmpty) {
                  return Center(
                    child: Text(
                      'No students in this batch.',
                      style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.x16,
                  itemCount: controller.rows.length,
                  separatorBuilder: (_, __) => AppSpacing.v12,
                  itemBuilder: (context, index) =>
                      _MarkRow(row: controller.rows[index], controller: controller),
                );
              }),
            ),
            Padding(
              padding: AppSpacing.x16.add(const EdgeInsets.only(bottom: AppSpacing.s16)),
              child: Obx(
                () => AppButton(
                  label: 'Save Marks',
                  onPressed: controller.submit,
                  isLoading: controller.isSaving.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkRow extends StatelessWidget {
  final TeacherExamMarkRow row;
  final TeacherExamMarksController controller;

  const _MarkRow({required this.row, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.studentName,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (row.enrollmentId != null)
                      Text(
                        row.enrollmentId!,
                        style: AppTextStyles.outfit(fontSize: 11, color: AppColors.textTertiary),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.toggleAbsent(row),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: row.isAbsent
                        ? AppColors.bohoRed.withValues(alpha: 0.12)
                        : AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: row.isAbsent ? AppColors.bohoRed : AppColors.fieldBorder,
                    ),
                  ),
                  child: Text(
                    'Absent',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: row.isAbsent ? AppColors.bohoRed : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!row.isAbsent) ...[
            AppSpacing.v12,
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    key: ValueKey('marks-${row.studentId}-${row.isAbsent}'),
                    initialValue: row.marksObtained?.toString() ?? '',
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.outfit(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Marks',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      filled: true,
                      fillColor: AppColors.fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.fieldBorder),
                      ),
                    ),
                    onChanged: (value) => controller.updateMarks(row, value),
                  ),
                ),
                AppSpacing.h12,
                Expanded(
                  child: TextFormField(
                    initialValue: row.remarks ?? '',
                    style: AppTextStyles.outfit(fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Remarks (optional)',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      filled: true,
                      fillColor: AppColors.fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.fieldBorder),
                      ),
                    ),
                    onChanged: (value) => controller.updateRemarks(row, value),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

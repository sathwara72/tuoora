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
            _buildExamInfoCard(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.rows.isEmpty) {
                  return Center(
                    child: Text(
                      'No students in this batch.',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.x16.add(
                    const EdgeInsets.only(top: AppSpacing.s8, bottom: AppSpacing.s16),
                  ),
                  itemCount: controller.rows.length,
                  separatorBuilder: (_, _) => AppSpacing.v12,
                  itemBuilder: (context, index) => _MarkRow(
                    row: controller.rows[index],
                    controller: controller,
                  ),
                );
              }),
            ),
            Padding(
              padding: AppSpacing.x16.add(
                const EdgeInsets.only(bottom: AppSpacing.s16, top: AppSpacing.s8),
              ),
              child: Obx(
                () => AppButton(
                  label:
                      'Save Marks (${controller.enteredCount}/${controller.totalStudents})',
                  icon: Icons.save_rounded,
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

  Widget _buildExamInfoCard() {
    return Padding(
      padding: AppSpacing.x16.add(const EdgeInsets.only(bottom: AppSpacing.s8)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: AppColors.primaryBrand,
                    size: 18,
                  ),
                ),
                AppSpacing.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.exam.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Total: ${controller.exam.totalMarks.toInt()} marks · Pass: ${controller.exam.passingMarks.toInt()} marks',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.v8,
            const Divider(height: 1, color: AppColors.borderGrey),
            AppSpacing.v8,
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Total', '${controller.totalStudents}', AppColors.textSecondary),
                  _statItem('Present', '${controller.presentCount}', AppColors.primaryBrand),
                  _statItem('Absent', '${controller.absentCount}', AppColors.bohoRed),
                  _statItem('Entered', '${controller.enteredCount}', Colors.amber.shade800),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.outfit(
            fontSize: 11,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MarkRow extends StatelessWidget {
  final TeacherExamMarkRow row;
  final TeacherExamMarksController controller;

  const _MarkRow({required this.row, required this.controller});

  @override
  Widget build(BuildContext context) {
    final maxMarks = controller.exam.totalMarks;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: row.isAbsent
              ? AppColors.bohoRed.withValues(alpha: 0.3)
              : AppColors.borderGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Header & Absent Toggle
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: row.isAbsent
                      ? AppColors.bohoRed.withValues(alpha: 0.1)
                      : AppColors.primaryBrand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    row.studentName.isNotEmpty
                        ? row.studentName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: row.isAbsent
                          ? AppColors.bohoRed
                          : AppColors.primaryBrand,
                    ),
                  ),
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (row.enrollmentId != null &&
                        row.enrollmentId!.isNotEmpty)
                      Text(
                        row.enrollmentId!,
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              // Absent Switch Toggle
              InkWell(
                onTap: () => controller.toggleAbsent(row),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: row.isAbsent
                        ? AppColors.bohoRed
                        : AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: row.isAbsent
                          ? AppColors.bohoRed
                          : AppColors.fieldBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        row.isAbsent
                            ? Icons.person_off_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 14,
                        color: row.isAbsent
                            ? AppColors.white
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        row.isAbsent ? 'Absent' : 'Present',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: row.isAbsent
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v12,

          // Marks Input Row (or Absent Notice) & Remarks
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Marks field
              if (row.isAbsent)
                Container(
                  width: 100,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.bohoRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.bohoRed.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    'ABSENT',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bohoRed,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    key: ValueKey('marks-${row.studentId}-${row.isAbsent}'),
                    initialValue: row.marksObtained != null
                        ? (row.marksObtained == row.marksObtained!.roundToDouble()
                            ? row.marksObtained!.toInt().toString()
                            : row.marksObtained.toString())
                        : '',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Max ${maxMarks.toInt()}',
                      hintStyle: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.fieldLabel,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 11,
                      ),
                      filled: true,
                      fillColor: AppColors.fieldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.fieldBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.fieldBorder),
                      ),
                    ),
                    onChanged: (value) => controller.updateMarks(row, value),
                  ),
                ),
              AppSpacing.h10,

              // Remarks field (ALWAYS visible and editable, for both present and absent students)
              Expanded(
                child: TextFormField(
                  initialValue: row.remarks ?? '',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: row.isAbsent
                        ? 'Absent reason (optional)'
                        : 'Remarks (optional)',
                    hintStyle: AppTextStyles.outfit(
                      fontSize: 12,
                      color: AppColors.fieldLabel,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 11,
                    ),
                    filled: true,
                    fillColor: AppColors.fieldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.fieldBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
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
      ),
    );
  }
}

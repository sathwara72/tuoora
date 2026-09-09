import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_mark_attendance_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_attendance_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherMarkAttendanceScreen extends GetView<TeacherMarkAttendanceController> {
  const TeacherMarkAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            TeacherAppBar(title: 'Attendance · ${controller.batch.name}'),
            _buildDateBar(context),
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
                  padding: AppSpacing.x16,
                  itemCount: controller.rows.length,
                  separatorBuilder: (_, __) => AppSpacing.v12,
                  itemBuilder: (context, index) =>
                      _StudentRow(row: controller.rows[index], controller: controller),
                );
              }),
            ),
            Obx(
              () => controller.isToday
                  ? Padding(
                      padding: AppSpacing.x16.add(
                        const EdgeInsets.only(bottom: AppSpacing.s16),
                      ),
                      child: AppButton(
                        label: 'Save Attendance',
                        onPressed: controller.submit,
                        isLoading: controller.isSubmitting.value,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBar(BuildContext context) {
    return Padding(
      padding: AppSpacing.x16,
      child: Obx(
        () => GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: controller.selectedDate.value,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
            );
            if (picked != null) controller.pickDate(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.primaryBrand,
                ),
                AppSpacing.h8,
                Text(
                  controller.displayDate,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!controller.isToday) ...[
                  AppSpacing.h8,
                  Text(
                    '(read-only)',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final TeacherAttendanceRow row;
  final TeacherMarkAttendanceController controller;

  const _StudentRow({required this.row, required this.controller});

  @override
  Widget build(BuildContext context) {
    // No Obx here: this widget is rebuilt by the parent list's Obx (which
    // tracks controller.rows) whenever setStatus() calls rows.refresh().
    return Container(
      padding: AppSpacing.all16,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
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
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          _statusChip('present', Icons.check_circle_rounded, AppColors.primaryBrand),
          AppSpacing.h8,
          _statusChip('absent', Icons.cancel_rounded, AppColors.bohoRed),
          AppSpacing.h8,
          _statusChip('late', Icons.schedule_rounded, Colors.amber.shade700),
        ],
      ),
    );
  }

  Widget _statusChip(String status, IconData icon, Color color) {
    final isSelected = row.status == status;
    return GestureDetector(
      onTap: controller.isToday ? () => controller.setStatus(row, status) : null,
      child: Container(
        width: AppSpacing.s36,
        height: AppSpacing.s36,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : AppColors.fieldBorder),
        ),
        child: Icon(icon, size: 18, color: isSelected ? color : AppColors.textTertiary),
      ),
    );
  }
}

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

class TeacherMarkAttendanceScreen
    extends GetView<TeacherMarkAttendanceController> {
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
            Obx(() {
              if (controller.isLoading.value || controller.rows.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildToolbar(context);
            }),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CommonLoading());
                }
                if (controller.rows.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 48,
                          color: AppColors.textTertiary.withValues(alpha: 0.5),
                        ),
                        AppSpacing.v12,
                        Text(
                          'No students enrolled in this batch.',
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: AppSpacing.x16.add(
                    const EdgeInsets.only(top: AppSpacing.s8, bottom: AppSpacing.s16),
                  ),
                  itemCount: controller.rows.length,
                  separatorBuilder: (_, _) => AppSpacing.v12,
                  itemBuilder: (context, index) => _StudentRow(
                    row: controller.rows[index],
                    controller: controller,
                  ),
                );
              }),
            ),
            Obx(() {
              if (!controller.isEditable || controller.rows.isEmpty) {
                return const SizedBox.shrink();
              }
              final marked =
                  controller.totalCount - controller.unmarkedCount;
              return Container(
                padding: AppSpacing.all16,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: AppButton(
                  label:
                      'Save Attendance ($marked/${controller.totalCount})',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: controller.submit,
                  isLoading: controller.isSubmitting.value,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) controller.pickDate(picked);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: controller.isToday
                              ? AppColors.primaryBrand.withValues(alpha: 0.1)
                              : AppColors.fieldBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          controller.isToday ? 'Today' : 'Change date',
                          style: AppTextStyles.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: controller.isToday
                                ? AppColors.primaryBrand
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Counters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _counterBadge('Total', '${controller.totalCount}', AppColors.textSecondary),
                _counterBadge('Present', '${controller.presentCount}', AppColors.primaryBrand),
                _counterBadge('Absent', '${controller.absentCount}', AppColors.bohoRed),
                if (controller.unmarkedCount > 0)
                  _counterBadge('Unmarked', '${controller.unmarkedCount}', Colors.grey.shade600),
              ],
            ),
            if (controller.isEditable) ...[
              AppSpacing.v12,
              Row(
                children: [
                  // Single-tap "Mark All Present" Button
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: controller.markAllPresent,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrand,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBrand.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.done_all_rounded,
                              color: AppColors.white,
                              size: 18,
                            ),
                            AppSpacing.h8,
                            Text(
                              'Mark All Present',
                              style: AppTextStyles.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.h8,
                  // Quick "Mark All Absent" button
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () => controller.markAll('absent'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.bohoRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.bohoRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.close_rounded,
                              color: AppColors.bohoRed,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'All Absent',
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.bohoRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _counterBadge(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: AppTextStyles.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 11,
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StudentRow extends StatelessWidget {
  final TeacherAttendanceRow row;
  final TeacherMarkAttendanceController controller;

  const _StudentRow({required this.row, required this.controller});

  @override
  Widget build(BuildContext context) {
    final status = row.status?.toLowerCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: status == 'present'
              ? AppColors.primaryBrand.withValues(alpha: 0.3)
              : status == 'absent'
                  ? AppColors.bohoRed.withValues(alpha: 0.3)
                  : AppColors.borderGrey,
        ),
      ),
      child: Row(
        children: [
          // Student Avatar / Initial
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _avatarBgColor(status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                row.studentName.isNotEmpty
                    ? row.studentName[0].toUpperCase()
                    : '?',
                style: AppTextStyles.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _avatarTextColor(status),
                ),
              ),
            ),
          ),
          AppSpacing.h12,

          // Name and ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (row.enrollmentId != null && row.enrollmentId!.isNotEmpty)
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
          AppSpacing.h8,

          // Quick Toggles: Present, Absent
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _quickToggle(
                statusKey: 'present',
                label: 'P',
                icon: Icons.check_rounded,
                activeColor: AppColors.primaryBrand,
                currentStatus: status,
              ),
              const SizedBox(width: 8),
              _quickToggle(
                statusKey: 'absent',
                label: 'A',
                icon: Icons.close_rounded,
                activeColor: AppColors.bohoRed,
                currentStatus: status,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _avatarBgColor(String? status) {
    switch (status) {
      case 'present':
        return AppColors.primaryBrand.withValues(alpha: 0.1);
      case 'absent':
        return AppColors.bohoRed.withValues(alpha: 0.1);
      default:
        return AppColors.fieldBg;
    }
  }

  Color _avatarTextColor(String? status) {
    switch (status) {
      case 'present':
        return AppColors.primaryBrand;
      case 'absent':
        return AppColors.bohoRed;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _quickToggle({
    required String statusKey,
    required String label,
    required IconData icon,
    required Color activeColor,
    required String? currentStatus,
  }) {
    final isSelected = currentStatus == statusKey;

    return InkWell(
      onTap: controller.isEditable
          ? () => controller.setStatus(row, statusKey)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.fieldBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.white : AppColors.textTertiary,
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.white : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

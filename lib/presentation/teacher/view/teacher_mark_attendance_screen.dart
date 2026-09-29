import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
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
            TeacherAppBar(title: 'Attendance • ${controller.batch.name}'),
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
                final displayedRows = controller.filteredRows;
                if (displayedRows.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 44,
                          color: AppColors.textTertiary.withValues(alpha: 0.5),
                        ),
                        AppSpacing.v12,
                        Text(
                          'No matching students found.',
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
                    const EdgeInsets.only(
                      top: AppSpacing.s8,
                      bottom: AppSpacing.s16,
                    ),
                  ),
                  itemCount: displayedRows.length,
                  separatorBuilder: (_, _) => AppSpacing.v12,
                  itemBuilder: (context, index) => _StudentRow(
                    row: displayedRows[index],
                    controller: controller,
                  ),
                );
              }),
            ),
            Obx(() {
              if (!controller.isEditable || controller.rows.isEmpty) {
                return const SizedBox.shrink();
              }
              final marked = controller.totalCount - controller.unmarkedCount;
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
                  label: 'Save Attendance ($marked/${controller.totalCount})',
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

  Future<void> _scanQr(BuildContext context) async {
    final scanned = await Get.toNamed(AppRoutes.teacherAttendanceQrScan);
    if (scanned is String && scanned.isNotEmpty) {
      await controller.markByQr(scanned);
    }
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
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) controller.pickDate(picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scan sits on top, above the counters card.
        if (controller.isEditable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _scanButton(context),
          ),
        Padding(
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
                // Filter Counters
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _counterBadge(
                        'All',
                        '${controller.totalCount}',
                        AppColors.textSecondary,
                        isSelected: controller.filterStatus.value == 'all',
                        onTap: () => controller.filterStatus.value = 'all',
                      ),
                      _counterBadge(
                        'Present',
                        '${controller.presentCount}',
                        AppColors.successGreen,
                        isSelected: controller.filterStatus.value == 'present',
                        onTap: () => controller.filterStatus.value = 'present',
                      ),
                      _counterBadge(
                        'Absent',
                        '${controller.absentCount}',
                        AppColors.errorRed,
                        isSelected: controller.filterStatus.value == 'absent',
                        onTap: () => controller.filterStatus.value = 'absent',
                      ),
                      if (controller.unmarkedCount > 0)
                        _counterBadge(
                          'Unmarked',
                          '${controller.unmarkedCount}',
                          Colors.grey.shade600,
                          isSelected: false,
                          onTap: null,
                        ),
                    ],
                  ),
                ),
                if (controller.isEditable) ...[
                  AppSpacing.v12,
                  Row(
                    children: [
                      Expanded(
                        child: _bulkButton(
                          label: 'Mark All Present',
                          color: AppColors.successGreen,
                          filled: true,
                          onTap: controller.markAllPresent,
                        ),
                      ),
                      AppSpacing.h8,
                      Expanded(
                        child: _bulkButton(
                          label: 'Mark All Absent',
                          color: AppColors.errorRed,
                          filled: false,
                          onTap: () => controller.markAll('absent'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        // Search sits below the card.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: AppSearchField(
            hintText: 'Search student by name, phone or ID...',
            onChanged: (val) => controller.searchQuery.value = val,
          ),
        ),
      ],
    );
  }

  Widget _scanButton(BuildContext context) {
    return InkWell(
      onTap: () => _scanQr(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryBrand.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primaryBrand.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.primaryBrand,
              size: 20,
            ),
            AppSpacing.h8,
            Text(
              'Scan Student ID (QR / Barcode)',
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBrand,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bulkButton({
    required String label,
    required Color color,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: filled ? AppColors.white : color,
          ),
        ),
      ),
    );
  }

  Widget _counterBadge(
    String label,
    String count,
    Color color, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.4), width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
        ),
        child: Column(
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
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textTertiary,
              ),
            ),
          ],
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
    final status = row.status?.toLowerCase();
    final isAbsent = status == 'absent';
    final isPresent = status == 'present';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isPresent
              ? AppColors.successGreen.withValues(alpha: 0.35)
              : isAbsent
              ? AppColors.errorRed.withValues(alpha: 0.4)
              : AppColors.borderGrey,
        ),
      ),
      child: Row(
        children: [
          _buildAvatar(row),
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
                AppSpacing.v2,
                Text(
                  row.phone != null && row.phone!.trim().isNotEmpty
                      ? row.phone!.trim()
                      : (row.enrollmentId != null &&
                                row.enrollmentId!.isNotEmpty
                            ? row.enrollmentId!
                            : 'No mobile'),
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (row.monthlyAbsentDates.isNotEmpty) ...[
                  AppSpacing.v4,
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: row.monthlyAbsentDates
                        .map(
                          (dateStr) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              dateStr,
                              style: AppTextStyles.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.h8,
          _quickToggle(
            statusKey: 'present',
            label: 'P',
            activeColor: AppColors.successGreen,
            currentStatus: status,
          ),
          const SizedBox(width: 8),
          _quickToggle(
            statusKey: 'absent',
            label: 'A',
            activeColor: AppColors.errorRed,
            currentStatus: status,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(TeacherAttendanceRow row) {
    final status = row.status?.toLowerCase();
    final isAbsent = status == 'absent';
    final imageUrl = row.profileImageUrl;

    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith('http') &&
        !imageUrl.contains('ui-avatars.com')) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isAbsent
              ? AppColors.errorRed.withValues(alpha: 0.1)
              : AppColors.primaryBrandLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isAbsent
                ? AppColors.errorRed.withValues(alpha: 0.35)
                : AppColors.borderGrey,
            width: 1.2,
          ),
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final initials = row.studentName.isNotEmpty
        ? row.studentName[0].toUpperCase()
        : '?';

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isAbsent
            ? AppColors.errorRed.withValues(alpha: 0.1)
            : (status == 'present'
                  ? AppColors.successGreen.withValues(alpha: 0.12)
                  : AppColors.fieldBg),
        shape: BoxShape.circle,
        border: Border.all(
          color: isAbsent
              ? AppColors.errorRed.withValues(alpha: 0.35)
              : AppColors.borderGrey,
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isAbsent
                ? AppColors.errorRed
                : (status == 'present'
                      ? AppColors.successGreen
                      : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _quickToggle({
    required String statusKey,
    required String label,
    required Color activeColor,
    required String? currentStatus,
  }) {
    final isSelected = currentStatus == statusKey;

    return InkWell(
      onTap: controller.isEditable
          ? () => controller.setStatus(row, statusKey)
          : null,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : activeColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor
                : activeColor.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isSelected ? AppColors.white : activeColor,
          ),
        ),
      ),
    );
  }
}

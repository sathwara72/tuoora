import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/presentation/institute/controllers/staff_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/core/widgets/input_styles.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LogAttendanceScreen extends GetView<StaffController> {
  const LogAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: AppStrings.addAttendance),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.all16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InstituteLabel('Select Member'),
                    _buildStaffDropdown(),
                    AppSpacing.v20,
                    Obx(
                      () => AppInputField(
                        label: AppStrings.labelDate,
                        hint: 'MM/dd/yyyy',
                        icon: Icons.calendar_today_rounded,
                        controller: TextEditingController(
                          text: DateFormat(
                            'MM/dd/yyyy',
                          ).format(controller.selectedLogDate.value),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final picked = await AppPickers.date(
                            context,
                            initialDate: controller.selectedLogDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            controller.selectLogDate(picked);
                          }
                        },
                      ),
                    ),
                    AppSpacing.v24,
                    const InstituteLabel('Attendance Status'),
                    _buildStatusToggle(),
                    Obx(
                      () => controller.isPresent.value
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppSpacing.v24,
                                AppInputField(
                                  label: AppStrings.absentReason,
                                  controller: controller.logNotesController,
                                  hint: AppStrings.enterReason,
                                  maxLines: 4,
                                ),
                              ],
                            ),
                    ),
                    AppSpacing.v32,
                    _buildLogButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffDropdown() {
    return Obx(() {
      final selectedId = controller.selectedLogStaff.value?.id;
      final isValueInList = controller.allStaff.any((s) => s.id == selectedId);
      final isStaffEmpty = controller.allStaff.isEmpty;
      return Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(InputStyles.borderRadius),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: isValueInList ? selectedId : null,
            isExpanded: true,
            hint: Text(
              controller.isLoadingAllStaff.value && isStaffEmpty
                  ? 'Loading staff...'
                  : 'Select Staff',
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.fieldLabel,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.fieldLabel,
            ),
            style: AppTextStyles.outfit(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: AppColors.white,
            items: controller.allStaff
                .map(
                  (staff) => DropdownMenuItem<int>(
                    value: staff.id,
                    child: Text(
                      staff.fullName,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: isStaffEmpty ? null : controller.selectLogStaffById,
          ),
        ),
      );
    });
  }

  Widget _buildStatusToggle() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.toggleStatus(true),
              child: _buildStatusButton(
                'Present',
                Icons.check_circle_rounded,
                AppColors.successGreen,
                controller.isPresent.value,
              ),
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: GestureDetector(
              onTap: () => controller.toggleStatus(false),
              child: _buildStatusButton(
                'Absent',
                Icons.cancel_rounded,
                AppColors.bohoRed,
                !controller.isPresent.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.05) : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isSelected ? color : AppColors.background,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? color : AppColors.textTertiary,
            size: 32,
          ),
          AppSpacing.v12,
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? color : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          onPressed: () => controller.saveAttendanceRecord(),
          label: AppStrings.logAttendance,
          icon: Icons.check_circle_outline_rounded,
          isLoading: controller.isSaving.value,
        ),
      ),
    );
  }

  String getInitials(String name) {
    if (name.isEmpty) return 'ST';
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 1 ? 2 : 1;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }
}

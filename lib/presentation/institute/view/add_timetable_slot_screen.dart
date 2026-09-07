import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/presentation/institute/controllers/timetable_controller.dart';
import 'package:tuoora/presentation/institute/models/timetable_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTimetableSlotScreen extends StatelessWidget {
  const AddTimetableSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String batchId = Get.arguments as String;
    final controller = Get.find<TimetableController>(tag: batchId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: controller.isEditing ? 'Edit Schedule' : 'Add Schedule',
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
                        label: 'SUBJECT',
                        controller: controller.subjectController,
                        hint: 'e.g. Accounting',
                        errorText: controller.subjectError.value,
                      ),
                    ),
                    AppSpacing.v24,
                    const InstituteLabel('DAY'),
                    AppSpacing.v8,
                    _buildDayChips(controller),
                    AppSpacing.v24,
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeField(
                            context,
                            controller,
                            label: 'START TIME',
                            isStart: true,
                          ),
                        ),
                        AppSpacing.h16,
                        Expanded(
                          child: _buildTimeField(
                            context,
                            controller,
                            label: 'END TIME',
                            isStart: false,
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.timeError.value == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          controller.timeError.value!,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                    AppSpacing.v24,
                    const InstituteLabel('ASSIGN STAFF (OPTIONAL)'),
                    AppSpacing.v8,
                    _buildStaffDropdown(controller),
                    AppSpacing.v24,
                    AppInputField(
                      label: 'ROOM / CLASSROOM (OPTIONAL)',
                      controller: controller.roomNoController,
                      hint: 'e.g. A-2',
                    ),
                    AppSpacing.v24,
                    AppInputField(
                      label: 'DESCRIPTION (OPTIONAL)',
                      controller: controller.descriptionController,
                      hint: 'Notes for this lecture slot',
                      maxLines: 3,
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

  Widget _buildDayChips(TimetableController controller) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: DayOfWeek.values.map((day) {
          final isSelected = controller.formDay.value == day;
          return GestureDetector(
            onTap: () => controller.formDay.value = day,
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
                DayOfWeek.labelFor(day),
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

  Widget _buildTimeField(
    BuildContext context,
    TimetableController controller, {
    required String label,
    required bool isStart,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InstituteLabel(label),
        AppSpacing.v8,
        GestureDetector(
          onTap: () async {
            final current = isStart
                ? controller.startTime.value
                : controller.endTime.value;
            final picked = await AppPickers.time(
              context,
              initialTime: current ?? TimeOfDay.now(),
            );
            if (picked != null) {
              if (isStart) {
                controller.startTime.value = picked;
              } else {
                controller.endTime.value = picked;
              }
            }
          },
          child: Obx(() {
            final value = isStart
                ? controller.startTime.value
                : controller.endTime.value;
            return Container(
              padding: AppSpacing.all16,
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  AppSpacing.h8,
                  Expanded(
                    child: Text(
                      value == null
                          ? '--:--'
                          : value.format(context),
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: value == null
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        fontWeight: value == null
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStaffDropdown(TimetableController controller) {
    return Obx(() {
      final isValueInList = controller.staffList.any(
        (s) => s.id == controller.selectedStaffId.value,
      );
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            isExpanded: true,
            value: isValueInList ? controller.selectedStaffId.value : null,
            hint: Text(
              controller.isLoadingStaff.value
                  ? 'Loading staff…'
                  : 'No staff assigned',
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(
                  'None',
                  style: AppTextStyles.outfit(fontSize: 14),
                ),
              ),
              ...controller.staffList.map(
                (staff) => DropdownMenuItem<int?>(
                  value: staff.id,
                  child: Text(
                    staff.fullName,
                    style: AppTextStyles.outfit(fontSize: 14),
                  ),
                ),
              ),
            ],
            onChanged: controller.isLoadingStaff.value
                ? null
                : controller.selectStaff,
          ),
        ),
      );
    });
  }

  Widget _buildSaveButton(TimetableController controller) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          label: controller.isEditing ? 'Save Changes' : 'Add Schedule',
          isLoading: controller.isSaving.value,
          onPressed: () => controller.submitForm(),
        ),
      ),
    );
  }
}

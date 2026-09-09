import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_add_timetable_slot_controller.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_batch_timetable_controller.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';

class TeacherAddTimetableSlotScreen extends GetView<TeacherAddTimetableSlotController> {
  const TeacherAddTimetableSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final title = controller.isEditing ? 'Edit Lecture Slot' : 'New Lecture Slot';
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
                    _label('Subject'),
                    Obx(
                      () => _field(
                        controller: controller.subjectController,
                        hint: 'e.g. Physics',
                        errorText: controller.subjectError.value,
                      ),
                    ),
                    AppSpacing.v16,
                    _label('Day'),
                    Obx(
                      () => Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: TeacherBatchTimetableController.days.map((day) {
                          final isSelected = controller.dayOfWeek.value == day;
                          return GestureDetector(
                            onTap: () => controller.selectDay(day),
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
                                day.substring(0, 3).toUpperCase(),
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Start Time'),
                              Obx(
                                () => _timeField(
                                  context: context,
                                  time: controller.startTime.value,
                                  onPick: controller.pickStartTime,
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
                              _label('End Time'),
                              Obx(
                                () => _timeField(
                                  context: context,
                                  time: controller.endTime.value,
                                  onPick: controller.pickEndTime,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => controller.timeError.value != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 6, left: 4),
                              child: Text(
                                controller.timeError.value!,
                                style: AppTextStyles.outfit(fontSize: 12, color: Colors.redAccent),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    AppSpacing.v16,
                    _label('Room (optional)'),
                    _field(controller: controller.roomController, hint: 'e.g. 204'),
                    AppSpacing.v16,
                    _label('Description (optional)'),
                    _field(controller: controller.descriptionController, hint: 'Notes', maxLines: 3),
                    AppSpacing.v32,
                    Obx(
                      () => AppButton(
                        label: controller.isEditing ? 'Save Changes' : 'Add Slot',
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

  Widget _timeField({
    required BuildContext context,
    required TimeOfDay? time,
    required ValueChanged<TimeOfDay> onPick,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryBrand),
            AppSpacing.h8,
            Text(
              time != null ? time.format(context) : 'Select',
              style: AppTextStyles.outfit(fontSize: 14, color: AppColors.textPrimary),
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

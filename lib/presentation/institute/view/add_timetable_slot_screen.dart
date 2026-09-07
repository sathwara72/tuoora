import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/presentation/institute/controllers/timetable_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/timetable_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';

class AddTimetableSlotScreen extends StatefulWidget {
  const AddTimetableSlotScreen({super.key});

  @override
  State<AddTimetableSlotScreen> createState() => _AddTimetableSlotScreenState();
}

class _AddTimetableSlotScreenState extends State<AddTimetableSlotScreen> {
  late final TimetableController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<TimetableController>()) {
      controller = Get.find<TimetableController>();
    } else {
      controller = Get.put(TimetableController());
    }

    final args = Get.arguments;
    if (args is BatchModel) {
      if (!controller.isEditing) {
        controller.startCreate(args);
      }
    } else if (args is String) {
      if (!controller.isEditing) {
        controller.selectFormBatch(args);
      }
    } else if (args is Map) {
      if (args['slot'] is TimetableSlot) {
        controller.startEdit(args['slot'] as TimetableSlot);
      } else if (args['batch'] is BatchModel && !controller.isEditing) {
        controller.startCreate(args['batch'] as BatchModel);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: controller.isEditing ? 'Edit Class Schedule' : 'Add Class Schedule',
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.x16.add(AppSpacing.y16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Batch Dropdown
                    const InstituteLabel('SELECT BATCH *'),
                    AppSpacing.v8,
                    _buildBatchDropdown(),
                    Obx(() {
                      if (controller.batchError.value == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                        child: Text(
                          controller.batchError.value!,
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                    AppSpacing.v20,

                    // 2. Class / Subject Dropdown (if batch has classes)
                    _buildClassDropdown(),

                    // 3. Subject Name Input
                    Obx(
                      () => AppInputField(
                        label: 'SUBJECT NAME *',
                        controller: controller.subjectController,
                        hint: 'e.g. Mathematics, Physics, Accounts',
                        errorText: controller.subjectError.value,
                      ),
                    ),
                    AppSpacing.v20,

                    // 4. Day Dropdown
                    const InstituteLabel('DAY *'),
                    AppSpacing.v8,
                    _buildDayDropdown(),
                    AppSpacing.v20,

                    // 5. Start and End Time
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeField(
                            context,
                            label: 'START TIME *',
                            isStart: true,
                          ),
                        ),
                        AppSpacing.h16,
                        Expanded(
                          child: _buildTimeField(
                            context,
                            label: 'END TIME *',
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
                        padding: const EdgeInsets.only(top: 6.0, left: 4.0),
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
                    AppSpacing.v20,

                    // 6. Assign Faculty / Staff
                    const InstituteLabel('ASSIGN FACULTY / TEACHER'),
                    AppSpacing.v8,
                    _buildStaffDropdown(),
                    AppSpacing.v20,

                    // 7. Room / Classroom
                    AppInputField(
                      label: 'ROOM / CLASSROOM (OPTIONAL)',
                      controller: controller.roomNoController,
                      hint: 'e.g. Room 102, Lab A',
                    ),
                    AppSpacing.v20,

                    // 8. Description / Notes
                    AppInputField(
                      label: 'DESCRIPTION (OPTIONAL)',
                      controller: controller.descriptionController,
                      hint: 'Special notes, chapter info, or instructions',
                      maxLines: 3,
                    ),
                    AppSpacing.v32,

                    // 9. Save Button
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchDropdown() {
    return Obx(() {
      final selectedId = controller.selectedFormBatchId.value;
      final batches = controller.batchesList;
      final isValueInList = batches.any((b) => b.id == selectedId);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.batchError.value != null
                ? Colors.redAccent
                : AppColors.primaryBrand,
            width: 1.5,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            isExpanded: true,
            value: isValueInList ? selectedId : null,
            hint: Text(
              controller.isLoadingBatches.value
                  ? 'Loading batches...'
                  : 'Select Batch',
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryBrand,
            ),
            items: batches.map((batch) {
              return DropdownMenuItem<String?>(
                value: batch.id,
                child: Text(
                  batch.title,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (newBatchId) {
              controller.selectFormBatch(newBatchId);
            },
          ),
        ),
      );
    });
  }

  Widget _buildClassDropdown() {
    return Obx(() {
      if (controller.isLoadingClasses.value) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBrand,
                ),
              ),
              AppSpacing.h8,
              Text(
                'Loading batch classes...',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }

      if (controller.batchClasses.isEmpty) {
        return const SizedBox.shrink();
      }

      final selectedClassId = controller.selectedClassId.value;
      final isClassInList = controller.batchClasses.any(
        (c) => c.id.toString() == selectedClassId,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const InstituteLabel('SELECT CLASS / SUBJECT'),
              AppSpacing.h6,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrandLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Auto-fill',
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBrand.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: isClassInList ? selectedClassId : null,
                hint: Text(
                  'Select from batch classes (or type below)',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primaryBrand,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'Custom / Other Subject',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                  ),
                  ...controller.batchClasses.map((cls) {
                    final teacherInfo = cls.teachers.isNotEmpty
                        ? ' · ${cls.teachers.first.fullName}'
                        : '';
                    return DropdownMenuItem<String?>(
                      value: cls.id.toString(),
                      child: Text(
                        '${cls.name}$teacherInfo',
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (classId) {
                  controller.selectClass(classId);
                },
              ),
            ),
          ),
          AppSpacing.v20,
        ],
      );
    });
  }

  Widget _buildDayDropdown() {
    return Obx(() {
      final available = controller.availableDays;
      final currentDay = controller.formDay.value.toLowerCase();
      final days = {currentDay, ...available.map((d) => d.toLowerCase())}.toList();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryBrand, width: 1.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: days.contains(currentDay) ? currentDay : days.first,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryBrand,
            ),
            items: days.map((day) {
              return DropdownMenuItem<String>(
                value: day,
                child: Text(
                  DayOfWeek.labelFor(day),
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (day) {
              if (day != null) controller.formDay.value = day;
            },
          ),
        ),
      );
    });
  }

  Widget _buildTimeField(
    BuildContext context, {
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
                    size: 18,
                  ),
                  AppSpacing.h8,
                  Expanded(
                    child: Text(
                      value == null ? '--:--' : value.format(context),
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

  Widget _buildStaffDropdown() {
    return Obx(() {
      final selectedId = controller.selectedStaffId.value;
      final staffList = controller.staffList;
      final isValueInList = staffList.any((s) => s.id == selectedId);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            isExpanded: true,
            value: isValueInList ? selectedId : null,
            hint: Text(
              controller.isLoadingStaff.value
                  ? 'Loading staff…'
                  : 'No faculty assigned (Optional)',
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(
                  'None (Unassigned)',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              ...staffList.map(
                (staff) => DropdownMenuItem<int?>(
                  value: staff.id,
                  child: Text(
                    staff.fullName,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildSaveButton() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          label: controller.isEditing ? 'Save Changes' : 'Add Class Schedule',
          isLoading: controller.isSaving.value,
          onPressed: () => controller.submitForm(),
        ),
      ),
    );
  }
}

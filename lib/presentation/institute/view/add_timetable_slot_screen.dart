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
        controller.startCreate(args, true);
      }
    } else if (args is String) {
      if (!controller.isEditing) {
        controller.selectFormBatch(args);
      }
    } else if (args is Map) {
      if (args['slot'] is TimetableSlot) {
        controller.startEdit(
          args['slot'] as TimetableSlot,
          isLocked: args['batch'] != null,
        );
      } else if (args['batch'] is BatchModel && !controller.isEditing) {
        controller.startCreate(args['batch'] as BatchModel, true);
      }
    } else {
      if (!controller.isEditing) {
        controller.startCreate(null, false);
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

                    // 2. Class / Subject Section (Direct class selection or custom fallback)
                    _buildClassOrSubjectSection(context),

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
      final isLocked = controller.isBatchLocked.value;

      final selectedBatch = batches.firstWhereOrNull((b) => b.id == selectedId) ?? controller.currentBatch.value;
      final batchTitle = selectedBatch?.title ?? (selectedId != null ? 'Batch #$selectedId' : 'Select Batch');

      if (isLocked && selectedBatch != null) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.fieldBorder,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  batchTitle,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        );
      }

      final isValueInList = batches.any((b) => b.id == selectedId);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.batchError.value != null
                ? Colors.redAccent
                : AppColors.fieldBorder,
            width: 1.0,
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
              color: AppColors.textMuted,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'Select Batch',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              ...batches.map((batch) {
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
              }),
            ],
            onChanged: (newBatchId) {
              controller.selectFormBatch(newBatchId);
            },
          ),
        ),
      );
    });
  }

  Widget _buildClassOrSubjectSection(BuildContext context) {
    return Obx(() {
      final hasClasses = controller.batchClasses.isNotEmpty;
      final isCustom = controller.isCustomSubject.value ||
          (!hasClasses && !controller.isLoadingClasses.value);

      if (!isCustom && (hasClasses || controller.isLoadingClasses.value)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const InstituteLabel('SELECT CLASS *'),
                    if (controller.isLoadingClasses.value) ...[
                      AppSpacing.h8,
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            AppSpacing.v8,
            _buildClassDropdown(),
            if (controller.subjectError.value != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                child: Text(
                  controller.subjectError.value!,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            AppSpacing.v12,
            _buildAssignedFacultyCard(),
            AppSpacing.v20,
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasClasses) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const InstituteLabel('SUBJECT NAME *'),
                  GestureDetector(
                    onTap: () {
                      controller.isCustomSubject.value = false;
                      if (controller.batchClasses.isNotEmpty) {
                        controller.selectClass(controller.batchClasses.first.id.toString());
                      }
                    },
                    child: Text(
                      '← Select from Classes',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.v8,
            ],
            AppInputField(
              label: hasClasses ? '' : 'SUBJECT NAME *',
              controller: controller.subjectController,
              hint: 'e.g. Mathematics, Physics, Accounts',
              errorText: controller.subjectError.value,
            ),
            AppSpacing.v20,
            const InstituteLabel('ASSIGN FACULTY / TEACHER'),
            AppSpacing.v8,
            _buildStaffDropdown(),
            AppSpacing.v20,
          ],
        );
      }
    });
  }

  Widget _buildClassDropdown() {
    return Obx(() {
      final batch = controller.batchesList.firstWhereOrNull(
            (b) => b.id == controller.selectedFormBatchId.value,
          ) ??
          controller.currentBatch.value;

      final items = <DropdownMenuItem<String?>>[];

      // 1. Placeholder
      items.add(
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            '-- Select Class --',
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );

      // 2. Batch Classes
      for (final cls in controller.batchClasses) {
        final teacherInfo = cls.teachers.isNotEmpty
            ? ' (${cls.teachers.map((t) => t.fullName).join(', ')})'
            : '';
        items.add(
          DropdownMenuItem<String?>(
            value: cls.id.toString(),
            child: Text(
              cls.name.trim() + teacherInfo,
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }

      // 3. Batch Subject (if available and not duplicated)
      if (batch != null && batch.subject.trim().isNotEmpty) {
        final alreadyIn = controller.batchClasses.any(
          (c) => c.name.trim().toLowerCase() == batch.subject.trim().toLowerCase(),
        );
        if (!alreadyIn) {
          final teacherName = batch.staffName != null && batch.staffName!.trim().isNotEmpty
              ? ' (${batch.staffName!.trim()})'
              : '';
          items.add(
            DropdownMenuItem<String?>(
              value: '__batch_subject__',
              child: Text(
                batch.subject.trim() + teacherName,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }
      }

      final selectedVal = controller.selectedClassId.value;
      final isValidValue = items.any((it) => it.value == selectedVal);
      final finalValue = isValidValue ? selectedVal : null;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: controller.subjectError.value != null
                ? Colors.redAccent
                : AppColors.fieldBorder,
            width: 1.0,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            isExpanded: true,
            value: finalValue,
            hint: Text(
              '-- Select Class --',
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
            ),
            items: items,
            onChanged: (newVal) {
              controller.selectClass(newVal);
            },
          ),
        ),
      );
    });
  }

  Widget _buildAssignedFacultyCard() {
    return Obx(() {
      final selectedId = controller.selectedClassId.value;
      if (selectedId == null || selectedId.isEmpty || selectedId == '__custom__') {
        return const SizedBox.shrink();
      }

      final cls = controller.batchClasses.firstWhereOrNull(
        (c) => c.id.toString() == selectedId,
      );

      final batch = controller.batchesList.firstWhereOrNull(
            (b) => b.id == controller.selectedFormBatchId.value,
          ) ??
          controller.currentBatch.value;

      if (cls != null) {
        final teachers = cls.teachers;
        if (teachers.length == 1) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
                AppSpacing.h8,
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Assigned Faculty: ',
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            color: const Color(0xFF166534),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: teachers.first.fullName,
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            color: const Color(0xFF14532D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (teachers.length > 1) {
          final isTeacherInList = teachers.any((t) => t.id == controller.selectedStaffId.value);
          final currentTeacherId = isTeacherInList ? controller.selectedStaffId.value : teachers.first.id;

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Lecture Faculty:',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.v6,
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: currentTeacherId,
                    items: teachers.map((t) {
                      return DropdownMenuItem<int>(
                        value: t.id,
                        child: Text(
                          t.fullName,
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (id) {
                      if (id != null) controller.selectedStaffId.value = id;
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No faculty assigned to this class. Assign faculty (Optional):',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber[800],
                  ),
                ),
                AppSpacing.v6,
                _buildStaffDropdown(),
              ],
            ),
          );
        }
      }

      if (selectedId == '__batch_subject__' && batch != null) {
        final teacherName = batch.staffName?.trim();
        if (teacherName != null && teacherName.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 18,
                ),
                AppSpacing.h8,
                Expanded(
                  child: Text(
                    'Assigned Faculty: $teacherName',
                    style: AppTextStyles.outfit(
                      fontSize: 13,
                      color: const Color(0xFF14532D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }

      return const SizedBox.shrink();
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
          border: Border.all(color: AppColors.fieldBorder, width: 1.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: days.contains(currentDay) ? currentDay : days.first,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
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

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
              title: controller.isEditing ? 'Edit Subject Schedule' : 'Add Subject Schedule',
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

                    // 2. Class / Subject Section
                    _buildClassOrSubjectSection(context),

                    // 3. Day Dropdown with All Days
                    _buildDaySection(),
                    AppSpacing.v20,

                    // 4. Start and End Time
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

                    // 5. Status (Active / Cancelled)
                    const InstituteLabel('STATUS'),
                    AppSpacing.v8,
                    _buildStatusSelector(),
                    AppSpacing.v20,

                    // 6. Room / Classroom
                    AppInputField(
                      label: 'ROOM / CLASSROOM (OPTIONAL)',
                      controller: controller.roomNoController,
                      hint: 'e.g. Room 102, Lab A',
                    ),
                    AppSpacing.v20,

                    // 7. Description / Notes
                    AppInputField(
                      label: 'DESCRIPTION (OPTIONAL)',
                      controller: controller.descriptionController,
                      hint: 'Special notes, chapter info, or instructions',
                      maxLines: 3,
                    ),
                    AppSpacing.v32,

                    // 8. Save Button
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
      final batch = controller.batchesList.firstWhereOrNull(
            (b) => b.id == controller.selectedFormBatchId.value,
          ) ??
          controller.currentBatch.value;
      final hasBatch = controller.selectedFormBatchId.value != null;
      final hasClasses = controller.batchClasses.isNotEmpty;
      final hasBatchSubject = batch != null && batch.subject.trim().isNotEmpty;
      final hasAnySubject = hasClasses || hasBatchSubject;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const InstituteLabel('SELECT SUBJECT *'),
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
          if (hasBatch && !controller.isLoadingClasses.value && !hasAnySubject) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 4.0),
              child: Text(
                'No subjects found for this batch.',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: const Color(0xFFD97706),
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
            '-- Select Subject --',
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

      // 4. Existing Subject if editing
      if (controller.isEditing && controller.selectedClassId.value == '__existing__') {
        items.add(
          DropdownMenuItem<String?>(
            value: '__existing__',
            child: Text(
              controller.subjectController.text,
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
              '-- Select Subject --',
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

  Widget _buildDaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const InstituteLabel('DAY *'),
            if (!controller.isEditing)
              Obx(
                () => GestureDetector(
                  onTap: () => controller.toggleAllDays(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 18,
                        width: 18,
                        child: Checkbox(
                          value: controller.isAllDays.value,
                          onChanged: (val) => controller.toggleAllDays(val),
                          activeColor: AppColors.primaryBrand,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      AppSpacing.h6,
                      Text(
                        'All Days',
                        style: AppTextStyles.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        AppSpacing.v8,
        _buildDayDropdown(),
        Obx(() {
          if (controller.isEditing ||
              (!controller.isAllDays.value && controller.formDay.value != 'all')) {
            return const SizedBox.shrink();
          }
          final daysList = controller.availableDays
              .map((d) => DayOfWeek.labelFor(d))
              .join(', ');
          return Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFC2410C),
                  size: 16,
                ),
                AppSpacing.h8,
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'This lecture will be scheduled across all days: ',
                          style: AppTextStyles.outfit(
                            fontSize: 11,
                            color: const Color(0xFF9A3412),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: daysList,
                          style: AppTextStyles.outfit(
                            fontSize: 11,
                            color: const Color(0xFF7C2D12),
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
        }),
      ],
    );
  }

  Widget _buildDayDropdown() {
    return Obx(() {
      final isEdit = controller.isEditing;
      final available = controller.availableDays;
      final currentDay = controller.formDay.value.toLowerCase();
      final isAll = controller.isAllDays.value || currentDay == 'all';

      final items = <DropdownMenuItem<String>>[];

      if (!isEdit) {
        items.add(
          DropdownMenuItem<String>(
            value: 'all',
            child: Text(
              'All Days',
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBrand,
              ),
            ),
          ),
        );
      }

      final dayValues = {
        if (currentDay != 'all') currentDay,
        ...available.map((d) => d.toLowerCase())
      }.toList();

      for (final day in dayValues) {
        items.add(
          DropdownMenuItem<String>(
            value: day,
            child: Text(
              DayOfWeek.labelFor(day),
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      }

      final selectedValue = isAll
          ? 'all'
          : (items.any((i) => i.value == currentDay)
              ? currentDay
              : (items.isNotEmpty ? items.first.value : null));

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
            value: selectedValue,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
            ),
            items: items,
            onChanged: (day) {
              if (day != null) {
                if (day == 'all') {
                  controller.toggleAllDays(true);
                } else {
                  controller.isAllDays.value = false;
                  controller.formDay.value = day;
                }
              }
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

  Widget _buildStatusSelector() {
    return Obx(() {
      final status = controller.formStatus.value;
      final isActive = status == 'active';

      return Row(
        children: [
          // Active
          Expanded(
            child: GestureDetector(
              onTap: () => controller.formStatus.value = 'active',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFECFDF5) : AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? const Color(0xFF6EE7B7) : AppColors.fieldBorder,
                    width: isActive ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      'Active',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? const Color(0xFF047857) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.h12,
          // Cancelled
          Expanded(
            child: GestureDetector(
              onTap: () => controller.formStatus.value = 'cancelled',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: !isActive ? const Color(0xFFFFF1F2) : AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !isActive ? const Color(0xFFFDA4AF) : AppColors.fieldBorder,
                    width: !isActive ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: !isActive ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      'Cancelled',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: !isActive ? FontWeight.w700 : FontWeight.w500,
                        color: !isActive ? const Color(0xFFBE123C) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSaveButton() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          label: controller.isEditing ? 'Save Changes' : 'Add Subject Schedule',
          isLoading: controller.isSaving.value,
          onPressed: () => controller.submitForm(),
        ),
      ),
    );
  }
}

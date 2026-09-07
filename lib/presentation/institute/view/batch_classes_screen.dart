import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/institute/controllers/batch_classes_controller.dart';
import 'package:tuoora/presentation/institute/models/batch_model.dart';
import 'package:tuoora/presentation/institute/models/school_class_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BatchClassesScreen extends StatelessWidget {
  const BatchClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final batch = Get.arguments as BatchModel?;
    if (batch == null) {
      // Arguments are lost if this route is re-entered without a fresh
      // navigation (e.g. a hot restart while already on this screen) —
      // bail out instead of crashing on the null cast.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute == AppRoutes.instituteBatchClasses) Get.back();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final controller = Get.put(BatchClassesController(batch), tag: batch.id);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: 'Classes',
              subtitle: batch.title,
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.classes.isEmpty) {
                  return const CommonLoading();
                }
                if (controller.classes.isEmpty) {
                  return const AppEmptyView(
                    icon: Icons.class_outlined,
                    title: 'No classes yet',
                    message:
                        'Add subjects taught in this batch and assign teachers to them.',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primaryBrand,
                  onRefresh: controller.fetchClasses,
                  child: ListView.separated(
                    padding: AppSpacing.all16.add(
                      const EdgeInsets.only(bottom: 80),
                    ),
                    itemCount: controller.classes.length,
                    separatorBuilder: (_, _) => AppSpacing.v12,
                    itemBuilder: (context, index) => _buildClassCard(
                      controller,
                      controller.classes[index],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => SubscriptionGuard.runAddAction(() {
          controller.prepareForAdd();
          _showClassDialog(controller);
        }),
        backgroundColor: SubscriptionGuard.blocksAdd
            ? AppColors.textMuted
            : AppColors.primaryBrand,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildClassCard(
    BatchClassesController controller,
    SchoolClassModel schoolClass,
  ) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  schoolClass.name,
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.prepareForEdit(schoolClass);
                  _showClassDialog(controller);
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.fieldLabel,
                ),
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                onPressed: () => CommonDialog.showDeleteConfirmation(
                  title: 'Delete Class',
                  description:
                      'Are you sure you want to delete "${schoolClass.name}"?',
                  onConfirm: () => controller.deleteClass(schoolClass.id),
                ),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.bohoRed,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (schoolClass.description != null &&
              schoolClass.description!.trim().isNotEmpty) ...[
            AppSpacing.v4,
            Text(
              schoolClass.description!,
              style: AppTextStyles.outfit(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
          AppSpacing.v12,
          schoolClass.teachers.isEmpty
              ? Text(
                  'No teacher assigned',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: schoolClass.teachers.map((teacher) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrandLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 14,
                            color: AppColors.primaryBrand,
                          ),
                          AppSpacing.h4,
                          Text(
                            teacher.fullName,
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBrand,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  void _showClassDialog(BatchClassesController controller) {
    CommonDialog.show(
      title: controller.editingClassId.value != null
          ? 'Edit Class'
          : 'Add Class',
      confirmText: controller.editingClassId.value != null ? 'Update' : 'Add',
      onConfirm: () => controller.saveClass(),
      isLoading: controller.isSaving,
      // CommonDialog itself scrolls and height-constrains its whole content
      // (title + description + body + buttons) against the keyboard, so the
      // body here is just a plain Column — no need to duplicate that logic.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AppInputField(
              label: 'Class Name',
              controller: controller.nameController,
              hint: 'e.g. Physics, Mathematics',
              errorText: controller.triedToSave.value
                  ? controller.nameError.value
                  : null,
            ),
          ),
          AppSpacing.v16,
          AppInputField(
            label: 'Description (Optional)',
            controller: controller.descriptionController,
            hint: 'Enter a short description',
            maxLines: 2,
          ),
          AppSpacing.v20,
          const InstituteLabel('Assign Teachers'),
          AppSpacing.v8,
          _buildTeacherMultiSelect(controller),
        ],
      ),
    );
  }

  Widget _buildTeacherMultiSelect(BatchClassesController controller) {
    return Obx(() {
      final isOpen = controller.isTeacherPickerOpen.value;
      final eligible = controller.eligibleTeachers;
      final selectedNames = eligible
          .where((s) => controller.selectedTeacherIds.contains(s.id))
          .map((s) => s.fullName)
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: controller.isLoadingStaff.value
                ? null
                : () => controller.isTeacherPickerOpen.toggle(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: isOpen
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )
                    : BorderRadius.circular(12),
                border: Border.all(
                  color: isOpen ? AppColors.primaryBrand : AppColors.fieldBorder,
                  width: isOpen ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: controller.isLoadingStaff.value
                        ? const CommonLoading(size: 18, strokeWidth: 2)
                        : Text(
                            selectedNames.isEmpty
                                ? (eligible.isEmpty
                                      ? 'No faculty found'
                                      : 'Select teacher(s)')
                                : selectedNames.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: selectedNames.isEmpty
                                  ? AppColors.textTertiary
                                  : AppColors.textPrimary,
                            ),
                          ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isOpen
                        ? AppColors.primaryBrand
                        : AppColors.fieldLabel,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen) _buildTeacherPanel(controller),
        ],
      );
    });
  }

  Widget _buildTeacherPanel(BatchClassesController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.primaryBrand, width: 1.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CHOOSE TEACHERS',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.6,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.selectedTeacherIds.clear(),
                      child: Text(
                        'Clear',
                        style: AppTextStyles.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bohoRed,
                        ),
                      ),
                    ),
                    AppSpacing.h16,
                    GestureDetector(
                      onTap: () => controller.isTeacherPickerOpen.value = false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrand,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: AppColors.white,
                            ),
                            AppSpacing.h4,
                            Text(
                              'Done',
                              style: AppTextStyles.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.background),
          Obx(() {
            final eligible = controller.eligibleTeachers;
            if (eligible.isEmpty) {
              return Padding(
                padding: AppSpacing.all16,
                child: Text(
                  'No staff members in the Faculty / Teacher department yet.',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: Material(
                type: MaterialType.transparency,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: eligible.length,
                  itemBuilder: (context, index) {
                    final staff = eligible[index];
                    return Obx(() {
                      final isSelected = controller.selectedTeacherIds
                          .contains(staff.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => controller.toggleTeacher(staff.id),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        activeColor: AppColors.primaryBrand,
                        tileColor: isSelected
                            ? AppColors.primaryBrandLight
                            : Colors.transparent,
                        title: Text(
                          staff.fullName,
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

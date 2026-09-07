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
    final BatchModel batch = Get.arguments;
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
                      context,
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
          _showClassDialog(context, controller);
        }),
        backgroundColor: SubscriptionGuard.blocksAdd
            ? AppColors.textMuted
            : AppColors.primaryBrand,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
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
                  _showClassDialog(context, controller);
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

  void _showClassDialog(BuildContext context, BatchClassesController controller) {
    CommonDialog.show(
      title: controller.editingClassId.value != null
          ? 'Edit Class'
          : 'Add Class',
      confirmText: controller.editingClassId.value != null ? 'Update' : 'Add',
      onConfirm: () => controller.saveClass(),
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
          Obx(() {
            if (controller.isLoadingStaff.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CommonLoading(size: 20, strokeWidth: 2),
              );
            }
            if (controller.staffList.isEmpty) {
              return Text(
                'No staff members found',
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.staffList.map((staff) {
                final isSelected = controller.selectedTeacherIds.contains(
                  staff.id,
                );
                return GestureDetector(
                  onTap: () => controller.toggleTeacher(staff.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBrand
                          : AppColors.fieldBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBrand
                            : AppColors.fieldBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: AppColors.white,
                          ),
                          AppSpacing.h4,
                        ],
                        Text(
                          staff.fullName,
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

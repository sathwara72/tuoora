import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/input_styles.dart';
import 'package:tuoora/presentation/institute/controllers/batch_controller.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEditBatchScreen extends GetView<BatchController> {
  const AddEditBatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => InstituteAppBar(
                title: controller.isEditMode.value
                    ? AppStrings.instEditBatchTitle
                    : AppStrings.instAddBatchTitle,
                isRoot: false,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.all24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => AppInputField(
                        label: AppStrings.instBatchNameLabelAlt,
                        controller: controller.batchNameController,
                        hint: AppStrings.instBatchNameHint,
                        errorText: controller.batchNameError.value,
                      ),
                    ),
                    AppSpacing.v24,
                    Obx(
                      () => AppInputField(
                        label: AppStrings.instBatchFeeLabelAlt,
                        controller: controller.batchFeeController,
                        hint: AppStrings.instBatchFeeHint,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        errorText: controller.feeError.value,
                      ),
                    ),
                    AppSpacing.v24,
                    const InstituteLabel('Fees Last Date'),
                    _buildFeesLastDateField(context),
                    AppSpacing.v24,
                    AppInputField(
                      label: AppStrings.instBatchDescLabel,
                      controller: controller.descriptionController,
                      hint: AppStrings.instBatchDescHint,
                      maxLines: 3,
                    ),
                    AppSpacing.v24,
                    const InstituteLabel(AppStrings.instActiveDaysLabel),
                    Obx(() {
                      if (controller.daysError.value != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            controller.daysError.value!,
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    AppSpacing.v12,
                    _buildDaysSelection(),
                    AppSpacing.v32,
                    _buildSaveButton(context),
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

  Widget _buildFeesLastDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.selectFeesLastDate(context),
      behavior: HitTestBehavior.opaque,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: InputStyles.contentPadding,
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                borderRadius: BorderRadius.circular(InputStyles.borderRadius),
                border: Border.all(
                  color: controller.feesLastDateError.value != null
                      ? Colors.redAccent
                      : AppColors.fieldBorder,
                  width: controller.feesLastDateError.value != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event_rounded,
                    color: AppColors.fieldLabel,
                    size: AppSpacing.s20,
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Text(
                      controller.selectedFeesLastDate.value != null
                          ? DateFormat(
                              'MMM dd, yyyy',
                            ).format(controller.selectedFeesLastDate.value!)
                          : 'Select fees last date',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: controller.selectedFeesLastDate.value != null
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                  Text(
                    AppStrings.instChangeBtn,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fieldLabel,
                    ),
                  ),
                ],
              ),
            ),
            if (controller.feesLastDateError.value != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  controller.feesLastDateError.value!,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSelection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: controller.allDays.map((day) {
        return Obx(() {
          final isSelected = controller.selectedDays.contains(day);
          return GestureDetector(
            onTap: () => controller.toggleDay(day),
            child: Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBrand
                    : AppColors.fieldBg,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Text(
                day,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          label: AppStrings.instSaveBatchBtn,
          icon: Icons.save_rounded,
          isLoading: controller.isLoading.value,
          onPressed: () {
            FocusScope.of(context).unfocus();
            controller.saveBatch(context);
          },
        ),
      ),
    );
  }
}

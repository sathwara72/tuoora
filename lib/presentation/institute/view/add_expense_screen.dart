import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/core/widgets/input_styles.dart';
import 'package:tuoora/presentation/institute/controllers/expense_controller.dart';
import 'package:tuoora/presentation/institute/models/expense_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends GetView<ExpenseController> {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const InstituteAppBar(title: AppStrings.addExpense),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.x16.add(AppSpacing.y16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [_buildForm(context)],
                    ),
                  ),
                ),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: AppButton(
                      onPressed: () => controller.addExpense(),
                      label: AppStrings.addExpense,
                      icon: Icons.check_circle_outline_rounded,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryDropdown(),
        AppSpacing.v20,
        Obx(
          () => AppInputField(
            label: AppStrings.instAmountLabel,
            hint: AppStrings.enterAmount,
            icon: Icons.currency_rupee_rounded,
            controller: controller.amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            maxLength: 6,
            errorText: controller.amountError.value,
          ),
        ),
        AppSpacing.v20,
        Obx(
          () => AppInputField(
            label: AppStrings.instBatchDescLabel,
            hint: AppStrings.hintEnterDescription,
            icon: Icons.description_rounded,
            controller: controller.descriptionController,
            errorText: controller.descriptionError.value,
          ),
        ),
        AppSpacing.v20,
        _buildDatePicker(context),
        AppSpacing.v20,
        _buildPaymentTypeToggle(),
        AppSpacing.v24,
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.labelCategory,
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.fieldLabel,
              ),
            ),
            GestureDetector(
              onTap: () => _showAddCategoryDialog(),
              child: Text(
                '+ NEW',
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.v8,
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(InputStyles.borderRadius),
                  border: controller.categoryError.value != null
                      ? Border.all(color: Colors.redAccent, width: 1.5)
                      : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ExpenseCategory>(
                    value: controller.selectedCategory.value,
                    isExpanded: true,
                    hint: Text(
                      AppStrings.hintSelectCategory,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    items: controller.categories.map((
                      ExpenseCategory category,
                    ) {
                      return DropdownMenuItem<ExpenseCategory>(
                        value: category,
                        child: Text(
                          category.name,
                          style: AppTextStyles.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedCategory.value = value;
                      }
                    },
                  ),
                ),
              ),
              if (controller.categoryError.value != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    controller.categoryError.value!,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.labelDate,
          style: AppTextStyles.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.fieldLabel,
          ),
        ),
        AppSpacing.v8,
        GestureDetector(
          onTap: () => controller.selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(InputStyles.borderRadius),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.fieldLabel,
                  size: 20,
                ),
                AppSpacing.h12,
                Obx(
                  () => Text(
                    DateFormat(
                      'MM/dd/yyyy',
                    ).format(controller.selectedDate.value),
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.instPaymentMethodLabel,
          style: AppTextStyles.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.fieldLabel,
          ),
        ),
        AppSpacing.v8,
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(InputStyles.borderRadius),
          ),
          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    'Cash',
                    !controller.isOnlinePayment.value,
                    () => controller.togglePaymentMethod(false),
                  ),
                ),
                Expanded(
                  child: _buildToggleButton(
                    'Online',
                    controller.isOnlinePayment.value,
                    () => controller.togglePaymentMethod(true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrand : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final textController = TextEditingController();
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Padding(
          padding: AppSpacing.all24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CREATE NEW CATEGORY',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              AppSpacing.v16,
              Row(
                children: [
                  Expanded(
                    child: AppInputField(
                      hint: 'Category Name...',
                      label: "",
                      controller: textController,
                    ),
                  ),
                  AppSpacing.h12,
                  ElevatedButton(
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        controller.createNewCategory(
                          textController.text.trim(),
                        );
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrand,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

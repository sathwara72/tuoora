import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/core/widgets/input_styles.dart';
import 'package:tuoora/presentation/institute/controllers/staff_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/presentation/institute/widgets/institute_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddSalaryScreen extends StatefulWidget {
  const AddSalaryScreen({super.key});

  @override
  State<AddSalaryScreen> createState() => _AddSalaryScreenState();
}

class _AddSalaryScreenState extends State<AddSalaryScreen> {
  final StaffController controller = Get.find<StaffController>();

  @override
  void initState() {
    super.initState();
    // Defer to post-frame so Rx mutations don't fire while ancestor widgets
    // (e.g. the dotted-background CustomPaint from GetMaterialApp.builder)
    // are still building. The primary reset happens at the launch site —
    // this is a safety net for any other entry path into this route.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.initAddSalaryMode();
      final args = Get.arguments;
      if (args is Map && args['staffId'] != null) {
        controller.selectSalaryStaffById(args['staffId'] as int);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: AppStrings.addSalary),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.all16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InstituteLabel('Select Staff Member'),
                    _buildStaffDropdown(),
                    AppSpacing.v20,
                    AppInputField(
                      label: AppStrings.paymentDate,
                      hint: 'MM/dd/yyyy',
                      icon: Icons.calendar_today_rounded,
                      controller: controller.salaryDateController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await AppPickers.date(
                          context,
                          initialDate: controller.selectedSalaryDate.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          controller.selectSalaryDate(picked);
                        }
                      },
                    ),
                    AppSpacing.v20,
                    AppInputField(
                      label: AppStrings.salaryAmount,
                      controller: controller.salaryAmountController,
                      hint: AppStrings.k000,
                      icon: Icons.currency_rupee_sharp,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => controller.update(),
                    ),
                    AppSpacing.v20,
                    _buildLeavesAndDeductionRow(),
                    AppSpacing.v24,
                    const InstituteLabel('Payment Method'),
                    _buildPaymentMethodToggle(),
                    AppSpacing.v24,
                    AppInputField(
                      label: AppStrings.notesOptional,
                      controller: controller.salaryNotesController,
                      hint: AppStrings.enterOptionalNote,
                      maxLines: 3,
                    ),
                    AppSpacing.v32,
                    _buildDisbursementSummary(),
                    AppSpacing.v32,
                    _buildSaveButton(),
                    AppSpacing.v40,
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
      final selectedId = controller.selectedAddSalaryStaff.value?.id;
      final isValueInList = controller.staffList.any((s) => s.id == selectedId);
      final isStaffEmpty = controller.staffList.isEmpty;
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
              isStaffEmpty ? 'Loading staff...' : 'Select Staff',
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
            items: controller.staffList
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
            onChanged: isStaffEmpty ? null : controller.selectSalaryStaffById,
          ),
        ),
      );
    });
  }

  Widget _buildLeavesAndDeductionRow() {
    return Obx(() {
      if (controller.selectedAddSalaryStaff.value == null) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InstituteLabel('Leaves & Deduction'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: AppInputField(
                  label: '',
                  controller: controller.salaryLeavesDisplayController,
                  hint: '0',
                  readOnly: true,
                  labelSpacing: 0,
                  textStyle: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AppSpacing.h8,
              Expanded(
                child: AppInputField(
                  label: '',
                  controller: controller.salaryDeductionController,
                  hint: AppStrings.deductionAmt,
                  icon: Icons.currency_rupee_sharp,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  labelSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildPaymentMethodToggle() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.isOnlinePayment.value = false,
              child: _buildToggleButton(
                'Cash',
                Icons.payments_rounded,
                AppColors.primaryBrand,
                !controller.isOnlinePayment.value,
              ),
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: GestureDetector(
              onTap: () => controller.isOnlinePayment.value = true,
              child: _buildToggleButton(
                'Online',
                Icons.account_balance_rounded,
                AppColors.primaryBrand,
                controller.isOnlinePayment.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.05) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
            size: 28,
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

  Widget _buildDisbursementSummary() {
    return GetBuilder<StaffController>(
      builder: (controller) {
        final amount = controller.salaryAmountController.text.isEmpty
            ? '0.00'
            : controller.salaryAmountController.text;
        return Container(
          padding: AppSpacing.all24,
          decoration: BoxDecoration(
            color: AppColors.primaryBrand.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryBrand.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.totalDisbursement,
                    style: AppTextStyles.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '₹$amount',
                    style: AppTextStyles.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ],
              ),
              AppSpacing.v16,
              const Divider(height: 1),
              AppSpacing.v16,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryBrand,
                    size: 16,
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Text(
                      AppStrings.thisPaymentWillBeRecordedIn,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          onPressed: controller.isSaving.value
              ? null
              : () => controller.saveSalaryRecord(),
          label: controller.isSaving.value ? 'Saving...' : 'Save Salary Record',
          icon: controller.isSaving.value
              ? null
              : Icons.check_circle_outline_rounded,
          isLoading: controller.isSaving.value,
        ),
      ),
    );
  }
}

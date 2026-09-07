import 'dart:io';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/presentation/institute/controllers/staff_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditStaffScreen extends GetView<StaffController> {
  const AddEditStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEdit = controller.selectedStaff.value != null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: isEdit ? 'Edit Staff Member' : 'Add Staff Member',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.x16.add(AppSpacing.y16),
                child: Form(
                  key: controller.addStaffFormKey,
                  child: Column(
                    children: [
                      _buildForm(context),
                      AppSpacing.v32,
                      _buildSaveButton(isEdit),
                      AppSpacing.v32,
                    ],
                  ),
                ),
              ),
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
        _buildProfileImageSection(context),
        AppSpacing.v32,
        Obx(
          () => AppInputField(
            label: AppStrings.instStudentNameLabel,
            controller: controller.staffNameController,
            hint: AppStrings.enterName,
            icon: Icons.person,
            errorText: controller.staffNameError.value,
            validator: (value) =>
                ValidationUtils.validateRequired(value, 'Full name'),
          ),
        ),
        AppSpacing.v20,
        Text(
          AppStrings.department,
          style: AppTextStyles.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.fieldLabel,
          ),
        ),
        AppSpacing.v8,
        Obx(
          () => _buildDepartmentMultiSelect(context, controller.deptError.value),
        ),
        AppSpacing.v20,
        Obx(
          () => AppInputField(
            label: AppStrings.instStudentEmailLabel,
            controller: controller.staffEmailController,
            hint: AppStrings.hintEnterEmail,
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            errorText: controller.staffEmailError.value,
            validator: ValidationUtils.validateEmail,
          ),
        ),
        AppSpacing.v20,
        Obx(
          () => AppInputField(
            label: AppStrings.instPhoneLabel,
            controller: controller.staffPhoneController,
            hint: AppStrings.instPhoneHint,
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            errorText: controller.staffPhoneError.value,
            validator: ValidationUtils.validatePhone,
          ),
        ),
        AppSpacing.v32,
        Text(
          AppStrings.employmentType,
          style: AppTextStyles.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.fieldLabel,
          ),
        ),
        AppSpacing.v12,
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildToggleButton(
                  'Salary',
                  controller.employmentType.value == 'Salary',
                  () => controller.employmentType.value = 'Salary',
                ),
              ),
            ),
            AppSpacing.h12,
            Expanded(
              child: Obx(
                () => _buildToggleButton(
                  'Hourly',
                  controller.employmentType.value == 'Hourly',
                  () => controller.employmentType.value = 'Hourly',
                ),
              ),
            ),
          ],
        ),
        AppSpacing.v24,
        Obx(
          () => AppInputField(
            label: controller.employmentType.value == 'Salary'
                ? 'Base Salary'
                : 'Hourly Rate',
            controller: controller.staffSalaryController,
            hint: AppStrings.k000,
            icon: Icons.payments_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: controller.staffSalaryError.value,
            validator: (value) => ValidationUtils.validateAmount(
              value,
              controller.employmentType.value == 'Salary'
                  ? 'Base Salary'
                  : 'Hourly Rate',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageSection(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => controller.showImagePickerSourceSheet(context),
          child: Stack(
            children: [
              Obx(
                () => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrandLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBrand.withValues(alpha: 0.1),
                    ),
                    image: controller.selectedImagePath.value != null
                        ? DecorationImage(
                            image: FileImage(
                              File(controller.selectedImagePath.value!),
                            ),
                            fit: BoxFit.cover,
                          )
                        : DecorationImage(
                            image:
                                controller.selectedStaff.value?.profileUrl !=
                                    null
                                ? CachedNetworkImageProvider(
                                    controller.selectedStaff.value!.profileUrl!,
                                  )
                                : CachedNetworkImageProvider(
                                    'https://ui-avatars.com/api/?name=Staff&background=00A3A3&color=fff',
                                  ),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.h16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.profilePhoto,
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.v4,
              Text(
                AppStrings.updateProfessionalInformationAndProfilePicture,
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textTertiary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentMultiSelect(BuildContext context, String? errorText) {
    return Obx(() {
      final isOpen = controller.isDepartmentPickerOpen.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.isDepartmentPickerOpen.toggle(),
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
                  color: isOpen
                      ? AppColors.primaryBrand
                      : (errorText != null
                            ? Colors.redAccent
                            : AppColors.fieldBorder),
                  width: isOpen || errorText != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.selectedDepartmentIds.isEmpty
                          ? AppStrings.selectDepartment
                          : controller.departments
                                .where(
                                  (d) => controller.selectedDepartmentIds
                                      .contains(d.id),
                                )
                                .map((d) => d.name)
                                .join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: controller.selectedDepartmentIds.isEmpty
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
          if (isOpen)
            _buildDepartmentPanel()
          else if (errorText != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                errorText,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildDepartmentPanel() {
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
                  'CHOOSE DEPARTMENTS',
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
                      onTap: () => controller.selectedDepartmentIds.clear(),
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
                      onTap: () =>
                          controller.isDepartmentPickerOpen.value = false,
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
          if (controller.departments.isEmpty)
            Padding(
              padding: AppSpacing.all16,
              child: Text(
                'No departments found',
                style: AppTextStyles.outfit(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: Material(
                type: MaterialType.transparency,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: controller.departments.length,
                  itemBuilder: (context, index) {
                    final dept = controller.departments[index];
                    return Obx(() {
                      final isSelected = controller.selectedDepartmentIds
                          .contains(dept.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) =>
                            controller.toggleDepartment(dept.id),
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
                          dept.name,
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
            ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrand : AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          onPressed: controller.isSaving.value
              ? null
              : () => controller.saveStaff(),
          isLoading: controller.isSaving.value,
          label: isEdit ? 'Update Staff Member' : 'Save Staff Member',
        ),
      ),
    );
  }
}

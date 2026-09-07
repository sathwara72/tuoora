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
        Obx(() => _buildDepartmentMultiSelect(controller.deptError.value)),
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

  Widget _buildDepartmentMultiSelect(String? errorText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: errorText != null
                ? Border.all(color: Colors.redAccent, width: 1.5)
                : null,
          ),
          child: controller.departments.isEmpty
              ? Text(
                  AppStrings.selectDepartment,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.departments.map((dept) {
                    final isSelected = controller.selectedDepartmentIds
                        .contains(dept.id);
                    return GestureDetector(
                      onTap: () => controller.toggleDepartment(dept.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBrand
                              : AppColors.white,
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
                              dept.name,
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
                ),
        ),
        if (errorText != null) ...[
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

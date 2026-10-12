import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/institute/controllers/student_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/core/widgets/input_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddEditStudentScreen extends GetView<InstituteStudentController> {
  const AddEditStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Obx(
                  () => InstituteAppBar(
                    title: controller.editingStudentId.value != null
                        ? 'Edit Student'
                        : 'Add New Student',
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.x16.add(AppSpacing.y16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMainFormCard(context),
                        AppSpacing.v24,
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.isLoading.value
                ? Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: Center(child: CommonLoading()),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFormCard(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, AppSpacing.s4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => controller.showImagePickerSourceSheet(context),
                child: Stack(
                  children: [
                    Obx(
                      () => Container(
                        width: AppSpacing.s80,
                        height: AppSpacing.s80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrandLight,
                          shape: BoxShape.circle,
                          image: controller.selectedImagePath.value != null
                              ? DecorationImage(
                                  image: FileImage(
                                    File(controller.selectedImagePath.value!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : (controller
                                            .currentStudent
                                            .value
                                            ?.profileImageUrl !=
                                        null &&
                                    controller
                                        .currentStudent
                                        .value!
                                        .profileImageUrl
                                        .isNotEmpty &&
                                    !controller
                                        .currentStudent
                                        .value!
                                        .profileImageUrl
                                        .contains('ui-avatars.com'))
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    controller
                                        .currentStudent
                                        .value!
                                        .profileImageUrl,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child:
                            (controller.selectedImagePath.value == null &&
                                (controller
                                            .currentStudent
                                            .value
                                            ?.profileImageUrl ==
                                        null ||
                                    controller
                                        .currentStudent
                                        .value!
                                        .profileImageUrl
                                        .isEmpty ||
                                    controller
                                        .currentStudent
                                        .value!
                                        .profileImageUrl
                                        .contains('ui-avatars.com')))
                            ? Center(
                                child: Text(
                                  _getInitials(
                                    controller.currentStudent.value?.name ?? "",
                                  ),
                                  style: AppTextStyles.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBrand,
                                  ),
                                ),
                              )
                            : null,
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
                      AppStrings.instStudentPhotoLabel,
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.v4,
                    Text(
                      AppStrings.instStudentPhotoHint,
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
          ),
          AppSpacing.v32,
          Obx(
            () => AppInputField(
              label: AppStrings.instStudentNameLabel,
              hint: AppStrings.instStudentNameHint,
              icon: Icons.person,
              controller: controller.nameController,
              errorText: controller.nameError.value,
            ),
          ),
          AppSpacing.v20,
          Obx(
            () => AppInputField(
              label: AppStrings.instPhoneLabel,
              hint: AppStrings.instPhoneHint,
              icon: Icons.phone,
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              errorText: controller.phoneError.value,
            ),
          ),
          AppSpacing.v12,
          Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Optional Mobile Numbers (Max 3)',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (controller.optionalPhoneControllers.length < 3)
                      GestureDetector(
                        onTap: () => controller.addOptionalPhone(),
                        child: Text(
                          '+ Add Number',
                          style: AppTextStyles.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBrand,
                          ),
                        ),
                      ),
                  ],
                ),
                if (controller.optionalPhoneControllers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...controller.optionalPhoneControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final phoneCtrl = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppInputField(
                              label: '',
                              hint: 'Optional Number ${index + 1}',
                              icon: Icons.phone_android_rounded,
                              controller: phoneCtrl,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => controller.removeOptionalPhone(index),
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            );
          }),
          AppSpacing.v20,
          Obx(
            () => AppInputField(
              label: '${AppStrings.instStudentEmailLabel} (Optional)',
              hint: '${AppStrings.instStudentEmailHint} (Optional)',
              icon: Icons.email_rounded,
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: controller.editingStudentId.value == null,
              errorText: controller.emailError.value,
            ),
          ),
          AppSpacing.v20,
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password (Optional)',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.fieldLabel,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(InputStyles.borderRadius),
                    border: controller.passwordError.value != null
                        ? Border.all(color: Colors.redAccent, width: 1.5)
                        : Border.all(color: AppColors.fieldBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.fieldLabel,
                          size: AppSpacing.s20,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: controller.passwordController,
                            obscureText: !controller.isPasswordVisible.value,
                            style: AppTextStyles.outfit(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: controller.editingStudentId.value != null
                                  ? 'Leave blank to keep current password'
                                  : 'Enter Password (Optional)',
                              hintStyle: AppTextStyles.outfit(
                                fontSize: 14,
                                color: AppColors.fieldLabel,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: controller.togglePasswordVisibility,
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.fieldLabel,
                            size: AppSpacing.s20,
                          ),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.passwordError.value != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      controller.passwordError.value!,
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
          AppSpacing.v20,
          Obx(
            () => AppInputField(
              label: AppStrings.instStudentDobLabel,
              hint: AppStrings.instSelectDobHint,
              icon: Icons.calendar_today_rounded,
              controller: controller.dobController,
              readOnly: true,
              onTap: () => controller.selectDOB(context),
              errorText: controller.dobError.value,
            ),
          ),

          AppSpacing.v20,
          Obx(
            () => AppInputField(
              label: AppStrings.instParentNameLabel,
              hint: AppStrings.instParentNameHint,
              icon: Icons.group,
              controller: controller.parentNameController,
              errorText: controller.parentNameError.value,
            ),
          ),
          AppSpacing.v20,
          AppInputField(
            label: 'School Name (Optional)',
            hint: 'Enter School Name',
            icon: Icons.school_outlined,
            controller: controller.schoolNameController,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 16),
      child: Obx(
        () => AppButton(
          label: controller.editingStudentId.value != null
              ? 'Update Student'
              : AppStrings.instConfirmBtn,
          onPressed: () => controller.saveStudent(
            isEdit: controller.editingStudentId.value != null,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.trim().split(' ');
    String initials = '';
    if (names.isNotEmpty && names[0].isNotEmpty) {
      initials += names[0][0].toUpperCase();
      if (names.length > 1 && names[names.length - 1].isNotEmpty) {
        initials += names[names.length - 1][0].toUpperCase();
      }
    }
    return initials.isEmpty ? 'SP' : initials;
  }
}

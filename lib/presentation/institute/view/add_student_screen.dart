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
          AppSpacing.v20,
          Obx(
            () => AppInputField(
              label: AppStrings.instStudentEmailLabel,
              hint: AppStrings.instStudentEmailHint,
              icon: Icons.email_rounded,
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: controller.editingStudentId.value == null,
              errorText: controller.emailError.value,
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

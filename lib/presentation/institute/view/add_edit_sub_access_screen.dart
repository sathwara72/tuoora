import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/app_input_field.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/input_styles.dart';
import 'package:tuoora/data/models/sub_access_model.dart';
import 'package:tuoora/presentation/institute/controllers/sub_access_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class AddEditSubAccessScreen extends GetView<SubAccessController> {
  const AddEditSubAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: controller.isEditing
                  ? 'Edit Sub-Access'
                  : 'Add Sub-Access',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.x16.add(AppSpacing.y16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDetailsCard(),
                    AppSpacing.v20,
                    _buildPermissionsSection(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Obx(
                () => AppButton(
                  label: controller.isEditing ? 'Save Changes' : 'Add User',
                  isLoading: controller.isSaving.value,
                  onPressed: controller.save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
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
      child: child,
    );
  }

  Widget _buildDetailsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AppInputField(
              label: 'Full Name',
              hint: 'Enter name',
              icon: Icons.person,
              controller: controller.nameController,
              errorText: controller.nameError.value,
            ),
          ),
          AppSpacing.v16,
          Obx(
            () => AppInputField(
              label: 'Email (used to sign in)',
              hint: 'name@example.com',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              controller: controller.emailController,
              errorText: controller.emailError.value,
            ),
          ),
          AppSpacing.v16,
          Obx(
            () => AppInputField(
              label: 'Phone (Optional)',
              hint: '10-digit mobile number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: controller.phoneController,
              errorText: controller.phoneError.value,
            ),
          ),
          AppSpacing.v16,
          _buildPasswordField(),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.isEditing ? 'Password (Optional)' : 'Password',
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
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
                      hintText: controller.isEditing
                          ? 'Leave blank to keep current password'
                          : 'Minimum 6 characters',
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
                  onPressed: () => controller.isPasswordVisible.toggle(),
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
          if (controller.passwordError.value != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
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
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Obx(() {
      final groups = controller.permissionGroups;
      final selectedCount = controller.selectedPermissions.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Permissions',
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$selectedCount selected',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
            ],
          ),
          AppSpacing.v4,
          Text(
            'Choose what this user can see and do on the web panel.',
            style: AppTextStyles.outfit(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.v12,
          if (groups.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CommonLoading(),
            )
          else
            ...groups.map(
              (g) => Padding(
                padding: AppSpacing.bottom12,
                child: _buildGroupCard(g),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildGroupCard(SubAccessPermissionGroup group) {
    final allOn = controller.isGroupFullySelected(group);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.label,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.toggleGroup(group, !allOn),
                child: Text(
                  allOn ? 'Clear' : 'Select all',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v8,
          ...group.permissions.map((p) {
            final on = controller.selectedPermissions.contains(p.key);
            return InkWell(
              onTap: () => controller.togglePermission(p.key, !on),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: on,
                        activeColor: AppColors.primaryBrand,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        onChanged: (v) =>
                            controller.togglePermission(p.key, v ?? false),
                      ),
                    ),
                    AppSpacing.h12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.label,
                            style: AppTextStyles.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (p.description.isNotEmpty)
                            Text(
                              p.description,
                              style: AppTextStyles.outfit(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

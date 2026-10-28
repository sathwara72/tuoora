import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/date_format_utils.dart';
import 'package:tuoora/core/widgets/app_search_field.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/input_styles.dart';
import 'package:tuoora/core/widgets/toggle_switch.dart';
import 'package:tuoora/data/models/sub_access_model.dart';
import 'package:tuoora/presentation/institute/controllers/sub_access_controller.dart';
import 'package:tuoora/presentation/institute/widgets/common_state_widget.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

/// Access Share: the owner's list of sub-access users.
class SubAccessScreen extends GetView<SubAccessController> {
  const SubAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(
              title: 'Access Share',
              subtitle: 'Give your team limited access',
            ),
            Expanded(
              child: Padding(
                padding: AppSpacing.x16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSpacing.v16,
                    AppSearchField(
                      hintText: 'Search by name, email or phone',
                      onChanged: (v) => controller.searchQuery.value = v,
                    ),
                    AppSpacing.v16,
                    Expanded(
                      child: Obx(() {
                        final list = controller.filteredUsers;
                        return CommonStateWidget(
                          isLoading: controller.isLoading.value,
                          isEmpty: list.isEmpty,
                          emptyTitle: 'No sub-access users',
                          emptySubtitle: controller.searchQuery.value.isEmpty
                              ? 'Tap + to give someone access to your web panel.'
                              : 'No users match your search.',
                          emptyIcon: Icons.admin_panel_settings_outlined,
                          child: RefreshIndicator(
                            color: AppColors.primaryBrand,
                            onRefresh: controller.fetchUsers,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 96),
                              itemCount: list.length,
                              separatorBuilder: (_, _) => AppSpacing.v12,
                              itemBuilder: (context, i) =>
                                  _buildUserCard(context, list[i]),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.prepareForAdd();
          Get.toNamed(AppRoutes.instituteAddEditSubAccess);
        },
        backgroundColor: AppColors.primaryBrand,
        child: const Icon(Icons.add, color: AppColors.white, size: 32),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, SubAccessUser user) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.background),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(user.name),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final busy = controller.busyIds.contains(user.id);
                return Opacity(
                  opacity: busy ? 0.5 : 1,
                  child: ToggleSwitch(
                    value: user.isActive,
                    onChanged: (_) {
                      if (!busy) controller.toggleStatus(user);
                    },
                  ),
                );
              }),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (v) => _onMenu(context, v, user),
                itemBuilder: (_) => [
                  _menuItem('edit', Icons.edit_outlined, 'Edit'),
                  _menuItem('logout', Icons.logout_rounded, 'Log Out'),
                  _menuItem(
                    'reset',
                    Icons.lock_reset_rounded,
                    'Reset Password',
                  ),
                  _menuItem('delete', Icons.delete_outline_rounded, 'Delete'),
                ],
              ),
            ],
          ),
          AppSpacing.v12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(
                user.isActive ? 'Active' : 'Disabled',
                user.isActive ? AppColors.successBg : AppColors.errorBg,
                user.isActive ? AppColors.greenText : AppColors.bohoRed,
              ),
              _chip(
                '${user.permissions.length} permission${user.permissions.length == 1 ? '' : 's'}',
                AppColors.primaryBrandLight,
                AppColors.primaryBrand,
              ),
              if (user.lastLoginAt != null)
                _chip(
                  'Last login ${DateFormatUtils.relativeTime(user.lastLoginAt)}',
                  AppColors.fieldBg,
                  AppColors.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    final danger = value == 'delete';
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: danger ? AppColors.bohoRed : AppColors.textPrimary,
          ),
          AppSpacing.h12,
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 14,
              color: danger ? AppColors.bohoRed : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _onMenu(BuildContext context, String value, SubAccessUser user) {
    switch (value) {
      case 'edit':
        controller.prepareForEdit(user);
        Get.toNamed(AppRoutes.instituteAddEditSubAccess);
        break;
      case 'logout':
        CommonDialog.show(
          title: 'Log Out ${user.name}?',
          description:
              'This ends all of their sessions. The account stays active and they can sign in again.',
          icon: Icons.logout_rounded,
          iconColor: AppColors.primaryBrand,
          iconBgColor: AppColors.primaryBrandLight,
          confirmText: 'Log Out',
          confirmButtonColor: AppColors.primaryBrand,
          onConfirm: () => controller.forceLogout(user),
        );
        break;
      case 'reset':
        _showResetPasswordDialog(user);
        break;
      case 'delete':
        CommonDialog.showDeleteConfirmation(
          title: 'Delete Sub-Access',
          description:
              'Are you sure you want to delete\n${user.name}? They will lose access immediately.',
          onConfirm: () => controller.delete(user),
        );
        break;
    }
  }

  void _showResetPasswordDialog(SubAccessUser user) {
    final passwordCtrl = TextEditingController();
    final error = RxnString();
    final visible = false.obs;
    final saving = false.obs;

    CommonDialog.show(
      title: 'Reset Password',
      description:
          'Set a new password for ${user.name}. They will be logged out everywhere.',
      icon: Icons.lock_reset_rounded,
      iconColor: AppColors.primaryBrand,
      iconBgColor: AppColors.primaryBrandLight,
      confirmText: 'Reset',
      confirmButtonColor: AppColors.primaryBrand,
      isLoading: saving,
      body: Obx(
        () => TextField(
          controller: passwordCtrl,
          obscureText: !visible.value,
          style: InputStyles.textStyle(),
          decoration: InputStyles.filled(
            hintText: 'New password (min 6)',
            errorText: error.value,
            suffixIcon: IconButton(
              onPressed: () => visible.value = !visible.value,
              icon: Icon(
                visible.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.fieldLabel,
                size: AppSpacing.s20,
              ),
            ),
          ),
        ),
      ),
      onConfirm: () async {
        final pwd = passwordCtrl.text;
        if (pwd.length < 6) {
          error.value = 'Password must be at least 6 characters';
          return;
        }
        error.value = null;
        saving.value = true;
        final ok = await controller.resetPassword(user, pwd);
        saving.value = false;
        if (ok) Get.back();
      },
    );
  }

  Widget _chip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    var initials = '';
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      initials = parts.first[0].toUpperCase();
      if (parts.length > 1 && parts.last.isNotEmpty) {
        initials += parts.last[0].toUpperCase();
      }
    }
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.primaryBrandLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTextStyles.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBrand,
        ),
      ),
    );
  }
}

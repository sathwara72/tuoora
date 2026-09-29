import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_dialog.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_profile_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_profile_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_institute_switcher_sheet.dart';

class TeacherProfileScreen extends GetView<TeacherProfileController> {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Obx(() {
        if (controller.isLoading.value && controller.profile.value == null) {
          return const Center(child: CommonLoading());
        }
        final profile = controller.profile.value;
        if (profile == null) {
          return const SizedBox.shrink();
        }
        final multipleInstitutes =
            Get.find<AuthService>().currentUser?.hasMultipleInstitutes == true;

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(context, profile),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('Details'),
                  _card(
                    children: [
                      if (profile.employeeId != null)
                        _detailRow(
                          Icons.badge_outlined,
                          'Employee ID',
                          profile.employeeId,
                        ),
                      _detailRow(
                        Icons.mail_outline_rounded,
                        'Email',
                        profile.email,
                      ),
                      if (profile.phone != null)
                        _detailRow(
                          Icons.phone_outlined,
                          'Phone',
                          profile.phone,
                        ),
                      if (profile.employmentType != null)
                        _detailRow(
                          Icons.work_outline_rounded,
                          'Employment',
                          _titleCase(profile.employmentType!),
                        ),
                      if (profile.instituteName != null)
                        _detailRow(
                          Icons.apartment_rounded,
                          'Institute',
                          profile.instituteName,
                        ),
                    ],
                  ),
                  AppSpacing.v20,
                  _sectionTitle('Account'),
                  _card(
                    children: [
                      if (multipleInstitutes)
                        _actionRow(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Switch Institute',
                          onTap: () =>
                              TeacherInstituteSwitcherSheet.show(context),
                        ),
                      _actionRow(
                        icon: Icons.lock_reset_rounded,
                        label: 'Change Password',
                        onTap: () => Get.toNamed(
                          AppRoutes.teacherChangePassword,
                          arguments: false,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.v20,
                  _card(
                    children: [
                      _actionRow(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        color: AppColors.bohoRed,
                        showChevron: false,
                        onTap: controller.logout,
                      ),
                      _actionRow(
                        icon: Icons.delete_forever_rounded,
                        label: AppStrings.deleteAccount,
                        color: AppColors.bohoRed,
                        showChevron: false,
                        onTap: () => CommonDialog.showDeleteConfirmation(
                          title: AppStrings.deleteAccountConfirmTitle,
                          description: AppStrings.deleteAccountConfirmMessage,
                          confirmText: AppStrings.deleteAccountConfirmButton,
                          onConfirm: controller.deleteAccount,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, TeacherProfile profile) {
    final hsl = HSLColor.fromColor(AppColors.primaryBrand);
    final dark = hsl
        .withLightness((hsl.lightness - 0.14).clamp(0.0, 1.0))
        .toColor();
    final subtitle = [
      profile.role,
      profile.department,
    ].where((e) => e != null && e.isNotEmpty).join(' · ');
    final isActive = profile.status.toLowerCase() == 'active';

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 10,
        16,
        26,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBrand, dark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrand.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: AppSpacing.s40,
                  height: AppSpacing.s40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'My Profile',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s40),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: controller.changeAvatar,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primaryBrandLight,
                    backgroundImage: profile.profileUrl != null
                        ? NetworkImage(profile.profileUrl!)
                        : null,
                    child: profile.profileUrl == null
                        ? Text(
                            profile.fullName.isNotEmpty
                                ? profile.fullName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBrand,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: dark, width: 2),
                    ),
                    child: controller.isUploadingAvatar.value
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CommonLoading(size: 14),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            color: AppColors.primaryBrand,
                            size: 15,
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: AppTextStyles.outfit(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.outfit(
                fontSize: 13,
                color: AppColors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF4ADE80) : Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _titleCase(profile.status),
                  style: AppTextStyles.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleCase(String v) {
    final cleaned = v.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    return cleaned
        .split(RegExp(r'\s+'))
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, indent: 62, color: Color(0xFFF1F5F9)),
          ],
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _iconBadge(icon, AppColors.primaryBrand),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value == null || value.isEmpty ? '-' : value,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primaryBrand,
    bool showChevron = true,
  }) {
    final isDanger = color == AppColors.bohoRed;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _iconBadge(icon, color),
            AppSpacing.h12,
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDanger ? color : AppColors.textPrimary,
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

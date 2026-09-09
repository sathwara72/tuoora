import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/teacher/controllers/teacher_profile_controller.dart';
import 'package:tuoora/presentation/teacher/models/teacher_profile_model.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_institute_switcher_sheet.dart';

class TeacherProfileScreen extends GetView<TeacherProfileController> {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const TeacherAppBar(title: 'My Profile'),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.profile.value == null) {
                  return const Center(child: CommonLoading());
                }
                final profile = controller.profile.value;
                if (profile == null) {
                  return const SizedBox.shrink();
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: controller.changeAvatar,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: AppColors.fieldBg,
                              backgroundImage: profile.profileUrl != null
                                  ? NetworkImage(profile.profileUrl!)
                                  : null,
                              child: profile.profileUrl == null
                                  ? Text(
                                      profile.fullName.isNotEmpty
                                          ? profile.fullName[0].toUpperCase()
                                          : '?',
                                      style: AppTextStyles.outfit(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBrand,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: AppSpacing.s28,
                                height: AppSpacing.s28,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBrand,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.white, width: 2),
                                ),
                                child: controller.isUploadingAvatar.value
                                    ? const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: CommonLoading(color: AppColors.white, size: 14),
                                      )
                                    : const Icon(
                                        Icons.camera_alt_rounded,
                                        color: AppColors.white,
                                        size: 14,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.v12,
                    Center(
                      child: Text(
                        profile.fullName,
                        style: AppTextStyles.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (profile.role != null)
                      Center(
                        child: Text(
                          [profile.role, profile.department]
                              .where((e) => e != null && e.isNotEmpty)
                              .join(' · '),
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    AppSpacing.v24,
                    _infoCard(profile),
                    AppSpacing.v24,
                    if (Get.find<AuthService>().currentUser?.hasMultipleInstitutes == true) ...[
                      _actionTile(
                        icon: Icons.apartment_rounded,
                        label: 'Switch Institute',
                        onTap: () => TeacherInstituteSwitcherSheet.show(context),
                      ),
                      AppSpacing.v8,
                    ],
                    _actionTile(
                      icon: Icons.lock_reset_rounded,
                      label: 'Change Password',
                      onTap: () => Get.toNamed(
                        AppRoutes.teacherChangePassword,
                        arguments: false,
                      ),
                    ),
                    AppSpacing.v8,
                    _actionTile(
                      icon: Icons.receipt_long_rounded,
                      label: 'Salary Slips',
                      onTap: () => Get.toNamed(AppRoutes.teacherSalaries),
                    ),
                    AppSpacing.v8,
                    _actionTile(
                      icon: Icons.event_available_rounded,
                      label: 'My Attendance',
                      onTap: () => Get.toNamed(AppRoutes.teacherSelfAttendance),
                    ),
                    AppSpacing.v24,
                    _actionTile(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      isDestructive: true,
                      onTap: controller.logout,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(TeacherProfile profile) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.employeeId != null)
            _infoRow('Employee ID', profile.employeeId),
          _infoRow('Email', profile.email),
          if (profile.phone != null) _infoRow('Phone', profile.phone),
          if (profile.employmentType != null)
            _infoRow('Employment Type', profile.employmentType),
          if (profile.instituteName != null)
            _infoRow('Institute', profile.instituteName, isLast: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.bohoRed : AppColors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.all16,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            AppSpacing.h12,
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            if (!isDestructive)
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

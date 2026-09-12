import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_app_bar.dart';
import 'package:tuoora/presentation/teacher/widgets/teacher_institute_switcher_sheet.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    // Enforce immediate redirect if must_change_password == true
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authService.currentUser?.mustChangePassword == true) {
        Get.offAllNamed(AppRoutes.teacherChangePassword, arguments: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Obx(() {
          final user = authService.currentUser;
          return Column(
            children: [
              TeacherAppBar(
                title:
                    'Welcome${user?.name.isNotEmpty == true ? ', ${user!.name}' : ''}',
                subtitle: user?.staffRole,
                isRoot: true,
                actions: [
                  if (user?.hasMultipleInstitutes == true)
                    GestureDetector(
                      onTap: () => TeacherInstituteSwitcherSheet.show(context),
                      child: Container(
                        width: AppSpacing.s40,
                        height: AppSpacing.s40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrand.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryBrand.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.primaryBrand,
                          size: AppSpacing.s20,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.teacherProfile),
                    child: Container(
                      width: AppSpacing.s40,
                      height: AppSpacing.s40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getInitials(user?.name),
                        style: AppTextStyles.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _confirmLogout(context),
                    child: Container(
                      width: AppSpacing.s40,
                      height: AppSpacing.s40,
                      decoration: BoxDecoration(
                        color: AppColors.fieldBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.fieldBorder),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.textPrimary,
                        size: AppSpacing.s20,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  children: [
                    if (user?.instituteName != null &&
                        user!.instituteName!.isNotEmpty)
                      _buildActiveInstituteCard(context, user),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.s12,
                      crossAxisSpacing: AppSpacing.s12,
                      childAspectRatio: 1.3,
                      children: [
                        _DashboardTile(
                          icon: Icons.groups_rounded,
                          label: 'My Batches',
                          onTap: () => Get.toNamed(AppRoutes.teacherBatches),
                        ),
                        _DashboardTile(
                          icon: Icons.calendar_month_rounded,
                          label: 'Time Table',
                          onTap: () => Get.toNamed(AppRoutes.teacherTimetable),
                        ),
                        _DashboardTile(
                          icon: Icons.event_available_rounded,
                          label: 'My Attendance',
                          onTap: () =>
                              Get.toNamed(AppRoutes.teacherSelfAttendance),
                        ),
                        _DashboardTile(
                          icon: Icons.receipt_long_rounded,
                          label: 'Salary Slips',
                          onTap: () => Get.toNamed(AppRoutes.teacherSalaries),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActiveInstituteCard(BuildContext context, dynamic user) {
    final bool hasMultiple = user.hasMultipleInstitutes;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryBrand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: AppColors.primaryBrand,
              size: 20,
            ),
          ),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE INSTITUTE',
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.instituteName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (hasMultiple) ...[
            AppSpacing.h8,
            InkWell(
              onTap: () => TeacherInstituteSwitcherSheet.show(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.swap_horiz_rounded,
                      size: 16,
                      color: AppColors.primaryBrand,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Switch',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(
          AppStrings.logOut,
          style: AppTextStyles.outfit(fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppStrings.instituteProfileAreYouSureYouWantTo,
          style: AppTextStyles.outfit(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              AppStrings.labelCancel,
              style: AppTextStyles.outfit(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await Get.find<AuthRepository>().logout('TEACHER');
              } catch (_) {}
              await Get.find<AuthService>().clearSession();
              Get.offAllNamed(AppRoutes.roleSelection);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Text(
              AppStrings.logOut,
              style: AppTextStyles.outfit(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'TM';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return '$first$second'.toUpperCase();
    }
    final single = parts[0];
    return single.substring(0, single.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: AppSpacing.s48,
              height: AppSpacing.s48,
              decoration: BoxDecoration(
                color: AppColors.primaryBrand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryBrand, size: 24),
            ),
            AppSpacing.v8,
            Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

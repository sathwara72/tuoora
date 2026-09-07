import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/widgets/app_logo.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.x16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              AppSpacing.v24,
              _buildRoleCard(
                title: AppStrings.loginAsInstitute,
                subtitle: AppStrings.manageStudentsBatchesAndAcademicOperations,
                icon: Icons.business_rounded,
                iconColor: AppColors.primaryBrand,
                onTap: () {
                  GetStorage().write('last_selected_role', 'INSTITUTE');
                  Get.toNamed(AppRoutes.login, arguments: 'INSTITUTE');
                },
              ),
              AppSpacing.v16,
              _buildRoleCard(
                title: AppStrings.loginAsStudent,
                subtitle: AppStrings.viewYourClassesFeesHomeworkAnd,
                icon: Icons.school_rounded,
                iconColor: AppColors.primaryBrand,
                onTap: () {
                  GetStorage().write('last_selected_role', 'STUDENT');
                  Get.toNamed(AppRoutes.login, arguments: 'STUDENT');
                },
              ),
              AppSpacing.v48,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: AppLogo(height: AppSpacing.s64),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.borderGrey, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.s72,
              height: AppSpacing.s72,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 32)),
            ),
            AppSpacing.h16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.v4,
                  Text(
                    subtitle,
                    style: AppTextStyles.outfit(
                      fontSize: 12,
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
      ),
    );
  }
}

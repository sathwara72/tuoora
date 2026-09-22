import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_images.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/branding_service.dart';
import 'package:tuoora/core/widgets/app_logo.dart';
import 'package:tuoora/core/widgets/brand_backdrop.dart';
import 'package:tuoora/core/widgets/fit_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const _studentBlue = Color(0xFF1D7AF2);
  static const _teacherGreen = Color(0xFF16A860);

  void _select(String role) {
    Get.toNamed(AppRoutes.login, arguments: role);
  }

  @override
  Widget build(BuildContext context) {
    final appName = Get.isRegistered<BrandingService>()
        ? Get.find<BrandingService>().appName
        : AppStrings.appName;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BrandBackdrop(
        child: SafeArea(
          child: FitScreen(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 48),
                  const AppLogo(height: 56),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.smartInstituteErp,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Welcome to ${appName.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.outfit(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.chooseYourRole,
                    style: AppTextStyles.outfit(
                      fontSize: 16,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const DotsDivider(),
                  const SizedBox(height: 22),
                  RoleCard(
                    title: 'Institute',
                    image: AppImages.roleInstitute,
                    color: AppColors.primaryBrand,
                    onTap: () => _select('INSTITUTE'),
                  ),
                  const SizedBox(height: 16),
                  RoleCard(
                    title: 'Student',
                    image: AppImages.roleStudent,
                    color: _studentBlue,
                    onTap: () => _select('STUDENT'),
                  ),
                  const SizedBox(height: 16),
                  RoleCard(
                    title: 'Teacher',
                    image: AppImages.roleTeacher,
                    color: _teacherGreen,
                    onTap: () => _select('TEACHER'),
                  ),
                  const SizedBox(height: 28),
                  const TaglineFooter(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Orange / amber / teal dots between two hairlines.
class DotsDivider extends StatelessWidget {
  const DotsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    Widget line() =>
        Container(width: 56, height: 1, color: AppColors.borderGrey);
    Widget dot(Color c) => Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line(),
        const SizedBox(width: 10),
        dot(AppColors.primaryBrand),
        dot(const Color(0xFFF6B94B)),
        dot(const Color(0xFF1FA593)),
        const SizedBox(width: 10),
        line(),
      ],
    );
  }
}

class TaglineFooter extends StatelessWidget {
  const TaglineFooter({super.key});

  @override
  Widget build(BuildContext context) {
    Widget line() =>
        Expanded(child: Container(height: 1, color: AppColors.borderGrey));
    return Row(
      children: [
        line(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            AppStrings.tagLine.toUpperCase(),
            style: AppTextStyles.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 1.8,
            ),
          ),
        ),
        line(),
      ],
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String image;
  final Color color;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.image,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // The coloured strip along the bottom edge is the outer container peeking
    // out below the inner card.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withValues(alpha: 0.14)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.alphaBlend(color.withValues(alpha: 0.07), Colors.white),
                Colors.white,
              ],
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                image,
                width: 96,
                height: 86,
                fit: BoxFit.contain,
                cacheWidth: 300,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: color,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

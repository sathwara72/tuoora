import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/url_constants.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/widgets/app_network_image.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/utils/url_launcher_utils.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:tuoora/data/repositories/auth_repository.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/app_version_label.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/student_bottom_nav.dart';
import 'package:tuoora/presentation/student/widgets/performance_gauge.dart';
import 'package:tuoora/presentation/student/widgets/profile_grid_action.dart';
import 'package:tuoora/presentation/student/widgets/profile_menu_tile.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';
import 'package:tuoora/presentation/student/controllers/student_profile_controller.dart';
import 'package:tuoora/data/models/student_profile_model.dart';
import 'dart:io';

class StudentProfileScreen extends GetView<StudentProfileController> {
  final bool showBottomNav;

  const StudentProfileScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CommonLoading(color: AppColors.primaryBrand);
          }
          final profile = controller.profileData.value;
          if (profile == null) {
            return const AppEmptyView(
              icon: Icons.person_off_outlined,
              title: AppStrings.profileUnavailable,
              message:
                  'We couldn\'t load your profile right now. Please try again later.',
            );
          }

          return Column(
            children: [
              const StudentAppBar(title: AppStrings.profile, isRoot: true),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryBrand,
                  onRefresh: controller.fetchProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.screenPaddingTop,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroCard(profile.header),
                        const SizedBox(height: 12),
                        _buildPerformanceScoreCard(profile.stats),
                        const SizedBox(height: 12),
                        _buildStatsRow(profile.stats),
                        const SizedBox(height: 12),
                        _buildGridActions(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('YOUR INFO'),
                        const SizedBox(height: 8),
                        _buildYourInfoCard(profile.info),
                        const SizedBox(height: 16),
                        _buildSectionTitle('SETTINGS'),
                        const SizedBox(height: 8),
                        _buildSettingsCard(),
                        const SizedBox(height: 16),
                        _buildSectionTitle('HELP & INFO'),
                        const SizedBox(height: 8),
                        _buildHelpCard(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: _actionButton(
                                context,
                                header: AppStrings.logOut,
                                icon: Icons.logout_rounded,
                                onPressed: () {
                                  _showLogoutDialog(context);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _actionButton(
                                context,
                                header: AppStrings.deleteAccount,
                                icon: Icons.delete_forever_rounded,
                                onPressed: () {
                                  _showDeleteAccountDialog(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const AppVersionLabel(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: showBottomNav
          ? const StudentBottomNav(currentIndex: 4)
          : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildHeroCard(StudentProfileHeader header) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(100, 14, 16, 4),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.instBrandOrange, AppColors.primaryBrand],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Text(
                  header.name,
                  style: AppTextStyles.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(100, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class ${header.standard} • ${header.subject} • Roll ${header.rollNo}',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Member since: ${header.memberSince}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 30,
            left: 16,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Obx(() {
                  final controller = Get.find<StudentProfileController>();
                  final imagePath = controller.profileImagePath.value;
                  return Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrandLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.white, width: 3),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imagePath.isNotEmpty
                        ? Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const _AvatarPersonFallback(),
                          )
                        : (header.avatarUrl.isNotEmpty &&
                                  header.avatarUrl.startsWith('http')
                              ? AppNetworkImage(
                                  url: header.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: const _AvatarPersonFallback(),
                                )
                              : Center(
                                  child: Text(
                                    header.initials,
                                    style: AppTextStyles.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryBrand,
                                    ),
                                  ),
                                )),
                  );
                }),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: GestureDetector(
                    onTap: () {
                      controller.showImagePickerOptions();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBrand,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceScoreCard(StudentProfileStats stats) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: PerformanceGauge(score: stats.performanceScore, size: 180),
      ),
    );
  }

  Widget _buildStatsRow(StudentProfileStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: AppStrings.attendance,
            value: '${stats.attendancePct}%',
            subValue: stats.attendanceLabel,
            valueColor: AppColors.primaryBrand,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            label: AppStrings.assignment,
            value: '${stats.assignmentsPct}%',
            subValue: stats.assignmentsLabel,
            valueColor: AppColors.primaryBrand,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subValue,
    Color? valueColor,
  }) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                subValue,
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ProfileGridAction(
                icon: Icons.show_chart_rounded,
                label: AppStrings.labelReports,
                iconBgColor: AppColors.primaryBrandLight,
                iconColor: AppColors.primaryBrand,
                onTap: () => Get.toNamed(AppRoutes.studentReports),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ProfileGridAction(
                icon: Icons.book_outlined,
                label: AppStrings.labelStudyMaterial,
                iconBgColor: AppColors.successBg,
                iconColor: AppColors.successGreen,
                onTap: () => Get.toNamed(AppRoutes.studentStudyMaterial),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ProfileGridAction(
                icon: Icons.domain_rounded,
                label: AppStrings.studentReceiptInstitute,
                iconBgColor: AppColors.subjectPhysicsSoft,
                iconColor: AppColors.subjectPhysics,
                onTap: () => Get.toNamed(AppRoutes.studentInstitute),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ProfileGridAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: AppStrings.chat,
                iconBgColor: AppColors.errorBg,
                iconColor: AppColors.bohoRed,
                onTap: () => Get.toNamed(AppRoutes.studentChat),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ProfileGridAction(
                icon: Icons.download_rounded,
                label: AppStrings.labelReceipts,
                iconBgColor: AppColors.primaryBrandLight,
                iconColor: AppColors.orangeTag,
                onTap: () => Get.toNamed(AppRoutes.studentReceiptsList),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ProfileGridAction(
                icon: Icons.fact_check_outlined,
                label: AppStrings.labelExams,
                iconBgColor: AppColors.successBg,
                iconColor: AppColors.successGreen,
                onTap: () => Get.toNamed(AppRoutes.studentExams),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ProfileGridAction(
                icon: Icons.calendar_view_week_rounded,
                label: AppStrings.labelTimetable,
                iconBgColor: AppColors.skyBlueLight,
                iconColor: AppColors.studentProgressBlue,
                onTap: () => Get.toNamed(AppRoutes.studentTimetable),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ProfileGridAction(
                icon: Icons.cake_outlined,
                label: AppStrings.labelBirthdays,
                iconBgColor: AppColors.primaryBrandLight,
                iconColor: AppColors.primaryBrand,
                onTap: () => Get.toNamed(AppRoutes.studentBirthdays),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ProfileGridAction(
                icon: Icons.badge_outlined,
                label: AppStrings.labelIdCard,
                iconBgColor: AppColors.successBg,
                iconColor: AppColors.successGreen,
                onTap: () => Get.toNamed(AppRoutes.studentIdCard),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildCardWrap({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildYourInfoCard(StudentProfileInfo info) {
    return _buildCardWrap(
      children: [
        _buildInfoRow('Phone', info.phone),
        Divider(height: 1, color: AppColors.borderGrey.withValues(alpha: 0.5)),
        _buildInfoRow('Email', info.email),
        if (info.parentName != null) ...[
          Divider(
            height: 1,
            color: AppColors.borderGrey.withValues(alpha: 0.5),
          ),
          _buildInfoRow(
            info.parentRelation,
            '${info.parentName} • ${info.parentPhone ?? ''}',
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return _buildCardWrap(
      children: [
        ProfileMenuTile(
          icon: Icons.notifications_none_rounded,
          title: AppStrings.notificationPreferences,
          onTap: () => Get.toNamed(AppRoutes.studentNotificationPreferences),
        ),
        // Divider(height: 1, color: AppColors.borderGrey.withValues(alpha: 0.5)),
        // const ProfileMenuTile(
        //   icon: Icons.article_outlined,
        //   title: AppStrings.language,
        //   trailingText: 'English',
        // ),
        // Divider(height: 1, color: AppColors.borderGrey.withValues(alpha: 0.5)),
        // const ProfileMenuTile(
        //   icon: Icons.brightness_auto_rounded,
        //   title: AppStrings.theme,
        //   trailingText: 'Light',
        // ),
      ],
    );
  }

  Widget _buildHelpCard() {
    return _buildCardWrap(
      children: [
        ProfileMenuTile(
          icon: Icons.chat_bubble_outline_rounded,
          title: AppStrings.helpSupport,
          onTap: () => AppSnackBar.warning(AppStrings.comingSoon),
        ),
        Divider(height: 1, color: AppColors.borderGrey.withValues(alpha: 0.5)),
        ProfileMenuTile(
          icon: Icons.shield_outlined,
          title: AppStrings.privacyTerms,
          onTap: () =>
              UrlLauncherUtils.openExternal(UrlConstants.urlPrivacyPolicy),
        ),
        Divider(height: 1, color: AppColors.borderGrey.withValues(alpha: 0.5)),
        ProfileMenuTile(
          icon: Icons.add_circle_outline_rounded,
          title: AppStrings.studentProfileTellUsWhatSMissing,
          onTap: () => Get.toNamed(AppRoutes.studentFeedback),
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required String header,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: () {
        onPressed();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Text(
            header,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(
          AppStrings.deleteAccountConfirmTitle,
          style: AppTextStyles.outfit(fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppStrings.deleteAccountConfirmMessage,
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
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Text(
              AppStrings.deleteAccountConfirmButton,
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

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
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
                await Get.find<AuthRepository>().logout('STUDENT');
              } catch (_) {}
              final authService = Get.find<AuthService>();
              await authService.clearSession();
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
}

class _AvatarPersonFallback extends StatelessWidget {
  const _AvatarPersonFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.person_rounded,
        size: 44,
        color: AppColors.primaryBrand,
      ),
    );
  }
}

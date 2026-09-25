import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/data/models/institute_profile_model.dart';
import 'package:tuoora/presentation/institute/controllers/institute_profile_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstituteSettingsScreen extends StatelessWidget {
  const InstituteSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstituteProfileController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: 'Settings', isRoot: false),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.profile.value == null) {
                  return const CommonLoading();
                }

                final p = controller.profile.value;
                if (p == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.redAccent,
                        ),
                        AppSpacing.v16,
                        const Text(AppStrings.errFailedLoadProfile),
                        AppSpacing.v16,
                        ElevatedButton(
                          onPressed: () => controller.fetchProfile(),
                          child: const Text(AppStrings.labelRetry),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchProfile(),
                  color: AppColors.primaryBrand,
                  child: SingleChildScrollView(
                    padding: AppSpacing.all16,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildActiveSessionsCard(context, controller),
                        AppSpacing.v16,
                        _buildAccountCard(context),
                        AppSpacing.v12,
                      ],
                    ),
                  ),
                );
              }),
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

  Widget _buildAccountCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardSectionHeader('Account & Security', Icons.security_rounded),
          _buildSettingsItem(
            icon: Icons.lock_outline_rounded,
            title: AppStrings.labelChangePassword,
            subtitle: AppStrings.updateYourLoginCredentials,
            onTap: () => Get.toNamed(AppRoutes.instituteChangePassword),
            isLast: true,
          ),
          // WhatsApp Integration is unfinished (coming-soon placeholder) —
          // hidden until the feature actually ships.
        ],
      ),
    );
  }

  Widget _cardSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBrand),
          AppSpacing.h8,
          Text(
            title,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool isLast = false,
    bool isComingSoon = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 8, 4, isLast ? 8 : 12),
        child: Row(
          children: [
            Container(
              padding: AppSpacing.all8,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryBrand).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? AppColors.primaryBrand,
              ),
            ),
            AppSpacing.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: iconColor ?? AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isComingSoon) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrandLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'COMING SOON',
                  style: AppTextStyles.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBrand,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              AppSpacing.h8,
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActiveSessionsCard(
    BuildContext context,
    InstituteProfileController controller,
  ) {
    final p = controller.profile.value;
    if (p == null) return const SizedBox.shrink();
    final sessions = p.activeSessions;
    if (sessions == null || sessions.isEmpty) return const SizedBox.shrink();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.devices_rounded,
                      size: 18,
                      color: AppColors.primaryBrand,
                    ),
                    AppSpacing.h8,
                    Text(
                      'Active Devices & Sessions',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBrand.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Text(
                    sessions.length <= 5
                        ? '${sessions.length} / 5 Devices'
                        : '${sessions.length} Devices',
                    style: AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...sessions.map((session) {
            final isCurrent = session.isCurrent == true;
            final isApp = session.isApp == true || session.sessionType == 'app';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: AppColors.scaffoldBg,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(
                  color: AppColors.fieldBorder.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: AppSpacing.all8,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.cardRadius,
                      ),
                    ),
                    child: Icon(
                      isApp
                          ? Icons.phone_android_rounded
                          : Icons.desktop_windows_rounded,
                      color: AppColors.primaryBrand,
                      size: 18,
                    ),
                  ),
                  AppSpacing.h12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                session.device ?? 'Unknown Device',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            AppSpacing.h6,
                            _buildBadge(
                              isApp ? 'APP' : 'WEB',
                              isApp
                                  ? AppColors.studentUpdateIconColor
                                  : AppColors.studentProgressBlue,
                              AppColors.studentUpdateIconBg,
                            ),
                            if (isCurrent) ...[
                              AppSpacing.h6,
                              _buildBadge(
                                'CURRENT',
                                AppColors.successGreen,
                                AppColors.successBg,
                              ),
                            ],
                          ],
                        ),
                        AppSpacing.v4,
                        Text(
                          '${session.os ?? "Unknown OS"} • Active ${_formatTimeAgo(session.lastOpen ?? session.lastLogin)}',
                          style: AppTextStyles.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h8,
                  TextButton(
                    onPressed: () =>
                        _confirmLogoutSession(context, controller, session),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.bohoRed.withValues(
                        alpha: 0.05,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      AppStrings.logOut,
                      style: AppTextStyles.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bohoRed,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Text(
        text,
        style: AppTextStyles.outfit(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatTimeAgo(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '1 second ago';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final difference = DateTime.now().difference(dateTime);
      if (difference.inSeconds < 60) {
        return '1 second ago';
      } else if (difference.inMinutes < 60) {
        final m = difference.inMinutes;
        return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
      } else if (difference.inHours < 24) {
        final h = difference.inHours;
        return '$h ${h == 1 ? 'hour' : 'hours'} ago';
      } else {
        final d = difference.inDays;
        return '$d ${d == 1 ? 'day' : 'days'} ago';
      }
    } catch (_) {
      return 'recently';
    }
  }

  void _confirmLogoutSession(
    BuildContext context,
    InstituteProfileController controller,
    ActiveSessions session,
  ) {
    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(
          'Log Out Device',
          style: AppTextStyles.outfit(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to remove ${session.device ?? "this device"}?',
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
              if (session.id != null) {
                controller.deleteDeviceSession(session.id!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
            ),
            child: Text(
              AppStrings.logout,
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/data/models/institute_profile_model.dart';
import 'package:tuoora/presentation/institute/controllers/institute_profile_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/app_version_label.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tuoora/core/services/auth_service.dart';
import 'package:tuoora/core/utils/url_launcher_utils.dart';
import 'package:tuoora/core/constants/url_constants.dart';
import 'package:tuoora/presentation/institute/view/institute_upi_payment_settings_screen.dart';

class InstituteProfileViewScreen extends StatelessWidget {
  const InstituteProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstituteProfileController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(
              title: AppStrings.instituteProfile,
              isRoot: false,
            ),
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
                        _buildHeaderCard(p),
                        AppSpacing.v16,
                        _buildContactCard(p),
                        AppSpacing.v16,
                        _buildActivePlanCard(),
                        AppSpacing.v16,
                        _buildUpiPaymentCard(context, controller),
                        AppSpacing.v16,
                        _buildSettingsNavigationCard(),
                        AppSpacing.v16,
                        _buildAddOnsNavigationCard(),
                        AppSpacing.v16,
                        _buildSupportCard(),
                        AppSpacing.v16,
                        _buildDeleteAccountCard(context, controller),
                        AppSpacing.v16,
                        _buildLogoutCard(context, controller),
                        AppSpacing.v16,
                        const AppVersionLabel(),
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

  Widget _buildHeaderCard(InstituteProfile p) {
    return _card(
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrandLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: p.logoUrl != null && p.logoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: p.logoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              _buildInitialsPlaceholder(p),
                          errorWidget: (context, url, error) =>
                              _buildInitialsPlaceholder(p),
                        )
                      : _buildInitialsPlaceholder(p),
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 44),
                      child: Text(
                        p.instituteName ?? p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    AppSpacing.v6,
                    Text(
                      'Owner: ${p.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    AppSpacing.v4,
                    Text(
                      'Code: ${p.instituteCode}',
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: AppColors.primaryBrandLight,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Get.toNamed(AppRoutes.instituteEditProfile),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsPlaceholder(InstituteProfile p) {
    String name = p.instituteName ?? p.name;
    String initials = 'IN';
    if (name.isNotEmpty) {
      List<String> parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      } else {
        initials = name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
      }
    }
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.outfit(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBrand,
        ),
      ),
    );
  }

  Widget _buildContactCard(dynamic p) {
    final address = [
      p.address,
      p.addressLine2,
      p.city,
      p.state,
      p.pincode,
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardSectionHeader('Contact Information', Icons.contact_page_rounded),
          _buildInfoRow(Icons.email_outlined, 'Email', p.email),
          _buildInfoRow(Icons.phone_outlined, 'Phone', p.phone),
          _buildInfoRow(
            Icons.map_outlined,
            'Address',
            address.isEmpty ? 'Not Provided' : address,
          ),
          if (p.website != null)
            _buildInfoRow(Icons.language_rounded, 'Website', p.website!),
        ],
      ),
    );
  }

  Widget _buildUpiPaymentCard(
    BuildContext context,
    InstituteProfileController controller,
  ) {
    return _card(
      child: Obx(() {
        final hasUpi = controller.hasUpiPayment;
        final qrUrl = controller.upiQrCodeUrl.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size: 18,
                    color: AppColors.primaryBrand,
                  ),
                  AppSpacing.h8,
                  Expanded(
                    child: Text(
                      AppStrings.upiPaymentDetailsCardTitle,
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (hasUpi)
                    InkWell(
                      onTap: () =>
                          _showUpiSettingsEditDialog(context, controller),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: AppColors.primaryBrand,
                            ),
                            AppSpacing.h4,
                            Text(
                              AppStrings.editSettings,
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBrand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    InkWell(
                      onTap: () =>
                          _showUpiSettingsEditDialog(context, controller),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 14,
                              color: AppColors.primaryBrand,
                            ),
                            AppSpacing.h4,
                            Text(
                              'Add',
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
              ),
            ),
            if (!hasUpi)
              _buildUpiEmptyState()
            else
              _buildUpiDetailsBody(context, controller.upiId.value, qrUrl),
          ],
        );
      }),
    );
  }

  Widget _buildUpiDetailsBody(
    BuildContext context,
    String upiId,
    String? qrUrl,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPI is configured',
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successGreen,
                  ),
                ),
                AppSpacing.v2,
                Text(
                  'Students can scan QR or pay via UPI ID',
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showUpiDetailsDialog(context, upiId, qrUrl),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: AppColors.primaryBrand,
                  ),
                  AppSpacing.h4,
                  Text(
                    'View',
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
      ),
    );
  }

  void _showUpiDetailsDialog(
    BuildContext context,
    String upiId,
    String? qrUrl,
  ) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'UPI Payment Details',
                    style: AppTextStyles.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              AppSpacing.v16,
              if (upiId.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.fieldBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.alternate_email_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      AppSpacing.h12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UPI ID',
                              style: AppTextStyles.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                            AppSpacing.v2,
                            Text(
                              upiId,
                              style: AppTextStyles.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.v16,
              ],
              if (qrUrl != null && qrUrl.isNotEmpty) ...[
                Container(
                  padding: AppSpacing.all8,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.fieldBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: qrUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                AppSpacing.v12,
                Text(
                  AppStrings.upiPaymentScanHint,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.upiPaymentEmptyTitle,
            style: AppTextStyles.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.v4,
          Text(
            AppStrings.upiPaymentEmptySubtitle,
            style: AppTextStyles.outfit(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard() {
    return Obx(() {
      final authService = Get.find<AuthService>();
      final sub = authService.subscription;
      if (sub == null) return const SizedBox.shrink();

      final int daysLeft = sub.daysLeft;
      final bool isExpiringSoon = sub.isExpireSoon;
      final dateFormat = DateFormat('dd MMM yyyy');

      Color statusColor = AppColors.successGreen;
      IconData statusIcon = Icons.verified_rounded;

      if (sub.isPending) {
        statusColor = AppColors.warningAmber;
        statusIcon = Icons.autorenew_rounded;
      } else if (sub.isReject || sub.isCancel || sub.isExpired) {
        statusColor = AppColors.errorRed;
        statusIcon = Icons.error_outline_rounded;
      }

      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subscription Status',
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(statusIcon, color: statusColor, size: 20),
              ],
            ),
            AppSpacing.v8,
            if (sub.endDate != null) ...[
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.cardRadius),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrandLight,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius,
                        ),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primaryBrand,
                        size: 16,
                      ),
                    ),
                    AppSpacing.h12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REMAINING',
                            style: AppTextStyles.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          AppSpacing.v4,
                          Text(
                            '$daysLeft days remaining — expires ${dateFormat.format(sub.endDate!)}',
                            style: AppTextStyles.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isExpiringSoon) ...[
                AppSpacing.v12,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    border: Border.all(
                      color: AppColors.warningAmber.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrandLight,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.primaryBrand,
                          size: 16,
                        ),
                      ),
                      AppSpacing.h12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXPIRING SOON',
                              style: AppTextStyles.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBrand,
                                letterSpacing: 0.8,
                              ),
                            ),
                            AppSpacing.v4,
                            Text(
                              'Expires in $daysLeft days — Renew now to avoid interruption',
                              style: AppTextStyles.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBrand,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            AppSpacing.v12,
            const Divider(height: 1, color: AppColors.fieldBorder),
            AppSpacing.v8,
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.instituteSubscription),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium_outlined,
                          size: 18,
                          color: AppColors.primaryBrand,
                        ),
                        AppSpacing.h8,
                        Text(
                          'Manage Subscription',
                          style: AppTextStyles.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBrand,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.primaryBrand,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSupportCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardSectionHeader('Support & Legal', Icons.info_outline_rounded),
          _buildSupportItem(
            icon: Icons.description_outlined,
            title: AppStrings.termsConditions,
            subtitle: AppStrings.readOurTermsOfService,
            onTap: () =>
                UrlLauncherUtils.openExternal(UrlConstants.urlTermsConditions),
          ),
          _buildSupportItem(
            icon: Icons.privacy_tip_outlined,
            title: AppStrings.privacyPolicy,
            subtitle: AppStrings.learnHowWeProtectYourData,
            onTap: () =>
                UrlLauncherUtils.openExternal(UrlConstants.urlPrivacyPolicy),
          ),
          _buildSupportItem(
            icon: Icons.help_center_outlined,
            title: AppStrings.helpSupport,
            subtitle: AppStrings.getAssistanceAndFaqs,
            onTap: () =>
                UrlLauncherUtils.openExternal(UrlConstants.urlHelpSupport),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
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
                color: AppColors.primaryBrand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primaryBrand),
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
                      color: AppColors.textPrimary,
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

  Widget _buildSettingsNavigationCard() {
    return _card(
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.instituteSettings),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.all8,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  size: 18,
                  color: AppColors.primaryBrand,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings & Security',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Manage active devices, logins, passwords & alert integrations',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOnsNavigationCard() {
    return _card(
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.instituteAddOns),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.all8,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: AppColors.primaryBrand,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add-ons',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'White Label branding and more, all in one place',
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutCard(
    BuildContext context,
    InstituteProfileController controller,
  ) {
    return _card(
      child: InkWell(
        onTap: () => _showLogoutDialog(context, controller),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.all8,
                decoration: BoxDecoration(
                  color: AppColors.bohoRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: AppColors.bohoRed,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.logout,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bohoRed,
                      ),
                    ),
                    Text(
                      AppStrings.signOutOfYourAccount,
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountCard(
    BuildContext context,
    InstituteProfileController controller,
  ) {
    return _card(
      child: InkWell(
        onTap: () => _showDeleteAccountDialog(context, controller),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.all8,
                decoration: BoxDecoration(
                  color: AppColors.bohoRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  size: 18,
                  color: AppColors.bohoRed,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.deleteAccount,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bohoRed,
                      ),
                    ),
                    Text(
                      AppStrings.deleteAccountSubtitle,
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    InstituteProfileController controller,
  ) {
    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(
          AppStrings.logout,
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
            onPressed: () {
              Get.back();
              controller.logout();
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

  void _showDeleteAccountDialog(
    BuildContext context,
    InstituteProfileController controller,
  ) {
    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(
          AppStrings.deleteAccountConfirmTitle,
          style: AppTextStyles.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          AppStrings.deleteAccountConfirmMessage,
          style: AppTextStyles.outfit(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
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
              backgroundColor: AppColors.bohoRed,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          AppSpacing.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.outfit(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                AppSpacing.v2,
                Text(
                  value,
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

  void _showUpiSettingsEditDialog(
    BuildContext context,
    InstituteProfileController controller,
  ) {
    Get.dialog(
      const InstituteUpiPaymentSettingsScreen(),
      barrierDismissible: false,
    );
  }
}

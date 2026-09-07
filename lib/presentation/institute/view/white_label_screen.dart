import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/constants/url_constants.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/subscription_manage_on_web_view.dart';
import 'package:tuoora/data/models/white_label_model.dart';
import 'package:tuoora/presentation/institute/controllers/white_label_controller.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

const _kColorPresets = [
  0xFFF97316, // Tuoora orange (default)
  0xFF2563EB, // blue
  0xFF16A34A, // green
  0xFF9333EA, // purple
  0xFFDC2626, // red
  0xFF0D9488, // teal
  0xFFDB2777, // pink
  0xFF111827, // near-black
];

class WhiteLabelScreen extends GetView<WhiteLabelController> {
  const WhiteLabelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Column(
            children: [
              const InstituteAppBar(title: 'White Label', isRoot: false),
              Expanded(
                child: SubscriptionManageOnWebView(
                  title: AppStrings.whiteLabelManageOnWebTitle,
                  message: AppStrings.whiteLabelManageOnWebMessage,
                  url: UrlConstants.urlInstituteWhiteLabel,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(title: 'White Label', isRoot: false),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoading();
                }

                final data = controller.status.value;
                if (data == null) {
                  return Center(
                    child: Text(
                      'Failed to load White Label status',
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchStatus,
                  color: AppColors.primaryBrand,
                  child: SingleChildScrollView(
                    padding: AppSpacing.all16,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: data.record?.isActive == true
                        ? _buildBrandingForm(data)
                        : _buildAddonCard(data.addon),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddonCard(WhiteLabelAddon addon) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: AppSpacing.s24,
            offset: const Offset(0, AppSpacing.s12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.all12,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrandLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryBrand,
                  size: 26,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Text(
                  addon.title,
                  style: AppTextStyles.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (addon.description.isNotEmpty) ...[
            AppSpacing.v16,
            Text(
              addon.description,
              style: AppTextStyles.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          AppSpacing.v20,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                addon.formattedPrice,
                style: AppTextStyles.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBrand,
                ),
              ),
              AppSpacing.h8,
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  addon.billingType,
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v24,
          Obx(
            () => AppButton(
              label: 'Buy Now',
              onPressed: addon.enabled ? controller.startPurchase : null,
              isDisabled: !addon.enabled,
              isLoading: controller.isPurchasing.value,
            ),
          ),
          if (!addon.enabled) ...[
            AppSpacing.v8,
            Text(
              'This add-on is not currently available for purchase.',
              textAlign: TextAlign.center,
              style: AppTextStyles.outfit(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBrandingForm(WhiteLabelStatus data) {
    final record = data.record!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildReviewStatusBanner(record),
        AppSpacing.v16,
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: AppSpacing.s24,
                offset: const Offset(0, AppSpacing.s12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your Branding',
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.v4,
              Text(
                'Once you submit, our team will confirm your logo and app name before publishing your app to the Play Store.',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              AppSpacing.v20,
              Center(child: _buildLogoPicker()),
              AppSpacing.v24,
              Text(
                'APP DISPLAY NAME',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fieldLabel,
                  letterSpacing: 1.0,
                ),
              ),
              AppSpacing.v8,
              Container(
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: TextField(
                  controller: controller.appNameController,
                  style: AppTextStyles.outfit(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Bright Future Academy',
                    hintStyle: AppTextStyles.outfit(
                      fontSize: 14,
                      color: AppColors.fieldLabel,
                    ),
                    border: InputBorder.none,
                    contentPadding: AppSpacing.all16,
                  ),
                ),
              ),
              AppSpacing.v24,
              Text(
                'PRIMARY COLOR',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fieldLabel,
                  letterSpacing: 1.0,
                ),
              ),
              AppSpacing.v8,
              Obx(
                () => _buildColorSwatches(
                  selected: controller.selectedPrimaryColor.value,
                  onSelect: controller.selectPrimaryColor,
                ),
              ),
              AppSpacing.v20,
              Text(
                'SECONDARY COLOR (OPTIONAL)',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fieldLabel,
                  letterSpacing: 1.0,
                ),
              ),
              AppSpacing.v8,
              Obx(
                () => _buildColorSwatches(
                  selected: controller.selectedSecondaryColor.value,
                  onSelect: controller.selectSecondaryColor,
                ),
              ),
              AppSpacing.v24,
              Obx(
                () => AppButton(
                  label: 'Submit Branding',
                  onPressed: controller.submitBranding,
                  isLoading: controller.isSubmittingBranding.value,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPicker() {
    return GestureDetector(
      onTap: controller.pickLogo,
      child: Obx(() {
        final localPath = controller.logoLocalPath.value;
        final existingUrl = controller.status.value?.record?.logoUrl;

        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.fieldBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: localPath != null
              ? Image.file(File(localPath), fit: BoxFit.cover)
              : (existingUrl != null && existingUrl.isNotEmpty)
              ? Image.network(existingUrl, fit: BoxFit.cover)
              : const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppColors.primaryBrand,
                  size: 32,
                ),
        );
      }),
    );
  }

  Widget _buildColorSwatches({
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _kColorPresets.map((value) {
        final hex = '#${value.toRadixString(16).substring(2).toUpperCase()}';
        final isSelected = selected?.toUpperCase() == hex;
        return GestureDetector(
          onTap: () => onSelect(hex),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(value),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.textPrimary : Colors.transparent,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewStatusBanner(WhiteLabelRecord record) {
    if (record.isReviewed) {
      return Container(
        padding: AppSpacing.all12,
        decoration: BoxDecoration(
          color: AppColors.successBg,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.successGreen,
              size: 18,
            ),
            AppSpacing.h8,
            Expanded(
              child: Text(
                'Confirmed by our team. Your app is being prepared for the Play Store.',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (record.brandingComplete) {
      return Container(
        padding: AppSpacing.all12,
        decoration: BoxDecoration(
          color: AppColors.primaryBrandLight,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              color: AppColors.primaryBrand,
              size: 18,
            ),
            AppSpacing.h8,
            Expanded(
              child: Text(
                'Branding submitted — our team will contact you to confirm before publishing.',
                style: AppTextStyles.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: AppSpacing.all12,
      decoration: BoxDecoration(
        color: AppColors.primaryBrandLight,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryBrand,
            size: 18,
          ),
          AppSpacing.h8,
          Expanded(
            child: Text(
              'Add-on active! Submit your app name and logo below to get started.',
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBrand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

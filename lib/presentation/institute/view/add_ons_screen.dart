import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/constants/url_constants.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_button.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/subscription_manage_on_web_view.dart';
import 'package:tuoora/presentation/institute/controllers/add_ons_controller.dart';
import 'package:tuoora/presentation/institute/models/add_on_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';

class AddOnsScreen extends GetView<AddOnsController> {
  const AddOnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        body: SafeArea(
          child: Column(
            children: [
              const InstituteAppBar(title: 'Add-ons', isRoot: false),
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
            const InstituteAppBar(title: 'Add-ons', isRoot: false),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const CommonLoading();
                }

                final addOns = controller.addOns;
                if (addOns.isEmpty) {
                  return Center(
                    child: Text(
                      'No add-ons available right now',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchAddOns,
                  color: AppColors.primaryBrand,
                  child: ListView.separated(
                    padding: AppSpacing.all16,
                    itemCount: addOns.length,
                    separatorBuilder: (_, __) => AppSpacing.v16,
                    itemBuilder: (context, index) => _AddOnCard(addOn: addOns[index]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddOnCard extends StatelessWidget {
  final AddOnModel addOn;

  const _AddOnCard({required this.addOn});

  @override
  Widget build(BuildContext context) {
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
                  size: 22,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Text(
                  addOn.title,
                  style: AppTextStyles.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (addOn.purchased)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
            ],
          ),
          if (addOn.description.isNotEmpty) ...[
            AppSpacing.v12,
            Text(
              addOn.description,
              style: AppTextStyles.outfit(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          AppSpacing.v16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                addOn.formattedPrice,
                style: AppTextStyles.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBrand,
                ),
              ),
              AppSpacing.h8,
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  addOn.billingType,
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.v16,
          _buildAction(),
        ],
      ),
    );
  }

  Widget _buildAction() {
    if (addOn.kind == AddOnKind.custom) {
      return AppButton(
        label: 'Manage',
        onPressed: () => Get.toNamed(AppRoutes.instituteWhiteLabel),
      );
    }

    if (addOn.purchased) {
      return AppButton(
        label: 'Active',
        onPressed: null,
        isDisabled: true,
        backgroundColor: AppColors.successGreen,
      );
    }

    final controller = Get.find<AddOnsController>();
    return Obx(() {
      final purchasing = controller.purchasingId.value == addOn.id;
      return AppButton(
        label: 'Buy Now',
        onPressed: addOn.enabled ? () => controller.startPurchase(addOn) : null,
        isDisabled: !addOn.enabled,
        isLoading: purchasing,
      );
    });
  }
}

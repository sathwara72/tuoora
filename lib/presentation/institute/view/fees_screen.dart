import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/presentation/institute/controllers/institute_controller.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InstituteFeesScreen extends GetView<InstituteController> {
  const InstituteFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.instFeesTitle,
              onBackTap: () => Get.back(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshFees(),
                color: AppColors.primaryBrand,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.x16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.v16,
                      Obx(
                        () => _buildTotalCollectedCard(
                          controller.currentMonthTotal.value,
                        ),
                      ),
                      AppSpacing.v24,
                      _buildRegistryHeader(controller),
                      AppSpacing.v16,
                      _buildRegistryList(controller),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionGuard.hideAddOnIOS
          ? null
          : FloatingActionButton(
              heroTag: 'fees_fab_unique_tag',
              onPressed: () => SubscriptionGuard.runAddAction(
                () => Get.toNamed(AppRoutes.instituteRecordFee),
              ),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white, size: 28),
            ),
    );
  }

  Widget _buildTotalCollectedCard(double amount) {
    return Container(
      padding: AppSpacing.cardPadding,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryBrand,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.instCurrentMonthCollected,
            style: AppTextStyles.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          AppSpacing.v12,
          Text(
            '₹${NumberFormat('#,##,###.##').format(amount)}',
            style: AppTextStyles.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistryHeader(InstituteController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.instFeeRegistry,
          style: AppTextStyles.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => controller.downloadFeeReport(),
          child: Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.primaryBrand,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: const Icon(Icons.download, color: AppColors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistryList(InstituteController controller) {
    return Obx(() {
      if (controller.isLoadingFees.value && controller.feeRecords.isEmpty) {
        return const Center(
          child: Padding(padding: EdgeInsets.all(32.0), child: CommonLoading()),
        );
      }

      if (controller.feeRecords.isEmpty) {
        return const AppEmptyView(
          icon: Icons.receipt_long_outlined,
          title: AppStrings.noFeeRecordsFound,
        );
      }

      return Column(
        children: controller.feeRecords.map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s10),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  Get.toNamed(AppRoutes.instituteFeeReceipt, arguments: record),
              child: _buildFeeItem(
                record.student?.name ?? '',
                '₹${record.totalAmount}',
                'ID: ${record.student?.enrollmentId}',
                record.date,
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildFeeItem(
    String name,
    String amount,
    String studentId,
    DateTime date,
  ) {
    return Container(
      padding: AppSpacing.cardPadding,
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
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBrandLight,
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: AppTextStyles.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBrand,
              ),
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      amount,
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                AppSpacing.v4,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      studentId,
                      style: AppTextStyles.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM, yyyy').format(date),
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

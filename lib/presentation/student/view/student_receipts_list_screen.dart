import 'package:flutter/material.dart';
import 'package:tuoora/core/utils/pull_refresh.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:tuoora/presentation/student/controllers/student_receipts_list_controller.dart';
import 'package:tuoora/presentation/student/models/fee_model.dart';
import 'package:tuoora/presentation/student/widgets/student_app_bar.dart';

class StudentReceiptsListScreen extends GetView<StudentReceiptsListController> {
  const StudentReceiptsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const StudentAppBar(
              title: AppStrings.labelReceipts,
              showDefaultActions: false,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && !PullRefresh.active.value) {
                  return const CommonLoading(color: AppColors.primaryBrand);
                }
                final items = controller.receipts;
                if (items.isEmpty) {
                  return const AppEmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: AppStrings.noReceiptsAvailableYet,
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primaryBrand,
                  onRefresh: () => PullRefresh.run(controller.loadReceipts),
                  child: ListView.separated(
                    padding: AppSpacing.screenPaddingTop,
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.s10),
                    itemBuilder: (context, index) {
                      final receipt = items[index];
                      return _ReceiptCard(
                        receipt: receipt,
                        onTap: () => controller.openReceipt(receipt),
                      );
                    },
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

class _ReceiptCard extends StatelessWidget {
  final StudentReceipt receipt;
  final VoidCallback onTap;

  const _ReceiptCard({required this.receipt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: AppColors.borderGrey.withValues(alpha: 0.5),
            ),
          ),
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              AppSpacing.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.receiptNumber.isNotEmpty
                          ? receipt.receiptNumber
                          : 'Receipt #${receipt.id}',
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (receipt.date.isNotEmpty) receipt.date,
                        if (receipt.paymentMethod.isNotEmpty)
                          receipt.paymentMethod,
                      ].join('  ·  '),
                      style: AppTextStyles.outfit(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppSpacing.h8,
              Text(
                '₹${receipt.amount}',
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

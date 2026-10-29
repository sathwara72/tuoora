import 'package:tuoora/core/utils/currency_utils.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:flutter/material.dart';

class FeeTransactionHistoryScreen extends StatelessWidget {
  const FeeTransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const InstituteAppBar(
              title: AppStrings.instFeeTransactionHistoryTitle,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.all24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    AppSpacing.v32,
                    Text(
                      AppStrings.pastTransactions,
                      style: AppTextStyles.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.v16,
                    _buildTransactionList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: AppSpacing.all24,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBrand, AppColors.textDarkGrey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBrand.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.totalFeesCollected,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
              Text(
                AppStrings.status,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.k1245000,
                style: AppTextStyles.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
              Text(
                AppStrings.active,
                style: AppTextStyles.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      {
        'date': 'Oct 15, 2023',
        'amount': '₹2,500.00',
        'method': 'UPI',
        'status': 'Successful',
      },
      {
        'date': 'Sep 12, 2023',
        'amount': '₹2,500.00',
        'method': 'Cash',
        'status': 'Successful',
      },
      {
        'date': 'Aug 10, 2023',
        'amount': '₹2,500.00',
        'method': 'UPI',
        'status': 'Successful',
      },
      {
        'date': 'Jul 14, 2023',
        'amount': '₹2,500.00',
        'method': 'UPI',
        'status': 'Successful',
      },
      {
        'date': 'Jun 08, 2023',
        'amount': '₹2,450.00',
        'method': 'Online',
        'status': 'Successful',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => AppSpacing.v16,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Container(
          padding: AppSpacing.all16,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLightGray),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tx['method'] == 'UPI'
                      ? Icons.phonelink_ring_rounded
                      : Icons.money_rounded,
                  color: AppColors.primaryBrand,
                ),
              ),
              AppSpacing.h16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['date']!,
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AppSpacing.v4,
                    Text(
                      'Payment via ${tx['method']}',
                      style: AppTextStyles.outfit(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRupees(tx['amount']),
                    style: AppTextStyles.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.v4,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tx['status']!,
                      style: AppTextStyles.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greenText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

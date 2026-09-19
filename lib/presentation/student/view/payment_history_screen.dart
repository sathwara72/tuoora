import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/widgets/payment_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/widgets/app_back_button.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final String title;
  final bool showBottomNav;
  const PaymentHistoryScreen({
    super.key,
    required this.title,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leadingWidth: 64,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Center(child: AppBackButton()),
        ),
        title: Text(
          title,
          style: AppTextStyles.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkSlate,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _buildMonthHeader('October 2023'),
          const PaymentItemTile(
            title: AppStrings.tuitionTerm1,
            date: 'Oct 02, 2023',
            ref: '#AE-9921',
            amount: '₹1,800.00',
          ),
          AppSpacing.v16,
          const PaymentItemTile(
            title: AppStrings.libraryOverdueFine,
            date: 'Oct 01, 2023',
            ref: '#AE-9850',
            amount: '₹15.00',
          ),
          AppSpacing.v32,
          _buildMonthHeader('September 2023'),
          const PaymentItemTile(
            title: AppStrings.annualSportsFee,
            date: 'Sept 15, 2023',
            ref: '#AE-8840',
            amount: '₹150.00',
          ),
          AppSpacing.v16,
          const PaymentItemTile(
            title: AppStrings.labMaintenance,
            date: 'Sept 10, 2023',
            ref: '#AE-8720',
            amount: '₹25.00',
          ),
          AppSpacing.v32,
          _buildMonthHeader('August 2023'),
          const PaymentItemTile(
            title: AppStrings.registrationCharges,
            date: 'Aug 01, 2023',
            ref: '#AE-8120',
            amount: '₹300.00',
          ),
          AppSpacing.v16,
          const PaymentItemTile(
            title: AppStrings.idCardReplacement,
            date: 'Aug 01, 2023',
            ref: '#AE-8110',
            amount: '₹10.00',
          ),
          AppSpacing.v24,
        ],
      ),
    );
  }

  Widget _buildMonthHeader(String month) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Text(
        month.toUpperCase(),
        style: AppTextStyles.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

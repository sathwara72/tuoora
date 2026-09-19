import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/expense_controller.dart';
import 'package:tuoora/presentation/institute/models/expense_model.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/core/widgets/app_empty_view.dart';
import 'package:tuoora/core/widgets/common_loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends GetView<ExpenseController> {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            InstituteAppBar(
              title: AppStrings.expensesOverview,
              actions: [
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.instituteExpenseAnalysis),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: AppColors.primaryBrand,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.expenses.isEmpty) {
                  return const CommonLoading();
                }
                if (controller.expenses.isEmpty) {
                  return const AppEmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: AppStrings.noExpensesFound,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => controller.loadExpenses(),
                  color: AppColors.primaryBrand,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppSpacing.screenPaddingTop.add(
                      const EdgeInsets.only(bottom: 96),
                    ),
                    itemCount: controller.expenses.length,
                    separatorBuilder: (context, index) => AppSpacing.v10,
                    itemBuilder: (context, index) {
                      final expense = controller.expenses[index];
                      return _buildExpenseCard(expense);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionGuard.hideAddOnIOS
          ? null
          : FloatingActionButton(
              onPressed: () => SubscriptionGuard.runAddAction(() {
                controller.resetForm();
                Get.toNamed(AppRoutes.instituteAddExpense);
              }),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white),
            ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: AppSpacing.all8,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.all8,
            decoration: BoxDecoration(
              color: expense.iconBgColor,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Icon(
              expense.icon,
              color: _getIconColor(expense.iconBgColor),
              size: 24,
            ),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.category?.name ?? "",
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.v4,
                Text(
                  dateFormat.format(expense.date),
                  style: AppTextStyles.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(expense.amount),
            style: AppTextStyles.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconColor(Color bgColor) {
    if (bgColor == AppColors.successBg) return AppColors.orangeTag;
    if (bgColor == AppColors.successBg) return AppColors.studentUpdateIconColor;
    if (bgColor == AppColors.successBg) return AppColors.subjectPhysics;
    if (bgColor == AppColors.successBg) return AppColors.greenText;
    if (bgColor == AppColors.successBg) return AppColors.textMuted;

    return AppColors.primaryBrand;
  }
}

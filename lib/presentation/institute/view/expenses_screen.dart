import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/expense_controller.dart';
import 'package:tuoora/presentation/institute/models/expense_model.dart';
import 'package:tuoora/presentation/institute/widgets/expense_widgets.dart';
import 'package:tuoora/presentation/institute/widgets/institute_app_bar.dart';
import 'package:tuoora/presentation/institute/widgets/month_selector_widget.dart';
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
            const InstituteAppBar(title: AppStrings.expensesOverview),
            _buildMonthSelector(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.expenses.isEmpty) {
                  return const CommonLoading();
                }

                final groups = controller.categoryGroups;

                return RefreshIndicator(
                  onRefresh: () => controller.loadExpenses(),
                  color: AppColors.primaryBrand,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    children: [
                      ExpenseHeroCard(
                        title: 'Total Spend',
                        total: controller.totalMonthlySpending,
                        monthLabel: DateFormat('MMMM yyyy').format(
                          controller.selectedExpensesMonth.value,
                        ),
                        stats: [
                          MapEntry('Categories', '${groups.length}'),
                          MapEntry(
                            'Transactions',
                            '${controller.expenses.length}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildIncludeSalaryToggle(),
                      const SizedBox(height: 16),
                      Text(
                        'Categories',
                        style: AppTextStyles.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (groups.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: AppEmptyView(
                            icon: Icons.receipt_long_outlined,
                            title: AppStrings.noExpensesFound,
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groups.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                mainAxisExtent: 128,
                              ),
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            return ExpenseCategoryGridTile(
                              icon: group.icon,
                              name: group.categoryName,
                              subtitle:
                                  '${group.count} ${group.count == 1 ? 'txn' : 'txns'}',
                              amount: group.totalAmount,
                              onTap: () =>
                                  _showTransactionsPopUp(context, group),
                            );
                          },
                        ),
                    ],
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
              mini: true,
              onPressed: () => SubscriptionGuard.runAddAction(() {
                controller.resetForm();
                Get.toNamed(AppRoutes.instituteAddExpense);
              }),
              backgroundColor: SubscriptionGuard.blocksAdd
                  ? AppColors.textMuted
                  : AppColors.primaryBrand,
              child: const Icon(Icons.add, color: AppColors.white, size: 20),
            ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Obx(() {
        final selectedDate = controller.selectedExpensesMonth.value;
        final isPrevEnabled = selectedDate.year > 2020;

        return MonthSelectorWidget(
          selectedMonth: selectedDate,
          onMonthChanged: (date) {
            controller.setExpensesMonth(date);
          },
          isNextEnabled: controller.canGoToNextExpensesMonth,
          isPrevEnabled: isPrevEnabled,
          minDate: DateTime(2020, 1),
          maxDate: DateTime.now(),
          helpText: 'Select Month',
        );
      }),
    );
  }

  Widget _buildIncludeSalaryToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrey),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      // The tile paints its ink on the nearest Material; the coloured
      // container above would hide it, so give the tile its own.
      child: Material(
        type: MaterialType.transparency,
        child: Obx(
          () => SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primaryBrand,
            title: Text(
              'Include staff salary in expenses',
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            value: controller.includeSalary.value,
            onChanged: controller.isTogglingSalary.value
                ? null
                : (value) => controller.toggleIncludeSalary(value),
          ),
        ),
      ),
    );
  }

  void _showTransactionsPopUp(BuildContext context, ExpenseCategoryGroup group) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 12, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: group.iconBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        group.icon,
                        color: group.color,
                        size: 20,
                      ),
                    ),
                    AppSpacing.h10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.categoryName,
                            style: AppTextStyles.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${group.count} ${group.count == 1 ? 'transaction' : 'transactions'} • Total: ${currencyFormat.format(group.totalAmount)}',
                            style: AppTextStyles.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!group.isSalary) ...[
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _editCategoryDialog(context, group),
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBrand, size: 19),
                        tooltip: 'Edit Category',
                      ),
                      AppSpacing.h8,
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _confirmDeleteCategory(context, group),
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 19),
                        tooltip: 'Delete Category',
                      ),
                    ],
                    AppSpacing.h8,
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.borderGrey),

              // Transactions list
              Expanded(
                child: group.transactions.isEmpty
                    ? const Center(child: Text('No transactions found'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: group.transactions.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 10,
                          thickness: 0.5,
                          color: AppColors.borderGrey,
                        ),
                        itemBuilder: (context, index) {
                          final transaction = group.transactions[index];
                          return _buildTransactionItem(transaction, currencyFormat);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editCategoryDialog(BuildContext context, ExpenseCategoryGroup group) {
    final textController = TextEditingController(text: group.categoryName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.edit_outlined, color: AppColors.primaryBrand, size: 22),
            AppSpacing.h8,
            Text(
              'Edit Category',
              style: AppTextStyles.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Name',
              style: AppTextStyles.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.v8,
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Maintenance, Utilities',
                hintStyle: AppTextStyles.outfit(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderGrey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryBrand, width: 1.5),
                ),
              ),
              style: AppTextStyles.outfit(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newName = textController.text.trim();
              if (newName.isEmpty) return;
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              controller.updateCategory(group.categoryId, newName);
            },
            child: Text(
              'Save',
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, ExpenseCategoryGroup group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
            AppSpacing.h8,
            Text(
              'Delete Category',
              style: AppTextStyles.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${group.categoryName}"? Any transactions in this category will be safely moved to "Other".',
          style: AppTextStyles.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet
              controller.deleteCategory(group.categoryId, group.categoryName);
            },
            child: Text(
              'Delete',
              style: AppTextStyles.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    ExpenseModel transaction,
    NumberFormat currencyFormat,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isOnline = transaction.paymentMethod == 'Online';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : 'No description',
                  style: AppTextStyles.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      dateFormat.format(transaction.date),
                      style: AppTextStyles.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    AppSpacing.h6,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppColors.studentProgressBlue.withValues(alpha: 0.1)
                            : AppColors.textTertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        transaction.paymentMethod,
                        style: AppTextStyles.outfit(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: isOnline
                              ? AppColors.studentProgressBlue
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.h8,
          Text(
            currencyFormat.format(transaction.amount),
            style: AppTextStyles.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBrand,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:tuoora/config/app_routes.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/utils/subscription_guard.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';
import 'package:tuoora/presentation/institute/controllers/expense_controller.dart';
import 'package:tuoora/presentation/institute/models/expense_model.dart';
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
            InstituteAppBar(
              title: AppStrings.expensesOverview,
              actions: [
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.instituteExpenseAnalysis),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: AppColors.primaryBrand,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            _buildMonthSelector(context),
            _buildTotalSpendingCard(),
            _buildCategoryFilterChips(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.expenses.isEmpty) {
                  return const CommonLoading();
                }

                final groups = controller.categoryGroups;
                if (groups.isEmpty) {
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
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                    itemCount: groups.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _buildCategoryCard(context, group);
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

  Widget _buildCategoryFilterChips() {
    return Obx(() {
      final allCategories = controller.categories;
      if (allCategories.isEmpty) return const SizedBox.shrink();

      final selectedId = controller.selectedCategoryFilter.value;

      return Container(
        height: 34,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            // "All" chip
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  'All',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selectedId == null ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
                selected: selectedId == null,
                selectedColor: AppColors.primaryBrand,
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: selectedId == null ? AppColors.primaryBrand : AppColors.borderGrey,
                  ),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onSelected: (_) => controller.setCategoryFilter(null),
              ),
            ),
            // Dynamic category chips
            ...allCategories.map((cat) {
              final isSelected = selectedId == cat.id;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    cat.name,
                    style: AppTextStyles.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBrand,
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryBrand : AppColors.borderGrey,
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: (selected) {
                    controller.setCategoryFilter(selected ? cat.id : null);
                  },
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildTotalSpendingCard() {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Obx(() {
      final total = controller.totalMonthlySpending;
      final categoryCount = controller.categoryGroups.length;
      final totalTransactions = controller.expenses.length;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spend',
                  style: AppTextStyles.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  currencyFormat.format(total),
                  style: AppTextStyles.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBrand.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$categoryCount ${categoryCount == 1 ? 'Category' : 'Categories'} • $totalTransactions ${totalTransactions == 1 ? 'Txn' : 'Txns'}',
                style: AppTextStyles.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBrand,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoryCard(BuildContext context, ExpenseCategoryGroup group) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTransactionsPopUp(context, group),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${group.count} ${group.count == 1 ? 'transaction' : 'transactions'}',
                        style: AppTextStyles.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
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
                      currencyFormat.format(group.totalAmount),
                      style: AppTextStyles.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View all',
                          style: AppTextStyles.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBrand,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 9,
                          color: AppColors.primaryBrand,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Flexible(
                child: group.transactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No transactions found'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shrinkWrap: true,
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

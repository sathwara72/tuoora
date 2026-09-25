import 'package:tuoora/core/utils/validation_utils.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/widgets/app_pickers.dart';
import 'package:tuoora/data/repositories_impl/institute_repository_impl.dart';
import 'package:tuoora/presentation/institute/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/api/api_exception.dart';
import 'package:tuoora/core/widgets/app_snack_bar.dart';
import 'package:intl/intl.dart';

class ExpenseController extends GetxController {
  final InstituteRepositoryImpl _repository;

  ExpenseController(this._repository);

  final expenses = <ExpenseModel>[].obs;
  final isLoading = false.obs;
  final isCategoriesLoading = false.obs;
  final categories = <ExpenseCategory>[].obs;

  // Filter States
  final selectedCategoryFilter = Rxn<int>();
  final selectedPaymentFilter = 'all'.obs;
  final searchQuery = ''.obs;

  void setCategoryFilter(int? categoryId) {
    selectedCategoryFilter.value = categoryId;
  }

  void setPaymentFilter(String payment) {
    selectedPaymentFilter.value = payment;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearFilters() {
    selectedCategoryFilter.value = null;
    selectedPaymentFilter.value = 'all';
    searchQuery.value = '';
  }

  // Expenses Month Filter State & Expanded Categories
  final selectedExpensesMonth = DateTime.now().obs;
  final expandedCategoryIds = <int>{}.obs;

  // Analysis State
  final expenseAnalysis = Rxn<ExpenseAnalysis>();
  final isAnalysisLoading = false.obs;
  final selectedAnalysisMonth = DateTime.now().obs;

  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalItems = 0.obs;

  // Add Expense Form Controllers
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedCategory = Rxn<ExpenseCategory>();
  final selectedDate = DateTime.now().obs;
  final isOnlinePayment = false.obs;
  final formKey = GlobalKey<FormState>();

  // Validation States (Pattern consistent with Add Student)
  final triedToSave = false.obs;
  final amountError = RxnString();
  final descriptionError = RxnString();
  final categoryError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
    loadCategories();
    loadExpenseAnalysis();

    // Listeners to clear errors as user types
    amountController.addListener(() {
      if (triedToSave.value) validateForm();
    });
    descriptionController.addListener(() {
      if (triedToSave.value) validateForm();
    });
    ever(selectedCategory, (_) {
      if (triedToSave.value) validateForm();
    });

    // Auto-refresh analysis when month changes
    ever(selectedAnalysisMonth, (_) => loadExpenseAnalysis());

    // Auto-refresh expenses when month changes
    ever(selectedExpensesMonth, (_) => loadExpenses());
  }

  bool validateForm() {
    bool isValid = true;

    // Amount validation
    final amountVal = ValidationUtils.validateAmount(
      amountController.text,
      'Amount',
    );
    amountError.value = amountVal;
    if (amountVal != null) isValid = false;

    // Description validation
    final descVal = ValidationUtils.validateRequired(
      descriptionController.text,
      'Description',
    );
    descriptionError.value = descVal;
    if (descVal != null) isValid = false;

    // Category validation
    final categoryVal = ValidationUtils.validateCategorySelection(
      selectedCategory.value,
    );
    categoryError.value = categoryVal;
    if (categoryVal != null) isValid = false;

    return isValid;
  }

  Future<void> loadExpenses({int page = 1}) async {
    if (isLoading.value && page != 1) return;

    try {
      if (page == 1) isLoading.value = true;
      final response = await _repository.listExpenses(
        page: page,
        month: selectedExpensesMonth.value.month,
        year: selectedExpensesMonth.value.year,
        perPage: 100,
      );

      if (page == 1) {
        expenses.assignAll(response.items);
      } else {
        expenses.addAll(response.items);
      }

      currentPage.value = response.currentPage;
      lastPage.value = response.lastPage;
      totalItems.value = response.total;
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    } finally {
      if (page == 1) isLoading.value = false;
    }
  }

  Future<void> loadMoreExpenses() async {
    if (currentPage.value < lastPage.value) {
      await loadExpenses(page: currentPage.value + 1);
    }
  }

  Future<void> loadCategories() async {
    try {
      isCategoriesLoading.value = true;
      final fetchedCategories = await _repository.getExpenseCategories();
      categories.assignAll(fetchedCategories);
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> createNewCategory(String name) async {
    try {
      final newCategory = await _repository.createExpenseCategory({'name': name});
      categories.add(newCategory);
      selectedCategory.value = newCategory;
      AppSnackBar.success('Category "$name" created successfully.');
    } catch (e) {
      debugPrint('Error creating category: $e');
      AppSnackBar.error('Failed to create category.');
    }
  }

  Future<void> updateCategory(int categoryId, String newName) async {
    try {
      final updated = await _repository.updateExpenseCategory(categoryId, {'name': newName});
      final index = categories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        categories[index] = updated;
      }
      if (selectedCategory.value?.id == categoryId) {
        selectedCategory.value = updated;
      }
      AppSnackBar.success('Category updated successfully.');
      await loadExpenses(page: 1);
      await loadCategories();
    } catch (e) {
      debugPrint('Error updating category: $e');
      AppSnackBar.error('Failed to update category.');
    }
  }

  Future<void> deleteCategory(int categoryId, String categoryName) async {
    try {
      await _repository.deleteExpenseCategory(categoryId);
      categories.removeWhere((c) => c.id == categoryId);
      if (selectedCategoryFilter.value == categoryId) {
        selectedCategoryFilter.value = null;
      }
      AppSnackBar.success('Category "$categoryName" deleted successfully.');
      await loadExpenses(page: 1);
      await loadCategories();
    } catch (e) {
      debugPrint('Error deleting category: $e');
      AppSnackBar.error('Failed to delete category.');
    }
  }

  Future<void> loadExpenseAnalysis() async {
    try {
      isAnalysisLoading.value = true;
      final month = DateFormat('MM').format(selectedAnalysisMonth.value);
      final year = DateFormat('yyyy').format(selectedAnalysisMonth.value);

      final analysis = await _repository.getExpenseAnalysis(month, year);

      // Sort categories by percentage descending (high first)
      analysis.categories.sort((a, b) => b.percentage.compareTo(a.percentage));

      expenseAnalysis.value = analysis;
    } catch (e) {
      debugPrint('Error loading analysis: $e');
      expenseAnalysis.value = null;
    } finally {
      isAnalysisLoading.value = false;
    }
  }

  bool get canGoToNextMonth {
    final now = DateTime.now();
    final currentView = selectedAnalysisMonth.value;
    // Cannot go beyond current month
    if (currentView.year < now.year) return true;
    if (currentView.year == now.year && currentView.month < now.month) {
      return true;
    }
    return false;
  }

  void nextAnalysisMonth() {
    if (!canGoToNextMonth) return;

    selectedAnalysisMonth.value = DateTime(
      selectedAnalysisMonth.value.year,
      selectedAnalysisMonth.value.month + 1,
    );
  }

  void prevAnalysisMonth() {
    selectedAnalysisMonth.value = DateTime(
      selectedAnalysisMonth.value.year,
      selectedAnalysisMonth.value.month - 1,
    );
  }

  void setAnalysisMonth(DateTime date) {
    selectedAnalysisMonth.value = DateTime(date.year, date.month);
  }


  bool get canGoToNextExpensesMonth {
    final now = DateTime.now();
    final currentView = selectedExpensesMonth.value;
    if (currentView.year < now.year) return true;
    if (currentView.year == now.year && currentView.month < now.month) {
      return true;
    }
    return false;
  }

  void nextExpensesMonth() {
    if (!canGoToNextExpensesMonth) return;
    selectedExpensesMonth.value = DateTime(
      selectedExpensesMonth.value.year,
      selectedExpensesMonth.value.month + 1,
    );
  }

  void prevExpensesMonth() {
    selectedExpensesMonth.value = DateTime(
      selectedExpensesMonth.value.year,
      selectedExpensesMonth.value.month - 1,
    );
  }

  void setExpensesMonth(DateTime date) {
    selectedExpensesMonth.value = DateTime(date.year, date.month);
  }

  void toggleCategoryExpanded(int categoryId) {
    if (expandedCategoryIds.contains(categoryId)) {
      expandedCategoryIds.remove(categoryId);
    } else {
      expandedCategoryIds.add(categoryId);
    }
  }

  bool isCategoryExpanded(int categoryId) => expandedCategoryIds.contains(categoryId);

  List<ExpenseCategoryGroup> get categoryGroups {
    final Map<int, List<ExpenseModel>> grouped = {};
    final Map<int, ExpenseCategory?> categoryMap = {};

    for (final cat in categories) {
      grouped[cat.id] = [];
      categoryMap[cat.id] = cat;
    }

    for (final exp in expenses) {
      final catId = exp.expenseCategoryId;
      if (!grouped.containsKey(catId)) {
        grouped[catId] = [];
        categoryMap[catId] = exp.category;
      }
      grouped[catId]!.add(exp);
    }

    final List<ExpenseCategoryGroup> groups = [];
    grouped.forEach((catId, items) {
      if (selectedCategoryFilter.value != null && selectedCategoryFilter.value != catId) {
        return;
      }

      final filteredItems = items.where((exp) {
        final matchPay = selectedPaymentFilter.value == 'all' ||
            exp.paymentMethod.toLowerCase() == selectedPaymentFilter.value.toLowerCase();
        final search = searchQuery.value.trim().toLowerCase();
        final matchSearch = search.isEmpty ||
            exp.description.toLowerCase().contains(search) ||
            exp.amount.toString().contains(search);
        return matchPay && matchSearch;
      }).toList();

      if ((selectedPaymentFilter.value != 'all' || searchQuery.value.trim().isNotEmpty) && filteredItems.isEmpty) {
        return;
      }

      final catName = categoryMap[catId]?.name ??
          (items.isNotEmpty && items.first.category?.name != null
              ? items.first.category!.name
              : 'Uncategorized');
      final double total = filteredItems.fold(0.0, (sum, item) => sum + item.amount);
      groups.add(
        ExpenseCategoryGroup(
          categoryId: catId,
          categoryName: catName,
          totalAmount: total,
          transactions: filteredItems,
          category: categoryMap[catId],
          isSalary: categoryMap[catId]?.isSalary ?? false,
        ),
      );
    });

    groups.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return groups;
  }

  double get totalMonthlySpending {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  void resetForm() {
    amountController.clear();
    descriptionController.clear();
    selectedCategory.value = null;
    selectedDate.value = DateTime.now();
    isOnlinePayment.value = false;
    triedToSave.value = false;
    amountError.value = null;
    descriptionError.value = null;
    categoryError.value = null;
  }

  void togglePaymentMethod(bool isOnline) {
    isOnlinePayment.value = isOnline;
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await AppPickers.date(
      context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> addExpense() async {
    triedToSave.value = true;
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      final Map<String, dynamic> data = {
        'expense_category_id': selectedCategory.value!.id.toString(),
        'amount': amountController.text,
        'date': selectedDate.value.toIso8601String().split('T')[0],
        'description': descriptionController.text,
        'payment_method': isOnlinePayment.value ? 'Online' : 'Cash',
      };

      await _repository.createExpense(data);

      Get.back();
      AppSnackBar.success(AppStrings.expenseAdded);
      resetForm();
      loadExpenses(page: 1);
      loadExpenseAnalysis();
    } catch (e) {
      if (e is ValidationException) {
        _handleValidationErrors(e.errors);
        AppSnackBar.error(AppStrings.validationErrorsBelow);
      } else {
        AppSnackBar.error(e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _handleValidationErrors(Map<String, dynamic> errors) {
    if (errors.containsKey('amount')) {
      amountError.value = (errors['amount'] as List).first.toString();
    }
    if (errors.containsKey('description')) {
      descriptionError.value = (errors['description'] as List).first.toString();
    }
    if (errors.containsKey('expense_category_id')) {
      categoryError.value = (errors['expense_category_id'] as List).first
          .toString();
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

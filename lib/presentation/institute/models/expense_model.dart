import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_colors.dart';

/// Virtual category id used for staff salary rows.
const int kSalaryCategoryId = -1;

class ExpenseCategory {
  final int id;
  final int instituteId;
  final String name;
  final bool isSalary;

  ExpenseCategory({
    required this.id,
    required this.instituteId,
    required this.name,
    this.isSalary = false,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      instituteId: json['institute_id'],
      name: json['name'],
      isSalary: json['is_salary'] == true || json['is_salary'] == 1,
    );
  }
}

class ExpenseModel {
  final int id;
  final int instituteId;
  final int expenseCategoryId;
  final double amount;
  final DateTime date;
  final String description;
  final String? receiptImage;
  final String paymentMethod;
  final ExpenseCategory? category;

  /// A paid staff salary shown as an expense: read-only.
  final bool isSalary;

  ExpenseModel({
    required this.id,
    required this.instituteId,
    required this.expenseCategoryId,
    required this.amount,
    required this.date,
    required this.description,
    this.receiptImage,
    required this.paymentMethod,
    this.category,
    this.isSalary = false,
  });

  /// A row from `expenses?category_id=salary` (id is `sal_<id>`, category is virtual).
  factory ExpenseModel.fromSalaryJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['salary_id'] is int
          ? json['salary_id']
          : int.tryParse('${json['salary_id']}') ?? 0,
      instituteId: 0,
      expenseCategoryId: kSalaryCategoryId,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
      paymentMethod: json['payment_method'] ?? 'Cash',
      category: ExpenseCategory(
        id: kSalaryCategoryId,
        instituteId: 0,
        name: 'Staff Salary',
        isSalary: true,
      ),
      isSalary: true,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      instituteId: json['institute_id'],
      expenseCategoryId: json['expense_category_id'] is String
          ? int.parse(json['expense_category_id'])
          : json['expense_category_id'],
      amount: json['amount'] is String
          ? double.parse(json['amount'])
          : (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
      receiptImage: json['receipt_image'],
      paymentMethod: json['payment_method'] ?? 'Cash',
      category: json['category'] != null
          ? ExpenseCategory.fromJson(json['category'])
          : null,
    );
  }

  IconData get icon {
    switch (category?.name) {
      case 'Bills':
        return Icons.bolt_rounded;
      case 'Shopping':
        return Icons.shopping_cart_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Food & Drink':
        return Icons.local_cafe_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color get iconBgColor {
    switch (category?.name) {
      case 'Bills':
        return AppColors.studentUpdateIconBg;
      case 'Shopping':
        return AppColors.warningBg;
      case 'Entertainment':
        return AppColors.scaffoldBg;
      case 'Food & Drink':
        return AppColors.successBg;
      case 'Transport':
        return AppColors.background;
      default:
        return AppColors.background;
    }
  }
}

class ExpenseListResponse {
  final List<ExpenseModel> items;
  final int total;
  final int currentPage;
  final int lastPage;
  final int perPage;

  ExpenseListResponse({
    required this.items,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
  });

  factory ExpenseListResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseListResponse(
      items: (json['items'] as List)
          .map((i) => ExpenseModel.fromJson(i))
          .toList(),
      total: json['total'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
    );
  }
}

class ExpenseCategoryGroup {
  final int categoryId;
  final String categoryName;
  final double totalAmount;
  final List<ExpenseModel> transactions;
  final ExpenseCategory? category;
  final bool isSalary;

  ExpenseCategoryGroup({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.transactions,
    this.category,
    this.isSalary = false,
  });

  int get count => transactions.length;

  IconData get icon => expenseCategoryIcon(categoryName);

  Color get color => AppColors.primaryBrand;

  Color get iconBgColor => color.withValues(alpha: 0.1);
}

IconData expenseCategoryIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('salary') || n.contains('staff')) return Icons.badge_rounded;
  if (n.contains('bill') || n.contains('electric') || n.contains('utilit')) {
    return Icons.bolt_rounded;
  }
  if (n.contains('rent')) return Icons.home_work_rounded;
  if (n.contains('shop') || n.contains('suppl') || n.contains('stationer')) {
    return Icons.shopping_bag_rounded;
  }
  if (n.contains('food') || n.contains('drink') || n.contains('tea')) {
    return Icons.local_cafe_rounded;
  }
  if (n.contains('transport') || n.contains('travel') || n.contains('fuel')) {
    return Icons.directions_car_rounded;
  }
  if (n.contains('entertain') || n.contains('event')) return Icons.movie_rounded;
  if (n.contains('market') || n.contains('advert')) return Icons.campaign_rounded;
  if (n.contains('repair') || n.contains('maint')) return Icons.build_rounded;
  return Icons.category_rounded;
}

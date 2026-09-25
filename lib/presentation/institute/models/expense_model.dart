import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_colors.dart';

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
  });

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

class CategoryAnalysis {
  final String categoryName;
  final double amount;
  final double percentage;

  CategoryAnalysis({
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  factory CategoryAnalysis.fromJson(Map<String, dynamic> json) {
    return CategoryAnalysis(
      categoryName: json['category_name'] ?? 'Unknown',
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class ExpenseAnalysis {
  final double totalSpending;
  final String monthName;
  final List<CategoryAnalysis> categories;

  ExpenseAnalysis({
    required this.totalSpending,
    required this.monthName,
    required this.categories,
  });

  factory ExpenseAnalysis.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ExpenseAnalysis(
      totalSpending: (data['total_spending'] as num).toDouble(),
      monthName: data['month_name'] ?? '',
      categories: (data['categories'] as List? ?? [])
          .map((c) => CategoryAnalysis.fromJson(c))
          .toList(),
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

  IconData get icon {
    switch (categoryName) {
      case 'Bills':
        return Icons.bolt_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Food & Drink':
        return Icons.local_cafe_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (categoryName) {
      case 'Bills':
        return AppColors.studentProgressBlue;
      case 'Shopping':
        return AppColors.warningAmber;
      case 'Entertainment':
        return AppColors.warningAmber;
      case 'Food & Drink':
        return AppColors.successGreen;
      case 'Transport':
        return AppColors.subjectPhysics;
      default:
        return AppColors.primaryBrand;
    }
  }

  Color get iconBgColor => color.withValues(alpha: 0.1);
}


/// `GET /institute/reports/profit-loss`: fee collections (income) against
/// expenses (plus paid staff salaries when the institute counts them).
class ProfitLossReport {
  final String periodLabel;
  final double totalIncome;
  final double totalExpense;
  final double netProfit;
  final bool isProfit;
  final double? profitMarginPercent;
  final bool includeSalaryInExpenses;
  final List<ProfitLossMonth> monthlyTrend;
  final double cashIncome;
  final double onlineIncome;
  final List<ProfitLossMethod> incomeByMethod;
  final List<ProfitLossBatch> topBatches;
  final List<ProfitLossCategory> expenseBreakdown;

  const ProfitLossReport({
    required this.periodLabel,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    required this.isProfit,
    this.profitMarginPercent,
    this.includeSalaryInExpenses = false,
    this.monthlyTrend = const [],
    this.cashIncome = 0,
    this.onlineIncome = 0,
    this.incomeByMethod = const [],
    this.topBatches = const [],
    this.expenseBreakdown = const [],
  });

  factory ProfitLossReport.fromJson(Map<String, dynamic> json) {
    final period = _map(json['period']);
    final summary = _map(json['summary']);
    final income = _map(json['income_breakdown']);
    final net = _d(summary['net_profit']);
    return ProfitLossReport(
      periodLabel: period['label']?.toString() ?? '',
      totalIncome: _d(summary['total_income']),
      totalExpense: _d(summary['total_expense']),
      netProfit: net,
      isProfit: summary['is_profit'] is bool
          ? summary['is_profit'] as bool
          : net >= 0,
      profitMarginPercent: summary['profit_margin_percent'] == null
          ? null
          : _d(summary['profit_margin_percent']),
      includeSalaryInExpenses: summary['include_salary_in_expenses'] == true,
      monthlyTrend: _list(json['monthly_trend'], ProfitLossMonth.fromJson),
      cashIncome: _d(income['cash']),
      onlineIncome: _d(income['online']),
      incomeByMethod: _list(income['by_method'], ProfitLossMethod.fromJson),
      topBatches: _list(income['top_batches'], ProfitLossBatch.fromJson),
      expenseBreakdown: _list(
        json['expense_breakdown'],
        ProfitLossCategory.fromJson,
      ),
    );
  }

  bool get isEmpty => totalIncome == 0 && totalExpense == 0;
}

class ProfitLossMonth {
  final String month;
  final String monthName;
  final double income;
  final double expense;
  final double profit;

  const ProfitLossMonth({
    required this.month,
    required this.monthName,
    required this.income,
    required this.expense,
    required this.profit,
  });

  factory ProfitLossMonth.fromJson(Map<String, dynamic> json) =>
      ProfitLossMonth(
        month: json['month']?.toString() ?? '',
        monthName: json['month_name']?.toString() ?? '',
        income: _d(json['income']),
        expense: _d(json['expense']),
        profit: _d(json['profit']),
      );

  /// "Apr" from "Apr 2026".
  String get shortName => monthName.split(' ').first;
}

class ProfitLossMethod {
  final String method;
  final double amount;
  final int count;

  const ProfitLossMethod({
    required this.method,
    required this.amount,
    required this.count,
  });

  factory ProfitLossMethod.fromJson(Map<String, dynamic> json) =>
      ProfitLossMethod(
        method: json['method']?.toString() ?? 'Other',
        amount: _d(json['amount']),
        count: int.tryParse(json['count']?.toString() ?? '') ?? 0,
      );
}

class ProfitLossBatch {
  final String batchName;
  final double amount;

  const ProfitLossBatch({required this.batchName, required this.amount});

  factory ProfitLossBatch.fromJson(Map<String, dynamic> json) =>
      ProfitLossBatch(
        batchName: json['batch_name']?.toString() ?? 'Unassigned',
        amount: _d(json['amount']),
      );
}

class ProfitLossCategory {
  final String categoryName;
  final double amount;
  final int count;
  final double percentage;
  final bool isSalary;

  const ProfitLossCategory({
    required this.categoryName,
    required this.amount,
    required this.count,
    required this.percentage,
    this.isSalary = false,
  });

  factory ProfitLossCategory.fromJson(Map<String, dynamic> json) =>
      ProfitLossCategory(
        categoryName:
            json['category_name']?.toString() ?? 'Other / Uncategorized',
        amount: _d(json['amount']),
        count: int.tryParse(json['count']?.toString() ?? '') ?? 0,
        percentage: _d(json['percentage']),
        isSalary: json['category_id']?.toString() == 'salary',
      );
}

double _d(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? v.cast<String, dynamic>() : const <String, dynamic>{};

List<T> _list<T>(dynamic v, T Function(Map<String, dynamic>) parse) =>
    v is List
    ? v.whereType<Map>().map((e) => parse(e.cast<String, dynamic>())).toList()
    : <T>[];

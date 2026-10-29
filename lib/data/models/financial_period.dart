import 'package:intl/intl.dart';

enum FinancialPeriodType { financialYear, currentYear, custom }

/// A reporting period for expenses and Profit & Loss, matching the server's
/// `filter_type` / `fy` / `start_date` / `end_date` query parameters.
/// Financial years run 1 April – 31 March.
class FinancialPeriod {
  final FinancialPeriodType type;

  /// First calendar year of the financial year (2026 = FY 2026-27).
  final int fyStartYear;
  final DateTime? customStart;
  final DateTime? customEnd;

  const FinancialPeriod._(
    this.type, {
    required this.fyStartYear,
    this.customStart,
    this.customEnd,
  });

  /// The financial year containing [now] (today by default).
  static int currentFyStartYear([DateTime? now]) {
    final d = now ?? DateTime.now();
    return d.month >= 4 ? d.year : d.year - 1;
  }

  factory FinancialPeriod.financialYear([int? fyStartYear]) =>
      FinancialPeriod._(
        FinancialPeriodType.financialYear,
        fyStartYear: fyStartYear ?? currentFyStartYear(),
      );

  factory FinancialPeriod.currentYear() => FinancialPeriod._(
    FinancialPeriodType.currentYear,
    fyStartYear: currentFyStartYear(),
  );

  factory FinancialPeriod.custom(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return FinancialPeriod._(
      FinancialPeriodType.custom,
      fyStartYear: currentFyStartYear(),
      customStart: s.isAfter(e) ? e : s,
      customEnd: s.isAfter(e) ? s : e,
    );
  }

  DateTime get start => switch (type) {
    FinancialPeriodType.financialYear => DateTime(fyStartYear, 4, 1),
    FinancialPeriodType.currentYear => DateTime(DateTime.now().year, 1, 1),
    FinancialPeriodType.custom => customStart!,
  };

  DateTime get end => switch (type) {
    FinancialPeriodType.financialYear => DateTime(fyStartYear + 1, 3, 31),
    FinancialPeriodType.currentYear => DateTime(DateTime.now().year, 12, 31),
    FinancialPeriodType.custom => customEnd!,
  };

  static String fyLabel(int startYear) =>
      'FY $startYear-${(startYear + 1).toString().substring(2)}';

  String get label {
    switch (type) {
      case FinancialPeriodType.financialYear:
        return fyLabel(fyStartYear);
      case FinancialPeriodType.currentYear:
        return '${DateTime.now().year}';
      case FinancialPeriodType.custom:
        final f = DateFormat('d MMM yyyy');
        return '${f.format(start)} – ${f.format(end)}';
    }
  }

  /// "1 Apr 2026 – 31 Mar 2027"
  String get rangeLabel {
    final f = DateFormat('d MMM yyyy');
    return '${f.format(start)} – ${f.format(end)}';
  }

  Map<String, String> toQuery() {
    final ymd = DateFormat('yyyy-MM-dd');
    switch (type) {
      case FinancialPeriodType.financialYear:
        return {'filter_type': 'financial_year', 'fy': '$fyStartYear'};
      case FinancialPeriodType.currentYear:
        return {'filter_type': 'current_year'};
      case FinancialPeriodType.custom:
        return {
          'filter_type': 'custom',
          'start_date': ymd.format(start),
          'end_date': ymd.format(end),
        };
    }
  }
}

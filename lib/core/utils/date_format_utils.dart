import 'dart:convert';
import 'package:intl/intl.dart';

/// Shared date-string helpers so different screens render the same date
/// the same way (e.g. homework due dates show "Today" / "Tomorrow" /
/// "May 30, 2026" consistently).
class DateFormatUtils {
  DateFormatUtils._();

  /// Returns the display label for a homework due date.
  ///
  /// - Closed (`isActive == false`) homework → "Ended MMM dd, yyyy".
  /// - Active homework due today → "Due Today".
  /// - Active homework due tomorrow → "Due Tomorrow".
  /// - Active homework due 2+ days from now (or in the past) → "Due MMM dd, yyyy".
  static String homeworkDueLabel(DateTime dueDate, {required bool isActive}) {
    final dateStr = DateFormat('MMM dd, yyyy').format(dueDate);
    if (!isActive) return 'Ended $dateStr';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;

    if (diff == 0) return 'Due Today';
    if (diff == 1) return 'Due Tomorrow';
    return 'Due $dateStr';
  }

  /// WhatsApp-style chat day separator label: AppStrings.studentTodayPill, "Yesterday", or a
  /// formatted date like "12 May 2026" for anything older.
  static String chatDaySeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(date.year, date.month, date.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Whether two timestamps fall on different calendar days (used to decide
  /// when to insert a day separator between consecutive chat messages).
  static bool isDifferentDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a != b;
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  /// Normalizes a dynamic input of days (List, comma-separated string,
  /// full day names like "Monday", or short names like "Mon") into a deduplicated,
  /// canonical ordered list of 3-letter day abbreviations:
  /// `['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']`.
  static List<String> normalizeDays(dynamic input) {
    if (input == null) return const [];
    List<dynamic> rawItems = [];
    if (input is List) {
      rawItems = input;
    } else if (input is String) {
      final trimmed = input.trim();
      if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) rawItems = decoded;
        } catch (_) {
          rawItems = trimmed
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .replaceAll("'", '')
              .split(',');
        }
      } else {
        rawItems = trimmed.split(',');
      }
    }

    final Set<String> normalizedSet = {};
    const dayMap = {
      'mon': 'Mon',
      'monday': 'Mon',
      'tue': 'Tue',
      'tues': 'Tue',
      'tuesday': 'Tue',
      'wed': 'Wed',
      'wednesday': 'Wed',
      'thu': 'Thu',
      'thur': 'Thu',
      'thurs': 'Thu',
      'thursday': 'Thu',
      'fri': 'Fri',
      'friday': 'Fri',
      'sat': 'Sat',
      'saturday': 'Sat',
      'sun': 'Sun',
      'sunday': 'Sun',
    };

    for (final item in rawItems) {
      if (item == null) continue;
      final parts = item.toString().split(',');
      for (final part in parts) {
        final key = part.trim().toLowerCase();
        if (key.isEmpty) continue;
        if (dayMap.containsKey(key)) {
          normalizedSet.add(dayMap[key]!);
        } else if (key.length >= 3 && dayMap.containsKey(key.substring(0, 3))) {
          normalizedSet.add(dayMap[key.substring(0, 3)]!);
        }
      }
    }

    const order = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = order.where((d) => normalizedSet.contains(d)).toList();
    return sorted.isNotEmpty ? sorted : normalizedSet.toList();
  }

  /// Formats days as a clean, deduplicated, comma-separated string (e.g. "Mon, Tue, Wed").
  static String formatDays(dynamic input) {
    final list = normalizeDays(input);
    if (list.isEmpty) return '';
    return list.join(', ');
  }
}

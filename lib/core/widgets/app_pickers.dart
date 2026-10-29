import 'package:flutter/material.dart';

import 'package:tuoora/core/constants/app_colors.dart';

/// Brand-themed wrappers for the Material date & time pickers so every
/// picker in the app uses the app's orange palette instead of the default
/// blue/teal. Pass [dateBuilder] / [timeBuilder] as the `builder:` argument
/// of `showDatePicker` / `showTimePicker`, or call [date] / [time] directly.
class AppPickers {
  AppPickers._();

  /// Retints any picker dialog to the brand colour scheme.
  static Widget _themed(BuildContext context, Widget? child) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: AppColors.primaryBrand,
          onPrimary: AppColors.white,
          secondary: AppColors.primaryBrand,
          onSecondary: AppColors.white,
          surface: AppColors.white,
          onSurface: AppColors.textPrimary,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: AppColors.white,
          headerBackgroundColor: AppColors.primaryBrand,
          headerForegroundColor: AppColors.white,
          todayForegroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.textMuted.withValues(alpha: 0.4);
              }
              return states.contains(WidgetState.selected)
                  ? AppColors.white
                  : AppColors.primaryBrand;
            },
          ),
          todayBackgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primaryBrand
                : Colors.transparent,
          ),
          // Disabled days (outside firstDate/lastDate) get a low-opacity
          // muted grey so they read clearly as untappable instead of looking
          // identical to live days.
          dayForegroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.textMuted.withValues(alpha: 0.4);
              }
              return states.contains(WidgetState.selected)
                  ? AppColors.white
                  : AppColors.textPrimary;
            },
          ),
          dayBackgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primaryBrand
                : Colors.transparent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColors.white,
          hourMinuteTextColor: AppColors.textPrimary,
          hourMinuteColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primaryBrand
                : AppColors.primaryBrandLight,
          ),
          dayPeriodTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.white
                : AppColors.textSecondary,
          ),
          dayPeriodColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primaryBrand
                : AppColors.primaryBrandLight,
          ),
          dialHandColor: AppColors.primaryBrand,
          dialBackgroundColor: AppColors.primaryBrandLight,
          dialTextColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.white
                : AppColors.textPrimary,
          ),
          entryModeIconColor: AppColors.primaryBrand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryBrand),
        ),
      ),
      child: child!,
    );
  }

  /// Use as the `builder:` of [showDatePicker].
  static Widget dateBuilder(BuildContext context, Widget? child) =>
      _themed(context, child);

  /// Use as the `builder:` of [showTimePicker]. Also forces the 12-hour
  /// layout (AM/PM toggle) regardless of device locale.
  static Widget timeBuilder(BuildContext context, Widget? child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
      child: _themed(context, child),
    );
  }

  /// Convenience for a brand-themed date picker.
  static Future<DateTime?> date(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: dateBuilder,
    );
  }

  /// Convenience for a brand-themed date range picker.
  static Future<DateTimeRange?> dateRange(
    BuildContext context, {
    DateTimeRange? initialRange,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
  }) {
    return showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      builder: dateBuilder,
    );
  }

  /// Convenience for a brand-themed (12-hour) time picker.
  static Future<TimeOfDay?> time(
    BuildContext context, {
    required TimeOfDay initialTime,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: timeBuilder,
    );
  }
}

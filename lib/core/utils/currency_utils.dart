/// Formatter utility for currency in the Indian Numbering System
/// (e.g. ₹5,000, ₹50,000, ₹5,00,000, ₹12,45,000, ₹1,00,00,000).
class CurrencyUtils {
  CurrencyUtils._();

  /// Formats a numeric value or numeric string into Indian currency notation
  /// (e.g. 5,000, 50,000, 5,00,000).
  ///
  /// [includeSymbol] prepends '₹' (default: true).
  /// [decimalDigits] forces exact decimal places. If null, displays integer
  /// numbers without decimals, and non-integer numbers with up to 2 decimal places.
  /// [trimZeroDecimals] if true and decimalDigits is null, drops trailing .00 (default: true).
  static String format(
    dynamic value, {
    bool includeSymbol = true,
    int? decimalDigits,
    bool trimZeroDecimals = true,
  }) {
    if (value == null) {
      return includeSymbol ? '₹0' : '0';
    }

    double? numVal;
    if (value is num) {
      numVal = value.toDouble();
    } else if (value is String) {
      final s = value.trim();
      if (s.isEmpty || s == '-') {
        return includeSymbol ? '₹0' : '0';
      }
      // Strip any existing currency symbols, commas, spaces
      final cleaned = s.replaceAll(RegExp(r'[^0-9.-]'), '');
      numVal = double.tryParse(cleaned);
      if (numVal == null) return value; // Return as-is if unparseable
    } else {
      return value.toString();
    }

    if (numVal.isNaN || numVal.isInfinite) {
      return includeSymbol ? '₹0' : '0';
    }

    final isNegative = numVal < 0;
    final absVal = numVal.abs();

    String formattedNumber;
    if (decimalDigits != null) {
      formattedNumber = _formatIndian(absVal.toStringAsFixed(decimalDigits));
    } else if (trimZeroDecimals && absVal == absVal.truncateToDouble()) {
      formattedNumber = _formatIndian(absVal.truncate().toString());
    } else {
      // Retain up to 2 decimals for fractional amounts
      final str = absVal.toStringAsFixed(2);
      if (trimZeroDecimals && str.endsWith('.00')) {
        formattedNumber = _formatIndian(str.substring(0, str.length - 3));
      } else {
        formattedNumber = _formatIndian(str);
      }
    }

    final sign = isNegative ? '-' : '';
    return includeSymbol ? '$sign₹$formattedNumber' : '$sign$formattedNumber';
  }

  /// Formats digits string with Indian comma grouping:
  /// First 3 digits from right, then groups of 2 digits
  /// (e.g. 5000 -> 5,000; 50000 -> 50,000; 500000 -> 5,00,000).
  static String _formatIndian(String numberStr) {
    final parts = numberStr.split('.');
    String intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    if (intPart.length > 3) {
      final last3 = intPart.substring(intPart.length - 3);
      String remaining = intPart.substring(0, intPart.length - 3);
      final List<String> chunks = [];
      while (remaining.length > 2) {
        chunks.insert(0, remaining.substring(remaining.length - 2));
        remaining = remaining.substring(0, remaining.length - 2);
      }
      if (remaining.isNotEmpty) {
        chunks.insert(0, remaining);
      }
      intPart = '${chunks.join(',')},$last3';
    }

    if (decPart != null && decPart.isNotEmpty) {
      return '$intPart.$decPart';
    }
    return intPart;
  }
}

/// Convenience helper to format values into Indian Rupees (e.g. ₹5,000, ₹50,000, ₹5,00,000).
String formatRupees(
  dynamic value, {
  bool includeSymbol = true,
  int? decimalDigits,
  bool trimZeroDecimals = true,
}) =>
    CurrencyUtils.format(
      value,
      includeSymbol: includeSymbol,
      decimalDigits: decimalDigits,
      trimZeroDecimals: trimZeroDecimals,
    );

extension NumCurrencyExtension on num {
  String toRupees({
    bool includeSymbol = true,
    int? decimalDigits,
    bool trimZeroDecimals = true,
  }) =>
      CurrencyUtils.format(
        this,
        includeSymbol: includeSymbol,
        decimalDigits: decimalDigits,
        trimZeroDecimals: trimZeroDecimals,
      );
}

extension StringCurrencyExtension on String {
  String toRupees({
    bool includeSymbol = true,
    int? decimalDigits,
    bool trimZeroDecimals = true,
  }) =>
      CurrencyUtils.format(
        this,
        includeSymbol: includeSymbol,
        decimalDigits: decimalDigits,
        trimZeroDecimals: trimZeroDecimals,
      );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tuoora/core/utils/currency_utils.dart';

void main() {
  test('groups rupees in thousands, lakhs and crores', () {
    for (final entry in <num, String>{
      0: '₹0',
      999: '₹999',
      5000: '₹5,000',
      50000: '₹50,000',
      500000: '₹5,00,000',
      1245000: '₹12,45,000',
      10000000: '₹1,00,00,000',
      -500000: '-₹5,00,000',
      500000.75: '₹5,00,000.75',
      99999.999: '₹1,00,000',
    }.entries) {
      expect(formatRupees(entry.key), entry.value);
    }
  });

  test('accepts API strings and existing formatted amounts', () {
    expect(formatRupees('500000.00'), '₹5,00,000');
    expect(formatRupees('₹500,000.50'), '₹5,00,000.50');
    expect(formatRupees('INR 500000'), '₹5,00,000');
    expect(formatRupees('-₹5,00,000'), '-₹5,00,000');
    expect(formatRupees('₹0.25'), '₹0.25');
  });

  test('supports symbol and decimal options', () {
    expect(formatRupees(500000, includeSymbol: false), '5,00,000');
    expect(formatRupees(500000, decimalDigits: 2), '₹5,00,000.00');
    expect(formatRupees(5000.5, decimalDigits: 0), '₹5,001');
  });

  test('handles missing and non-finite amounts', () {
    for (final value in [null, '', '-', double.nan, double.infinity]) {
      expect(formatRupees(value), '₹0');
    }
    expect(formatRupees('Unavailable'), 'Unavailable');
  });
}

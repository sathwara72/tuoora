import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuoora/presentation/institute/widgets/expense_widgets.dart';

void main() {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('expense summary shows Indian currency grouping', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExpenseHeroCard(
            title: 'Total expenses',
            total: 500000,
            monthLabel: 'FY 2026-27',
          ),
        ),
      ),
    );

    expect(find.text('₹5,00,000'), findsOneWidget);
    expect(find.text('Total expenses'), findsOneWidget);
    expect(find.text('FY 2026-27'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

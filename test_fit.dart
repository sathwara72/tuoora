import 'package:flutter/widgets.dart';
void main() {
  final box = FittedBox(
    fit: BoxFit.contain,
    child: SizedBox(width: 390, height: 1000),
  );
  // We can't easily run Flutter widget tests in a simple Dart script without a test environment.
}

import 'package:flutter/widgets.dart';

void main() {
  print("BoxConstraints.constrain(Size(390, 1000)) with minHeight: 500, maxHeight: 900");
  final c = BoxConstraints(minWidth: 390, maxWidth: 390, minHeight: 500, maxHeight: 900);
  print(c.constrain(Size(390, 1000)));
  print("BoxConstraints.constrain(Size(390, 600))");
  print(c.constrain(Size(390, 600)));
}

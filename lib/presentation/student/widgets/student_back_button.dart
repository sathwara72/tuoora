import 'package:flutter/material.dart';
import 'package:tuoora/core/widgets/app_back_button.dart';

/// Kept for existing call sites; renders the shared [AppBackButton].
class StudentBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const StudentBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) => AppBackButton(onTap: onTap);
}

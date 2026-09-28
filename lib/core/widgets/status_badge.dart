import 'package:flutter/material.dart';

import 'package:tuoora/core/constants/app_colors.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/theme/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;

  const StatusBadge._({required this.label, required this.backgroundColor});

  factory StatusBadge.success(String label) =>
      StatusBadge._(label: label, backgroundColor: AppColors.successGreen);

  factory StatusBadge.danger(String label) =>
      StatusBadge._(label: label, backgroundColor: AppColors.bohoRed);

  factory StatusBadge.reviewed(String label) =>
      StatusBadge._(label: label, backgroundColor: Colors.lightGreen);

  factory StatusBadge.fromLabel(String label) {
    final first = label.trim().toUpperCase().split(RegExp(r'\s+')).first;
    const successTokens = {'ACTIVE', 'SUBMITTED', 'OPEN', 'PAID', 'PRESENT'};
    const dangerTokens = {
      'PENDING',
      'CLOSED',
      'CANCELLED',
      'CANCELED',
      'OVERDUE',
      'DUE',
      'INACTIVE',
      'ABSENT',
    };
    if (first == 'REVIEWED') return StatusBadge.reviewed(label);
    if (successTokens.contains(first)) return StatusBadge.success(label);
    if (dangerTokens.contains(first)) return StatusBadge.danger(label);
    return StatusBadge.danger(label);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

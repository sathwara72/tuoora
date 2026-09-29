import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuoora/core/constants/app_colors.dart';

class AppTextStyles {
  /// App-wide font (Outfit). Use the recommended weight hierarchy:
  ///   - `w700` for big headers / page titles
  ///   - `w500` / `w600` for section headers
  ///   - `w400` for body / subtitle / descriptions
  static TextStyle outfit({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  // ============================================
  // PREDESIGNED SEMANTIC STYLES
  // ============================================

  // Headers (H1, H2, etc.)
  static TextStyle get h1 => outfit(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => outfit(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get h4 => outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Overlines (small spaced headers like 'PARENT DASHBOARD')
  static TextStyle get overlineLabel => outfit(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.primaryBrand,
  );

  static TextStyle get overlineMuted => outfit(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  // Body texts
  static TextStyle get bodyMuted => outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.5,
  );

  static TextStyle get bodySmall => outfit(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Special UI elements
  static TextStyle get largeAmount => outfit(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    height: 1.0,
  );

  static TextStyle get tinyBadge => outfit(
    fontSize: 8,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.textTertiary,
  );

  // ============================================
  // LEGACY THEME STYLES
  // (kept for callers that haven't migrated to the semantic getters)
  // ============================================
  static TextStyle get headline => outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get subtitle => outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => outfit(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get button =>
      outfit(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.white);
}

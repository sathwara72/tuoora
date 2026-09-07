import 'package:tuoora/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Mirrors AppColors.primaryBrand (the actual brand color used pervasively
  // throughout the app) rather than its own separate hardcoded value, so the
  // few default-Material-styled widgets that read the ColorScheme (rather
  // than an explicit AppColors.primaryBrand) pick up white-label builds too.
  static const Color primary = AppColors.primaryBrand;
  static const Color primaryContainer = AppColors.primaryBrandLight;
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FC);
  static const Color background = Color(0xFFFFFFFF);
  static const Color onPrimary = AppColors.white;
  static const Color onSurface = Color(0xFF1A1C1E);

  /// Design-system minimum tap height for every Material button.
  /// Applied via `_buttonMinSize` to ElevatedButton, TextButton, and
  /// OutlinedButton themes so raw buttons inherit it without per-call
  /// `styleFrom(minimumSize: ...)` plumbing.
  static const double _buttonHeight = 48;
  static const Size _buttonMinSize = Size(0, _buttonHeight);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      primaryContainer: primaryContainer,
      surface: surface,
      onPrimary: onPrimary,
      onSurface: onSurface,
    ),
    // Transparent so the global DottedBackground (wired in
    // GetMaterialApp.builder) shows through every Scaffold, including ones
    // that don't set their own backgroundColor.
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.outfit(fontSize: 16, color: onSurface),
      bodyMedium: GoogleFonts.outfit(fontSize: 14, color: onSurface),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: _buttonMinSize,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: _buttonMinSize,
        textStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: _buttonMinSize,
        textStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

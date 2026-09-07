import 'package:flutter/material.dart';

class AppColors {
  // --- White-label brand colors ---
  // Baked at BUILD TIME via --dart-define (not fetched at runtime): this app
  // is compiled per-institute (one build = one institute, per the white-label
  // flavor process — see tool/build_white_label.sh), so the brand color is
  // known before compilation and can stay a real compile-time constant.
  // int.fromEnvironment is itself a const expression, so every one of the
  // hundreds of `AppColors.primaryBrand` call sites across the app —
  // including ones inside `const` widgets — keeps working unchanged; only
  // this default value changes per build.
  static const Color primaryBrand = Color(
    int.fromEnvironment('BRAND_PRIMARY_COLOR', defaultValue: 0xFFF97316),
  );
  static const Color primaryBrandLight = Color(
    int.fromEnvironment('BRAND_PRIMARY_COLOR_LIGHT', defaultValue: 0xFFFEF4E8),
  );

  // --- Layout & Backgrounds ---
  static const Color scaffoldBg = Colors.transparent;
  static const Color surfaceBg = Color(0xFFF8F9FB);
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF5F5F5);
  static const Color fieldLabel = Color(0xFFA1A8B3);
  static const Color fieldBg = Color(0xFFF1F5F9);
  static const Color fieldBorder = Color(0xFFE2E8F0);
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color brandAppBarColor = Color(0xFF663322);
  static const Color instBrandOrange = Color(0xFFFF6600);
  static const Color successGreen = Color(0xFF10B981);
  static const Color green = Color(0xFF43A047);
  static const Color orangeTag = Color(0xFFC2410C);
  static const Color subjectPhysics = Color(0xFF06B6D4);

  // --- Typography ---
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDarkGrey = Color(0xFF374151);

  // --- Dividers & Borders ---
  static const Color borderGrey = Color(0xFFE5E7EB);
  static const Color borderLightGray = Color(0xFFD1D5DB);

  // --- Status & Functional ---
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color bohoRed = Color(0xFFD92D20);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color greenText = Color(0xFF065F46);
  static const Color skyBlueLight = Color(0xFFB9EFFF);
  static const Color error = Color(0xFFB00020);
  static const Color blueSapphire = Color(0xFF917B6B);

  // --- Student App Theme ---
  static const Color studentUpdateIconBg = Color(0xFFDBEAFE);
  static const Color studentUpdateIconColor = Color(0xFF1D4ED8);
  static const Color studentProgressBlue = Color(0xFF3B82F6);
  static const Color subjectPhysicsSoft = Color(0xFFCFFAFE);
  static const Color turquoiseBlue = Color(0xFF5EEAD4);
}

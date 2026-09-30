import 'package:flutter/material.dart';

// Spacing constants for the app
class AppSpacing {
  // Raw values (doubles)
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s18 = 18.0;
  static const double s20 = 20.0;
  static const double s22 = 22.0;
  static const double s24 = 24.0;
  static const double s26 = 26.0;
  static const double s28 = 28.0;
  static const double s32 = 32.0;
  static const double s36 = 36.0;
  static const double s40 = 40.0;
  static const double s44 = 44.0;
  static const double s48 = 48.0;
  static const double s52 = 52.0;
  static const double s54 = 54.0;
  static const double s56 = 56.0;
  static const double s60 = 60.0;
  static const double s64 = 64.0;
  static const double s72 = 72.0;
  static const double s80 = 80.0;
  static const double s88 = 88.0;
  static const double s100 = 100.0;
  static const double s140 = 140.0;
  static const double s144 = 144.0;
  static const double s160 = 160.0;
  static const double s180 = 180.0;
  static const double s240 = 240.0;
  static const double s260 = 260.0;

  // Vertical Spacing (SizedBox widgets)
  static const v2 = SizedBox(height: s2);
  static const v4 = SizedBox(height: s4);
  static const v6 = SizedBox(height: s6);
  static const v8 = SizedBox(height: s8);
  static const v10 = SizedBox(height: s10);
  static const v12 = SizedBox(height: s12);
  static const v16 = SizedBox(height: s16);
  static const v20 = SizedBox(height: s20);
  static const v24 = SizedBox(height: s24);
  static const v32 = SizedBox(height: s32);
  static const v40 = SizedBox(height: s40);
  static const v48 = SizedBox(height: s48);
  static const v80 = SizedBox(height: s80);
  static const v100 = SizedBox(height: s100);

  // Horizontal Spacing (SizedBox widgets)
  static const h4 = SizedBox(width: s4);
  static const h6 = SizedBox(width: s6);
  static const h8 = SizedBox(width: s8);
  static const h12 = SizedBox(width: s12);
  static const h10 = SizedBox(width: s10);
  static const h16 = SizedBox(width: s16);
  static const h20 = SizedBox(width: s20);
  static const h24 = SizedBox(width: s24);
  static const h32 = SizedBox(width: s32);

  // EdgeInsets (Common Padding & Margins)
  static const all4 = EdgeInsets.all(s4);
  static const all6 = EdgeInsets.all(s6);
  static const all8 = EdgeInsets.all(s8);
  static const all10 = EdgeInsets.all(s10);
  static const all12 = EdgeInsets.all(s12);
  static const all14 = EdgeInsets.all(s14);
  static const all16 = EdgeInsets.all(s16);
  static const all20 = EdgeInsets.all(s20);
  static const all24 = EdgeInsets.all(s24);
  static const all28 = EdgeInsets.all(s28);
  static const all32 = EdgeInsets.all(s32);

  // Horizontal Symmetric
  static const x6 = EdgeInsets.symmetric(horizontal: s6);
  static const x8 = EdgeInsets.symmetric(horizontal: s8);
  static const x10 = EdgeInsets.symmetric(horizontal: s10);
  static const x12 = EdgeInsets.symmetric(horizontal: s12);
  static const x14 = EdgeInsets.symmetric(horizontal: s14);
  static const x16 = EdgeInsets.symmetric(horizontal: s16);
  static const x20 = EdgeInsets.symmetric(horizontal: s20);
  static const x24 = EdgeInsets.symmetric(horizontal: s24);
  static const x28 = EdgeInsets.symmetric(horizontal: s28);
  static const x32 = EdgeInsets.symmetric(horizontal: s32);

  // Vertical Symmetric
  static const y2 = EdgeInsets.symmetric(vertical: s2);
  static const y4 = EdgeInsets.symmetric(vertical: s4);
  static const y6 = EdgeInsets.symmetric(vertical: s6);
  static const y8 = EdgeInsets.symmetric(vertical: s8);
  static const y10 = EdgeInsets.symmetric(vertical: s10);
  static const y12 = EdgeInsets.symmetric(vertical: s12);
  static const y14 = EdgeInsets.symmetric(vertical: s14);
  static const y16 = EdgeInsets.symmetric(vertical: s16);
  static const y18 = EdgeInsets.symmetric(vertical: s18);
  static const y20 = EdgeInsets.symmetric(vertical: s20);
  static const y24 = EdgeInsets.symmetric(vertical: s24);
  static const y32 = EdgeInsets.symmetric(vertical: s32);

  // Bottom Spacing
  static const EdgeInsets bottom10 = EdgeInsets.only(bottom: s10);
  static const EdgeInsets bottom12 = EdgeInsets.only(bottom: s12);
  static const EdgeInsets bottom16 = EdgeInsets.only(bottom: s16);
  static const EdgeInsets bottom20 = EdgeInsets.only(bottom: s20);

  // Top Spacing
  static const EdgeInsets top4 = EdgeInsets.only(top: s4);

  // Right Spacing
  static const EdgeInsets right16 = EdgeInsets.only(right: s16);

  // Semantic Spacing
  ///
  /// Design-system screen padding: 16 dp on left, right, and top.
  /// Bottom is 16 dp too — screens that want a different bottom should
  /// use [screenPaddingTop] (no bottom) or [screenPaddingWithBottom].
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(
    s16,
    s16,
    s16,
    s16,
  );

  /// Spec L:16, R:16, T:16, B:0 — for screens that supply their own
  /// bottom padding (e.g. scrollable bodies needing a tall safe-area
  /// gap below the last card).
  static const EdgeInsets screenPaddingTop = EdgeInsets.fromLTRB(
    s16,
    s16,
    s16,
    0,
  );

  /// Same as [screenPadding] but with a caller-controlled bottom.
  static EdgeInsets screenPaddingWithBottom(double bottom) =>
      EdgeInsets.fromLTRB(s16, s16, s16, bottom);

  static const headerPaddingLarge = EdgeInsets.fromLTRB(s28, s40, s28, s32);

  // ============================================
  // Card design-system tokens
  // ============================================
  /// Corner radius for any card surface (7 dp).
  static const double cardRadius = 7.0;

  /// Internal padding for any card surface (8 dp on all sides).
  static const EdgeInsets cardPadding = EdgeInsets.all(s8);
}

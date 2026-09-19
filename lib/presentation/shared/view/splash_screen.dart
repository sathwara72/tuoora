import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuoora/core/constants/app_strings.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';
import 'package:tuoora/core/widgets/app_logo.dart';
import 'package:tuoora/presentation/shared/controllers/splash_controller.dart';
import 'package:tuoora/presentation/shared/widgets/splash/splash_illustration.dart';

/// 3-second splash. One [AnimationController] drives every element; each
/// piece reads its own slice of the timeline (seconds in the comments):
///
///   0.0–0.5  logo fades in and scales 95% → 100%, soft glow behind it
///   0.5–1.2  logo glides up; feature icons rise in one by one
///   1.2–2.2  books slide up, graduation cap settles with a small bounce;
///            icons drift slowly around the illustration
///   2.2–2.7  brand message fades in
///   2.7–3.0  progress line completes, everything settles
///   3.0      the whole screen fades/scales out (see [SplashController])
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _totalSeconds = 3.0;

  late final AnimationController _c;

  // Softer than easeOutBack: ~4% overshoot for icons, ~8% for the cap.
  static const _softSpring = Cubic(0.34, 1.16, 0.64, 1.0);
  static const _capBounce = Cubic(0.3, 1.5, 0.6, 1.0);

  static const _icons = [
    (Icons.groups_rounded, SplashColors.orange, -145.0),
    (Icons.bar_chart_rounded, SplashColors.blue, -35.0),
    (Icons.calendar_month_rounded, SplashColors.green, 180.0),
    (Icons.currency_rupee_rounded, SplashColors.red, 0.0),
    (Icons.chat_bubble_rounded, SplashColors.purple, 148.0),
  ];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Progress (0..1, curved) of the slice [from]..[to] seconds.
  double _t(double from, double to, [Curve curve = Curves.linear]) {
    final raw = ((_c.value * _totalSeconds - from) / (to - from)).clamp(
      0.0,
      1.0,
    );
    return curve.transform(raw);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();
    return Scaffold(
      backgroundColor: SplashColors.mist,
      body: Obx(
        () => AnimatedOpacity(
          opacity: controller.exiting.value ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInCubic,
          child: AnimatedScale(
            scale: controller.exiting.value ? 1.04 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInCubic,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const RepaintBoundary(
                  child: CustomPaint(painter: SplashBackdropPainter()),
                ),
                LayoutBuilder(
                  builder: (context, box) => AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) => _scene(context, box.biggest),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scene(BuildContext context, Size size) {
    final w = size.width;
    final h = size.height;
    final padTop = MediaQuery.paddingOf(context).top;

    // ---- logo group -------------------------------------------------------
    const logoHeight = 64.0;
    const groupHeight = logoHeight + 8 + 14;
    final startTop = h * 0.5 - groupHeight / 2;
    final endTop = padTop + h * 0.085;
    final move = _t(0.5, 1.2, Curves.easeInOutCubic);
    final logoTop = startTop + (endTop - startTop) * move;
    final entrance = _t(0.0, 0.5, Curves.easeOutCubic);
    final logoScale = (0.95 + 0.05 * entrance) * (1 - 0.12 * move);
    final glow = _t(0.0, 0.8, Curves.easeOut) * (1 - 0.6 * _t(1.2, 2.2));

    // ---- orbit ------------------------------------------------------------
    final cx = w / 2;
    final cy = h * 0.52;
    final rx = w * 0.4;
    final ry = h * 0.165;
    final drift = _t(0.5, 3.0, Curves.easeInOut) * 0.45; // radians

    // ---- illustration -----------------------------------------------------
    final books = [
      for (var i = 0; i < 4; i++)
        _t(1.2 + i * 0.1, 1.75 + i * 0.1, Curves.easeOutCubic),
    ];
    final cap = _t(1.7, 2.25, _capBounce);
    final rays = _t(2.2, 2.6, Curves.easeOut);

    // ---- text + progress --------------------------------------------------
    final tag = _t(2.2, 2.7, Curves.easeOutCubic);
    final progress = _t(0.4, 3.0, Curves.easeInOutCubic);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Soft glow behind the logo.
        Positioned(
          left: cx - 150,
          top: logoTop + logoHeight / 2 - 90,
          child: Opacity(
            opacity: (glow * 0.55).clamp(0.0, 1.0),
            child: Container(
              width: 300,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    SplashColors.green.withValues(alpha: 0.16),
                    SplashColors.blue.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Logo + descriptor.
        Positioned(
          top: logoTop,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: entrance,
            child: Transform.scale(
              scale: logoScale,
              child: Column(
                children: [
                  const AppLogo(height: logoHeight),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.smartInstituteErp,
                    style: AppTextStyles.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Brand message.
        Positioned(
          top: endTop + groupHeight + 22,
          left: 24,
          right: 24,
          child: Opacity(
            opacity: tag,
            child: Transform.translate(
              offset: Offset(0, (1 - tag) * 14),
              child: Text(
                AppStrings.splashTagline,
                textAlign: TextAlign.center,
                style: AppTextStyles.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: SplashColors.ink,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),

        // Illustration.
        Positioned(
          left: cx - StackedBooks.width / 2,
          top: cy - StackedBooks.height / 2 + 6,
          child: RepaintBoundary(
            child: Transform.scale(
              scale: 1.12,
              child: StackedBooks(bookProgress: books, capProgress: cap),
            ),
          ),
        ),
        Positioned(
          left: cx - 60,
          top: cy - StackedBooks.height / 2 - 32,
          child: CapRays(progress: rays),
        ),

        // Orbiting feature icons.
        for (var i = 0; i < _icons.length; i++)
          _orbitIcon(i, cx, cy, rx, ry, drift),

        // Progress line.
        Positioned(
          left: w * 0.17,
          right: w * 0.17,
          top: h * 0.845,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 4,
              child: Stack(
                children: [
                  Container(color: const Color(0xFFE2ECEA)),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [SplashColors.green, Color(0xFF34D399)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _orbitIcon(
    int i,
    double cx,
    double cy,
    double rx,
    double ry,
    double drift,
  ) {
    final (icon, color, deg) = _icons[i];
    final appear = _t(0.5 + i * 0.1, 1.0 + i * 0.1, _softSpring);
    final fade = _t(0.5 + i * 0.1, 0.85 + i * 0.1, Curves.easeOut);
    final angle = deg * math.pi / 180 + drift;
    const size = 52.0;
    final x = cx + rx * math.cos(angle) - size / 2;
    final y = cy + ry * math.sin(angle) - size / 2 + (1 - appear) * 18;
    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: fade,
        child: FeatureBubble(icon: icon, color: color, size: size),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tuoora/core/constants/app_text_styles.dart';

/// Brand accents used by the splash animation.
class SplashColors {
  static const green = Color(0xFF0CAD6D);
  static const orange = Color(0xFFFF7A00);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFFA855F7);
  static const red = Color(0xFFF43F5E);
  static const ink = Color(0xFF1F2937);
  static const mist = Color(0xFFF8FBFF);
}

/// Soft coloured circle with a single glyph — one per product area.
class FeatureBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const FeatureBubble({
    super.key,
    required this.icon,
    required this.color,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.alphaBlend(color.withValues(alpha: 0.16), Colors.white),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}

class _BookSpec {
  final String label;
  final Color color;
  final double width;
  final double angle;
  final double dx;

  const _BookSpec(this.label, this.color, this.width, this.angle, this.dx);
}

/// Four stacked books topped by a graduation cap. Each book and the cap take
/// their own 0..1 progress so the parent can stagger them on one timeline.
class StackedBooks extends StatelessWidget {
  /// Bottom → top progress for the four books.
  final List<double> bookProgress;
  final double capProgress;

  const StackedBooks({
    super.key,
    required this.bookProgress,
    required this.capProgress,
  });

  static const double bookHeight = 46;
  static const double step = 36;
  static const double capWidth = 150;
  static const double capHeight = 70;
  static const double width = 240;
  static const double height = step * 3 + bookHeight + capHeight - 30;

  static const _books = [
    _BookSpec('Growth Together', SplashColors.red, 236, 0.02, 4),
    _BookSpec('Batches & Classes', SplashColors.orange, 224, -0.016, -8),
    _BookSpec('Fees & Payments', SplashColors.blue, 214, 0.024, 8),
    _BookSpec('Students', SplashColors.green, 200, -0.014, -4),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < _books.length; i++)
            Positioned(
              bottom: i * step,
              child: Opacity(
                opacity: bookProgress[i].clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(_books[i].dx, (1 - bookProgress[i]) * 36),
                  child: _Book(spec: _books[i]),
                ),
              ),
            ),
          Positioned(
            bottom: step * 3 + bookHeight - 20,
            child: Opacity(
              opacity: (capProgress * 2).clamp(0.0, 1.0),
              child: Transform.translate(
                // Overshooting progress (>1) dips slightly below rest, then
                // settles — the small natural bounce.
                offset: Offset(0, (1 - capProgress) * -46),
                child: const SizedBox(
                  width: capWidth,
                  height: capHeight,
                  child: CustomPaint(painter: _CapPainter()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Book extends StatelessWidget {
  final _BookSpec spec;

  const _Book({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: spec.angle,
      child: SizedBox(
        width: spec.width,
        height: StackedBooks.bookHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _BookPainter(spec.color)),
            ),
            Positioned(
              left: 24,
              top: 15,
              child: Text(
                spec.label,
                maxLines: 1,
                style:
                    AppTextStyles.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ).copyWith(
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A book seen slightly from above and the right: front spine, lit top
/// face, and a cream page block receding on the open end.
class _BookPainter extends CustomPainter {
  final Color color;

  const _BookPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const depth = 9.0; // how far the top face / pages recede
    const pagesW = 30.0;
    final frontR = w - pagesW;

    // Ground shadow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(6, h - 10, w - 4, h + 2),
        const Radius.circular(8),
      ),
      Paint()
        ..color = color.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Top face.
    final top = Path()
      ..moveTo(4, depth)
      ..lineTo(frontR, depth)
      ..lineTo(w - 2, 0)
      ..lineTo(depth + 4, 0)
      ..close();
    canvas.drawPath(
      top,
      Paint()..color = Color.lerp(color, Colors.white, 0.38)!,
    );

    // Page block on the open end.
    final pages = Path()
      ..moveTo(frontR, depth)
      ..lineTo(w - 2, 0)
      ..lineTo(w - 2, h - depth - 2)
      ..lineTo(frontR, h - 2)
      ..close();
    canvas.drawPath(
      pages,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBF2), Color(0xFFEBDDC2)],
        ).createShader(Rect.fromLTWH(frontR, 0, pagesW, h)),
    );
    final pageLine = Paint()
      ..color = const Color(0xFFB8A683).withValues(alpha: 0.55)
      ..strokeWidth = 0.8;
    for (var k = 1; k <= 4; k++) {
      final f = k / 5;
      canvas.drawLine(
        Offset(frontR + 2, depth + (h - 2 - depth) * f),
        Offset(w - 3, (h - depth - 2) * f),
        pageLine,
      );
    }

    // Front spine.
    final front = RRect.fromRectAndCorners(
      Rect.fromLTRB(0, depth, frontR, h - 2),
      topLeft: const Radius.circular(5),
      bottomLeft: const Radius.circular(5),
      topRight: const Radius.circular(2),
      bottomRight: const Radius.circular(2),
    );
    canvas.drawRRect(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, Colors.white, 0.14)!,
            Color.lerp(color, Colors.black, 0.16)!,
          ],
        ).createShader(front.outerRect),
    );

    // Spine bands near the left end and a soft top highlight.
    final band = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..strokeWidth = 1.4;
    canvas.drawLine(Offset(12, depth + 3), Offset(12, h - 5), band);
    canvas.drawLine(Offset(16, depth + 3), Offset(16, h - 5), band);
    canvas.drawLine(
      Offset(6, depth + 1.5),
      Offset(frontR - 4, depth + 1.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _BookPainter old) => old.color != color;
}

class _CapPainter extends CustomPainter {
  const _CapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final base = Path()
      ..moveTo(w * 0.24, h * 0.48)
      ..lineTo(w * 0.24, h * 0.76)
      ..quadraticBezierTo(w * 0.5, h * 1.0, w * 0.76, h * 0.76)
      ..lineTo(w * 0.76, h * 0.48)
      ..close();
    canvas.drawPath(
      base,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F2A44), Color(0xFF0F172A)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final board = Path()
      ..moveTo(0, h * 0.36)
      ..lineTo(w * 0.5, h * 0.08)
      ..lineTo(w, h * 0.36)
      ..lineTo(w * 0.5, h * 0.64)
      ..close();
    canvas.drawShadow(board, Colors.black.withValues(alpha: 0.35), 4, false);
    canvas.drawPath(
      board,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF334062), Color(0xFF111827)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Soft sheen along the upper-left face of the board.
    final sheen = Path()
      ..moveTo(w * 0.06, h * 0.35)
      ..lineTo(w * 0.5, h * 0.11)
      ..lineTo(w * 0.62, h * 0.18)
      ..lineTo(w * 0.22, h * 0.40)
      ..close();
    canvas.drawPath(
      sheen,
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );

    // Tassel: cord from the button to the right corner, then a hanging tuft.
    final cord = Paint()
      ..color = SplashColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.36)
        ..lineTo(w * 0.84, h * 0.4)
        ..lineTo(w * 0.86, h * 0.8),
      cord,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.835, h * 0.78, w * 0.05, h * 0.2),
        const Radius.circular(3),
      ),
      Paint()..color = SplashColors.orange,
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.36),
      3.2,
      Paint()..color = SplashColors.orange,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Short rays above the cap, shown once everything has settled.
class CapRays extends StatelessWidget {
  final double progress;

  const CapRays({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: progress.clamp(0.0, 1.0),
      child: SizedBox(
        width: 120,
        height: 26,
        child: CustomPaint(painter: _RaysPainter(progress)),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  final double t;

  const _RaysPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final base = size.height;
    final colors = [
      SplashColors.green,
      SplashColors.orange,
      SplashColors.green,
      SplashColors.orange,
      SplashColors.green,
    ];
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + (i - 2) * 0.42;
      final r0 = 14 + t * 2;
      final r1 = r0 + 8 + (i == 2 ? 4 : 0);
      canvas.drawLine(
        Offset(cx + math.cos(a) * r0 * 2, base + math.sin(a) * r0),
        Offset(cx + math.cos(a) * r1 * 2, base + math.sin(a) * r1),
        Paint()
          ..color = colors[i].withValues(alpha: 0.85)
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter old) => old.t != t;
}

/// Static backdrop: faint blue/green washes up top, mint hills and a leaf at
/// the bottom. Painted once and cached by the parent's RepaintBoundary.
class SplashBackdropPainter extends CustomPainter {
  const SplashBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, SplashColors.mist],
        ).createShader(Offset.zero & size),
    );

    canvas.drawCircle(
      Offset(w * 1.02, h * 0.06),
      w * 0.36,
      Paint()..color = const Color(0xFFEAF2FE).withValues(alpha: 0.85),
    );
    canvas.drawCircle(
      Offset(-w * 0.05, h * 0.30),
      w * 0.24,
      Paint()..color = const Color(0xFFE9F7F0).withValues(alpha: 0.7),
    );

    final back = Path()
      ..moveTo(0, h * 0.91)
      ..cubicTo(w * 0.22, h * 0.87, w * 0.42, h * 0.93, w * 0.68, h * 0.9)
      ..cubicTo(w * 0.84, h * 0.88, w * 0.94, h * 0.9, w, h * 0.89)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      back,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDF4E9), Color(0xFFC9EEDB)],
        ).createShader(Rect.fromLTWH(0, h * 0.86, w, h * 0.14)),
    );

    final front = Path()
      ..moveTo(0, h * 0.95)
      ..cubicTo(w * 0.28, h * 0.92, w * 0.5, h * 0.985, w * 0.78, h * 0.95)
      ..cubicTo(w * 0.9, h * 0.935, w * 0.96, h * 0.945, w, h * 0.94)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFFE7F8EF));

    _leaf(
      canvas,
      Offset(w * 0.93, h * 0.945),
      w * 0.11,
      -0.45,
      const Color(0xFF16A06A),
    );
    _leaf(
      canvas,
      Offset(w * 0.93, h * 0.945),
      w * 0.09,
      0.35,
      const Color(0xFF7ED9A9),
    );
    _leaf(
      canvas,
      Offset(w * 0.93, h * 0.945),
      w * 0.07,
      -1.0,
      const Color(0xFF34C58A),
    );
  }

  void _leaf(Canvas canvas, Offset origin, double len, double rot, Color c) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(rot);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.5, -len * 0.55, 0, -len)
      ..quadraticBezierTo(-len * 0.5, -len * 0.55, 0, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = c);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

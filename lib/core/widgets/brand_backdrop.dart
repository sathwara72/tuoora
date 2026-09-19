import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuoora/core/constants/app_strings.dart';

/// Shared background for the role-selection and login screens: soft colour
/// blobs, the teal/orange wave, an open-book sketch and the two handwritten
/// taglines flanking the logo.
class BrandBackdrop extends StatelessWidget {
  final Widget child;

  const BrandBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _BackdropPainter()),
          ),
        ),
        Positioned.fill(child: child),
        const Positioned(top: 0, left: 0, right: 0, child: _Taglines()),
      ],
    );
  }
}

class _Taglines extends StatelessWidget {
  const _Taglines();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Script(
                text: AppStrings.learnManageGrow,
                color: const Color(0xFF2D3A55),
                underline: 48,
              ),
              _Script(
                text: AppStrings.betterEducationBrighterTomorrow,
                color: const Color(0xFF8A94A8),
                underline: 56,
                alignEnd: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Script extends StatelessWidget {
  final String text;
  final Color color;
  final double underline;
  final bool alignEnd;

  const _Script({
    required this.text,
    required this.color,
    required this.underline,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.14,
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            text,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: GoogleFonts.caveat(fontSize: 19, height: 1.0, color: color),
          ),
          const SizedBox(height: 4),
          Container(
            width: underline,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFF6B94B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void blob(double cx, double cy, double r, Color c) =>
        canvas.drawCircle(Offset(w * cx, h * cy), w * r, Paint()..color = c);

    blob(0.0, 0.02, 0.13, const Color(0xFFEAF1FB));
    blob(1.0, 0.0, 0.20, const Color(0xFFEAF5EE));
    blob(-0.04, 0.30, 0.11, const Color(0xFFFDF0E4));
    blob(1.02, 0.36, 0.10, const Color(0xFFEAF1FB));
    blob(0.22, 0.92, 0.07, const Color(0xFFFDEBD8));
    blob(0.98, 0.90, 0.10, const Color(0xFFEAF5EE));

    final tealWave = Path()
      ..moveTo(0, h * 0.90)
      ..cubicTo(w * 0.15, h * 0.86, w * 0.30, h * 0.90, w * 0.50, h * 0.96)
      ..cubicTo(w * 0.58, h * 0.985, w * 0.62, h, w * 0.66, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      tealWave,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1FA593), Color(0xFF52C48A)],
        ).createShader(Rect.fromLTWH(0, h * 0.86, w * 0.66, h * 0.14)),
    );

    final orangeWave = Path()
      ..moveTo(w * 0.20, h)
      ..cubicTo(w * 0.36, h * 0.94, w * 0.62, h * 0.96, w, h * 0.925)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      orangeWave,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF7A23B), Color(0xFFFCD98A)],
        ).createShader(Rect.fromLTWH(w * 0.2, h * 0.92, w * 0.8, h * 0.08)),
    );

    paintBookSketch(canvas, Offset(w * 0.86, h * 0.925), w * 0.16);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Background for the login screens: blobs, a faded role illustration, a
/// single handwritten tagline top-right, an italic quote bottom-left and the
/// orange/teal hills along the bottom edge.
class LoginBackdrop extends StatelessWidget {
  final Widget child;
  final String image;
  final String tagline;
  final String quote;

  const LoginBackdrop({
    super.key,
    required this.child,
    required this.image,
    required this.tagline,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _LoginBackdropPainter()),
          ),
        ),
        Positioned(
          left: -18,
          top: 142,
          child: IgnorePointer(
            child: Container(
              width: 118,
              height: 118,
              decoration: const BoxDecoration(
                color: Color(0xFFFDEBD8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.45,
                child: Image.asset(image, width: 96, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        Positioned(
          right: -14,
          bottom: 40,
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.22,
              child: Image.asset(image, width: 150, fit: BoxFit.contain),
            ),
          ),
        ),
        Positioned(
          left: 24,
          bottom: 78,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6B94B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(child: child),
        Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 22, 0),
                child: _Script(
                  text: tagline,
                  color: const Color(0xFF2D3A55),
                  underline: 52,
                  alignEnd: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginBackdropPainter extends CustomPainter {
  const _LoginBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void blob(double cx, double cy, double r, Color c) =>
        canvas.drawCircle(Offset(w * cx, h * cy), w * r, Paint()..color = c);

    blob(0.12, -0.02, 0.32, const Color(0xFFFDF0E4));
    blob(1.0, 0.03, 0.24, const Color(0xFFEAF5EE));
    blob(1.04, 0.24, 0.10, const Color(0xFFFDF0E4));

    final mint = Path()
      ..moveTo(w * 0.42, h)
      ..cubicTo(w * 0.60, h * 0.935, w * 0.82, h * 0.925, w, h * 0.945)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(mint, Paint()..color = const Color(0xFFD6EFE2));

    final orange = Path()
      ..moveTo(0, h * 0.925)
      ..cubicTo(w * 0.14, h * 0.90, w * 0.30, h * 0.95, w * 0.52, h * 0.985)
      ..lineTo(w * 0.58, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      orange,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF7A23B), Color(0xFFFCD98A)],
        ).createShader(Rect.fromLTWH(0, h * 0.9, w * 0.6, h * 0.1)),
    );

    final teal = Path()
      ..moveTo(w * 0.30, h)
      ..cubicTo(w * 0.52, h * 0.955, w * 0.74, h * 0.965, w, h * 0.958)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      teal,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF52C48A), Color(0xFF1FA593)],
        ).createShader(Rect.fromLTWH(w * 0.3, h * 0.95, w * 0.7, h * 0.05)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum RoleBackdropStyle { student, teacher }

/// Themed background for the student and teacher logins: blobs, dotted grid,
/// layered hills and handwritten taglines.
class RoleLoginBackdrop extends StatelessWidget {
  final Widget child;
  final String tagline;
  final String bottomLeft;
  final double bottomLeftOffset;
  final RoleBackdropStyle style;

  const RoleLoginBackdrop({
    super.key,
    required this.child,
    required this.tagline,
    required this.bottomLeft,
    required this.style,
    this.bottomLeftOffset = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _RoleBackdropPainter(style)),
          ),
        ),
        Positioned(
          left: 26,
          bottom: bottomLeftOffset,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: -0.32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bottomLeft,
                    style: GoogleFonts.caveat(
                      fontSize: 17,
                      height: 1.0,
                      color: const Color(0xFF6B7A99),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 52,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (style == RoleBackdropStyle.student)
          Positioned(
            right: 22,
            bottom: 92,
            child: IgnorePointer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Your Learning\nJourney Starts Here',
                    textAlign: TextAlign.end,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF9AA5B8),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 96,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned.fill(child: child),
        Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 22, 0),
                child: _Script(
                  text: tagline,
                  color: const Color(0xFF6B7A99),
                  underline: 52,
                  alignEnd: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleBackdropPainter extends CustomPainter {
  final RoleBackdropStyle style;
  const _RoleBackdropPainter(this.style);

  void _paintTeacher(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void blob(double cx, double cy, double r, Color c) =>
        canvas.drawCircle(Offset(w * cx, h * cy), w * r, Paint()..color = c);

    blob(0.02, 0.05, 0.27, const Color(0xFFE3F4EA));
    blob(1.02, 0.06, 0.26, const Color(0xFFE9F6EE));
    blob(-0.04, 0.26, 0.11, const Color(0xFFE3F4EA));
    blob(1.04, 0.30, 0.09, const Color(0xFFE9F6EE));

    final dot = Paint()
      ..color = const Color(0xFFCBD3DF).withValues(alpha: 0.55);
    for (var y = 14.0; y < h; y += 28) {
      for (var x = 14.0; x < w; x += 28) {
        canvas.drawCircle(Offset(x, y), 1, dot);
      }
    }

    final mint = Path()
      ..moveTo(w * 0.30, h)
      ..cubicTo(w * 0.50, h * 0.925, w * 0.78, h * 0.93, w, h * 0.945)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(mint, Paint()..color = const Color(0xFFD3EEDF));

    final green = Path()
      ..moveTo(0, h * 0.915)
      ..cubicTo(w * 0.15, h * 0.885, w * 0.32, h * 0.94, w * 0.55, h * 0.975)
      ..lineTo(w * 0.66, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      green,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1FA57F), Color(0xFF5CCB9C)],
        ).createShader(Rect.fromLTWH(0, h * 0.88, w * 0.66, h * 0.12)),
    );

    final deep = Path()
      ..moveTo(w * 0.45, h)
      ..cubicTo(w * 0.62, h * 0.965, w * 0.82, h * 0.96, w, h * 0.972)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(deep, Paint()..color = const Color(0xFF52C29A));

    paintBookSketch(canvas, Offset(w * 0.78, h * 0.895), w * 0.28);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (style == RoleBackdropStyle.teacher) {
      _paintTeacher(canvas, size);
      return;
    }
    final w = size.width;
    final h = size.height;

    void blob(double cx, double cy, double r, Color c) =>
        canvas.drawCircle(Offset(w * cx, h * cy), w * r, Paint()..color = c);

    blob(0.05, 0.03, 0.30, const Color(0xFFEAF2FC));
    blob(-0.02, 0.15, 0.10, const Color(0xFFFDEBD8));
    blob(1.04, 0.17, 0.10, const Color(0xFFE6F0FB));
    blob(0.98, 0.02, 0.12, const Color(0xFFF1F6FD));

    final dot = Paint()..color = const Color(0xFFD3E1F4);
    for (var r = 0; r < 6; r++) {
      for (var c = 0; c < 6; c++) {
        canvas.drawCircle(
          Offset(w * 0.15 + c * 14, h * 0.035 + r * 14),
          1.5,
          dot,
        );
      }
    }

    final paleBlue = Path()
      ..moveTo(0, h * 0.905)
      ..cubicTo(w * 0.20, h * 0.875, w * 0.40, h * 0.93, w * 0.62, h * 0.97)
      ..lineTo(w * 0.72, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(paleBlue, Paint()..color = const Color(0xFFDCEAFA));

    final blue = Path()
      ..moveTo(0, h * 0.955)
      ..cubicTo(w * 0.18, h * 0.94, w * 0.34, h * 0.975, w * 0.50, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      blue,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF5B9BE6), Color(0xFF8FBDF0)],
        ).createShader(Rect.fromLTWH(0, h * 0.93, w * 0.5, h * 0.07)),
    );

    final orange = Path()
      ..moveTo(w * 0.40, h)
      ..cubicTo(w * 0.58, h * 0.945, w * 0.80, h * 0.93, w, h * 0.925)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(
      orange,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFF7A23B), Color(0xFFFCD9A6)],
        ).createShader(Rect.fromLTWH(w * 0.4, h * 0.92, w * 0.6, h * 0.08)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Faint open-book sketch with three "sparkle" rays above it.
void paintBookSketch(Canvas canvas, Offset c, double width) {
  final stroke = Paint()
    ..color = const Color(0xFFB8C4D9).withValues(alpha: 0.75)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeJoin = StrokeJoin.round;
  final half = width / 2;
  final top = c.dy - width * 0.42;
  final bottom = c.dy + width * 0.10;

  final left = Path()
    ..moveTo(c.dx, top + 4)
    ..quadraticBezierTo(c.dx - half * 0.5, top - 4, c.dx - half, top + 2)
    ..lineTo(c.dx - half, bottom - 2)
    ..quadraticBezierTo(c.dx - half * 0.5, bottom - 8, c.dx, bottom)
    ..close();
  final right = Path()
    ..moveTo(c.dx, top + 4)
    ..quadraticBezierTo(c.dx + half * 0.5, top - 4, c.dx + half, top + 2)
    ..lineTo(c.dx + half, bottom - 2)
    ..quadraticBezierTo(c.dx + half * 0.5, bottom - 8, c.dx, bottom)
    ..close();
  canvas.drawPath(left, stroke);
  canvas.drawPath(right, stroke);

  final ray = Paint()
    ..color = const Color(0xFF5BB6E8)
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round;
  final tip = Offset(c.dx, top - 10);
  canvas.drawLine(tip, tip.translate(0, -8), ray);
  canvas.drawLine(tip.translate(-12, 2), tip.translate(-18, -4), ray);
  canvas.drawLine(tip.translate(12, 2), tip.translate(18, -4), ray);
}

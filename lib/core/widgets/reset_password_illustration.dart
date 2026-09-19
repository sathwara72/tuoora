import 'package:flutter/material.dart';

/// Open envelope with a padlock letter, a paper plane and sparkles. Drawn in
/// code so it stays crisp at any density.
class ResetPasswordIllustration extends StatelessWidget {
  final double width;

  const ResetPasswordIllustration({super.key, this.width = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.62,
      child: const CustomPaint(painter: _IllustrationPainter()),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  const _IllustrationPainter();

  static const _orange = Color(0xFFF97316);
  static const _amber = Color(0xFFF6B94B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(w * x, h * y);

    // Soft peach blob behind everything.
    final blob = Path()
      ..moveTo(w * 0.16, h * 0.55)
      ..cubicTo(w * 0.10, h * 0.20, w * 0.36, h * 0.06, w * 0.55, h * 0.16)
      ..cubicTo(w * 0.80, h * 0.10, w * 0.98, h * 0.35, w * 0.90, h * 0.68)
      ..cubicTo(w * 0.86, h * 0.98, w * 0.30, h * 1.02, w * 0.16, h * 0.55)
      ..close();
    canvas.drawPath(blob, Paint()..color = const Color(0xFFFDEBD8));

    // Envelope body.
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.27, h * 0.50, w * 0.73, h * 0.92),
      const Radius.circular(8),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFF9B94A));

    // Letter with padlock.
    final letter = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.34, h * 0.14, w * 0.66, h * 0.66),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      letter.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(letter, Paint()..color = Colors.white);

    final lockBody = RRect.fromRectAndRadius(
      Rect.fromCenter(center: p(0.5, 0.40), width: w * 0.105, height: h * 0.15),
      const Radius.circular(4),
    );
    canvas.drawRRect(lockBody, Paint()..color = _orange);
    canvas.drawArc(
      Rect.fromCenter(
        center: p(0.5, 0.305),
        width: w * 0.062,
        height: h * 0.11,
      ),
      3.14159,
      3.14159,
      false,
      Paint()
        ..color = _orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(p(0.5, 0.395), 2.6, Paint()..color = Colors.white);
    canvas.drawLine(
      p(0.5, 0.40),
      p(0.5, 0.435),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    final line = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.40, 0.53), p(0.60, 0.53), line);
    canvas.drawLine(p(0.40, 0.60), p(0.60, 0.60), line);

    // Envelope front flaps.
    final left = Path()
      ..moveTo(w * 0.27, h * 0.50)
      ..lineTo(w * 0.27, h * 0.92)
      ..lineTo(w * 0.50, h * 0.72)
      ..close();
    final right = Path()
      ..moveTo(w * 0.73, h * 0.50)
      ..lineTo(w * 0.73, h * 0.92)
      ..lineTo(w * 0.50, h * 0.72)
      ..close();
    final bottom = Path()
      ..moveTo(w * 0.27, h * 0.92)
      ..lineTo(w * 0.50, h * 0.69)
      ..lineTo(w * 0.73, h * 0.92)
      ..close();
    canvas.drawPath(left, Paint()..color = const Color(0xFFF7A93A));
    canvas.drawPath(right, Paint()..color = const Color(0xFFF7A93A));
    canvas.drawPath(bottom, Paint()..color = const Color(0xFFFBC969));

    // Sparkle rays above the letter.
    final ray = Paint()
      ..color = _orange
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.50, 0.03), p(0.50, 0.09), ray);
    canvas.drawLine(p(0.40, 0.07), p(0.37, 0.12), ray);
    canvas.drawLine(p(0.60, 0.07), p(0.63, 0.12), ray);

    // Teal accents on the left.
    final teal = Paint()
      ..color = const Color(0xFF1FA593)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.12, 0.62), p(0.17, 0.68), teal);
    canvas.drawLine(p(0.19, 0.50), p(0.21, 0.57), teal);

    // Dashed flight path + paper plane.
    final path = Path()
      ..moveTo(w * 0.73, h * 0.62)
      ..quadraticBezierTo(w * 0.86, h * 0.60, w * 0.88, h * 0.34);
    _dashed(
      canvas,
      path,
      Paint()
        ..color = const Color(0xFF9CA3AF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final plane = Path()
      ..moveTo(w * 0.86, h * 0.36)
      ..lineTo(w * 0.99, h * 0.20)
      ..lineTo(w * 0.94, h * 0.44)
      ..lineTo(w * 0.905, h * 0.375)
      ..close();
    canvas.drawPath(plane, Paint()..color = _amber);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.905, h * 0.375)
        ..lineTo(w * 0.99, h * 0.20)
        ..lineTo(w * 0.895, h * 0.42)
        ..close(),
      Paint()..color = _orange,
    );
  }

  void _dashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 5), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

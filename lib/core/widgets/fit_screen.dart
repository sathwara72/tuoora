import 'package:flutter/widgets.dart';

/// Lays [child] out at a phone-sized design width and scales it uniformly so
/// it fills the available width on larger screens (up to [maxScale]) and
/// shrinks it when it is taller than the available height, so a screen never
/// needs to scroll. Fonts, fields and buttons therefore keep the same
/// proportions on every device instead of looking small on tall/wide phones.
class FitScreen extends StatelessWidget {
  final Widget child;

  /// Width the screens are designed for.
  static const double designWidth = 390;

  /// Upper bound for the enlargement, so tablets don't get giant controls.
  static const double maxScale = 1.3;

  const FitScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final layoutWidth = box.maxWidth <= designWidth
            ? box.maxWidth
            : (box.maxWidth / maxScale).clamp(designWidth, box.maxWidth);
        return SizedBox(
          width: box.maxWidth,
          height: box.maxHeight,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: SizedBox(width: layoutWidth, child: child),
          ),
        );
      },
    );
  }
}

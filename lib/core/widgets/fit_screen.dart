import 'package:flutter/widgets.dart';

/// Lays [child] out at the full available width and scales it down uniformly
/// when it is taller than the available height, so a screen never needs to
/// scroll. Content is only ever shrunk, never enlarged.
class FitScreen extends StatelessWidget {
  final Widget child;

  const FitScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => SizedBox(
        width: box.maxWidth,
        height: box.maxHeight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(width: box.maxWidth, child: child),
        ),
      ),
    );
  }
}

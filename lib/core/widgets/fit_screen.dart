import 'package:flutter/widgets.dart';

/// Lays [child] out at a phone-sized design width and scales it uniformly to
/// fit the screen width (up to [maxScale]).
///
/// This widget is designed to be used in a Scaffold with `resizeToAvoidBottomInset: false`.
/// This keeps the Scaffold body at full height (so background art doesn't shift)
/// while this widget creates a scrollable viewport that avoids the keyboard.
class FitScreen extends StatelessWidget {
  final Widget child;

  /// Width the screens are designed for.
  static const double designWidth = 390;

  /// Upper bound for the enlargement, so tablets don't get giant controls.
  static const double maxScale = 1.3;

  const FitScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Read the keyboard height. (Scaffold must have resizeToAvoidBottomInset: false)
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(
      builder: (context, box) {
        final layoutWidth = box.maxWidth <= designWidth
            ? box.maxWidth
            : (box.maxWidth / maxScale).clamp(designWidth, box.maxWidth);

        // The visible screen area above the keyboard
        final viewportHeight = box.maxHeight - keyboardHeight;

        return Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: SingleChildScrollView(
            // Always allow scrolling, but it will only scroll if content is taller than viewport.
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportHeight > 0 ? viewportHeight : 0,
                maxWidth: box.maxWidth,
              ),
              child: FittedBox(
                // ALWAYS scale based on width. This guarantees the UI never changes
                // size or gets "bigger/smaller" when the keyboard opens or closes!
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: layoutWidth,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

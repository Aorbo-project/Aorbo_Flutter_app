import 'package:flutter/material.dart';

/// A small control (back arrow, sheet close "x", +/- stepper) whose touch
/// area is at least Material's 48 x 48 dp, while it LOOKS exactly as before
/// (scan D7: these were 18-32 dp, so thumbs often missed them). The whole
/// box reacts to a tap, not just the drawn glyph.
class TapTarget extends StatelessWidget {
  const TapTarget({
    super.key,
    required this.onTap,
    required this.child,
    this.label,
  });

  /// Null = disabled (still the same size).
  final VoidCallback? onTap;

  /// What is drawn — unchanged in size.
  final Widget child;

  /// Read out by screen readers (e.g. "Back", "Close").
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kMinInteractiveDimension,
            minHeight: kMinInteractiveDimension,
          ),
          child: Center(widthFactor: 1, heightFactor: 1, child: child),
        ),
      ),
    );
  }
}

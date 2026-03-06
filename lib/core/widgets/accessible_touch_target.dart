/// Reusable wrapper that enforces WCAG-compliant touch target sizing.
///
/// The Web Content Accessibility Guidelines (WCAG) recommend a minimum touch
/// target size of **44 × 44 logical pixels**. This widget applies that minimum
/// via [BoxConstraints] and optionally adds [Semantics] and [GestureDetector].
library;

import 'package:flutter/material.dart';

/// Minimum touch target dimension recommended by WCAG 2.1 SC 2.5.5.
const double kMinTouchTarget = 44;

/// Ensures its [child] meets the 44 × 44 pt WCAG minimum touch target size.
///
/// Wrap any interactive element that might otherwise render smaller than the
/// minimum — for example a standalone icon or a compact chip — to guarantee
/// that the tappable area is large enough for all users.
///
/// If [semanticsLabel] is provided the child is wrapped in a [Semantics] node.
/// If [onTap] is provided the child is wrapped in a [GestureDetector].
class AccessibleTouchTarget extends StatelessWidget {
  const AccessibleTouchTarget({
    required this.child,
    this.semanticsLabel,
    this.onTap,
    super.key,
  });

  /// The widget to display inside the touch target.
  final Widget child;

  /// Optional [Semantics] label applied to the touch target.
  final String? semanticsLabel;

  /// Optional tap handler. When non-null the target responds to taps.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget result = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: kMinTouchTarget,
        minHeight: kMinTouchTarget,
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: child,
      ),
    );

    if (onTap != null) {
      result = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }

    if (semanticsLabel != null) {
      result = Semantics(
        label: semanticsLabel,
        button: onTap != null,
        child: result,
      );
    }

    return result;
  }
}

/// Reusable empty state placeholder for screens with no content.
///
/// All display strings are passed in via parameters — nothing is hardcoded —
/// so the widget can be used in any feature module with its own copy.
library;

import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Minimum touch target dimension recommended by WCAG 2.1 SC 2.5.5.
const double _kMinTouchTarget = 44;

/// A centred empty-state layout with an icon, title, body text, and an
/// optional action button.
///
/// Example:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.inbox_outlined,
///   title: l10n.emptyStateTitle,
///   body: l10n.emptyStateBody,
///   actionLabel: l10n.retryButton,
///   onAction: () => ref.invalidate(someProvider),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsetsDirectional.all(AppTokens.space32),
    super.key,
  });

  /// The icon displayed at the top of the empty state.
  final IconData icon;

  /// Primary message — typically a short headline.
  final String title;

  /// Secondary message providing more context.
  final String body;

  /// Label for the optional action button. Both [actionLabel] and [onAction]
  /// must be provided for the button to appear.
  final String? actionLabel;

  /// Callback for the optional action button.
  final VoidCallback? onAction;

  /// Outer padding applied to the entire widget.
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: title,
              child: ExcludeSemantics(
                child: Icon(
                  icon,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space16),
            Semantics(
              header: true,
              child: Text(
                title,
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppTokens.space8),
            Text(
              body,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTokens.space24),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: _kMinTouchTarget,
                  minHeight: _kMinTouchTarget,
                ),
                child: Semantics(
                  button: true,
                  label: actionLabel,
                  child: FilledButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

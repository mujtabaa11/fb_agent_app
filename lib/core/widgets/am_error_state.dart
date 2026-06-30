import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../theme/app_tokens.dart';

class AmErrorState extends StatelessWidget {
  const AmErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.all(AppTokens.space32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: message,
              child: ExcludeSemantics(
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              message,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.space24),
            Semantics(
              button: true,
              label: l10n.retryLabel,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retryLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

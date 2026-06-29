/// Global error boundary that catches Flutter framework errors.
///
/// Overrides [ErrorWidget.builder] so that unhandled build-time exceptions
/// display a user-friendly message instead of the red error screen.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../services/crashlytics_service.dart';
import '../theme/app_tokens.dart';

/// Wraps [child] and installs a custom [ErrorWidget.builder] that renders
/// [AppErrorWidget] instead of the default red/grey error screen.
///
/// Place this as close to the root as possible — typically around
/// [ProviderScope] in `main.dart`.
class ErrorBoundary extends StatelessWidget {
  const ErrorBoundary({
    required this.child,
    this.onRetry,
    super.key,
  });

  /// Called when the user taps the retry button in the error UI.
  /// Defaults to a no-op if not provided.
  final VoidCallback? onRetry;

  /// The widget subtree to protect.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry ?? () {};

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return AppErrorWidget(details: details, onRetry: retry);
    };

    return child;
  }
}

/// User-facing error widget displayed by [ErrorWidget.builder].
///
/// In debug mode the full error and stack trace are logged via [debugPrint].
/// In release mode the error is routed to [CrashlyticsService].
///
/// Raw exception messages are **never** shown to the user.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.details,
    required this.onRetry,
    super.key,
  });

  /// The Flutter error details captured by the framework.
  final FlutterErrorDetails details;

  /// Called when the user taps the retry button.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Log the error appropriately per build mode.
    if (kDebugMode) {
      debugPrint('ErrorBoundary caught error: ${details.exception}');
      debugPrint('Stack trace:\n${details.stack}');
    } else {
      // In release mode, route to Crashlytics for crash reporting.
      // We use ProviderScope.containerOf to access providers without a
      // WidgetRef, since ErrorWidget.builder may create this widget outside
      // the normal widget lifecycle.
      try {
        final container = ProviderScope.containerOf(context);
        final crashlytics = container.read(crashlyticsServiceProvider);
        crashlytics.recordError(
          details.exception,
          details.stack ?? StackTrace.current,
        );
      } catch (_) {
        // If the container is not available (e.g., error during bootstrap),
        // silently ignore — we cannot log remotely in this edge case.
      }
    }

    // ErrorWidget.builder can be invoked in contexts where the localisation
    // delegates have not been installed yet (e.g., before MaterialApp is
    // built). In that case AppLocalizations.of(context) returns null and we
    // fall back to hardcoded English strings. This is the only place in the
    // app where hardcoded strings are acceptable.
    final l10n = AppLocalizations.of(context);
    final errorMessage = l10n?.errorGeneric ?? 'Something went wrong.';
    final retryLabel = l10n?.retryButton ?? 'Try Again';

    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppTokens.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: errorMessage,
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.space16),
              Text(
                errorMessage,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.space24),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                child: Semantics(
                  button: true,
                  label: retryLabel,
                  child: FilledButton(
                    onPressed: onRetry,
                    child: Text(retryLabel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

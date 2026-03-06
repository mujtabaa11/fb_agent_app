/// Fallback screen shown when Firebase fails to initialise at boot.
///
/// Displayed via [runApp] in `main.dart` so it does not depend on the normal
/// app widget tree, GoRouter, or Riverpod.
library;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// UI strings — zero hardcoded strings inline.
// ---------------------------------------------------------------------------

const String _kAppTitle = 'Launchpad';
const String _kErrorIconLabel = 'Error icon';
const String _kSetupNote =
    'Check the README for Firebase setup instructions.';

/// A minimal error screen displayed when Firebase initialisation fails.
///
/// Takes a required [message] describing the failure and renders it inside a
/// standalone [MaterialApp] (no router, no providers).
class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({required this.message, super.key});

  /// Human-readable description of the Firebase initialisation failure.
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _kAppTitle,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 24, end: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: _kErrorIconLabel,
                    child: const ExcludeSemantics(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    label: message,
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: _kSetupNote,
                    child: const Text(
                      _kSetupNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

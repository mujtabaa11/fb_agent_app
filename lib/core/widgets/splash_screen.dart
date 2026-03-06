import 'package:flutter/material.dart';
import 'package:template_app/l10n/app_localizations.dart';

/// A full-screen loading indicator shown while the app determines auth state.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Semantics(
          label: AppLocalizations.of(context)!.loadingAppLabel,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

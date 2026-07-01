/// Placeholder add player screen.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

class AddPlayerScreen extends StatelessWidget {
  const AddPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addPlayerTitle)),
      body: Center(child: Text(l10n.addPlayerTitle)),
    );
  }
}

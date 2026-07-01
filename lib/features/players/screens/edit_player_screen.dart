/// Placeholder edit player screen.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

class EditPlayerScreen extends StatelessWidget {
  const EditPlayerScreen({required this.playerId, super.key});

  final String playerId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editPlayerTitle)),
      body: Center(child: Text(l10n.editPlayerTitle)),
    );
  }
}

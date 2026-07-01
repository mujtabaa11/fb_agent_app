/// Placeholder agent public profile screen.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

class AgentPublicProfileScreen extends StatelessWidget {
  const AgentPublicProfileScreen({required this.agentId, super.key});

  final String agentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentPublicProfileTitle)),
      body: Center(child: Text(l10n.agentPublicProfileTitle)),
    );
  }
}

/// Placeholder messages tab screen.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

class ConversationListScreen extends StatelessWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(child: Text(l10n.messagesTitle));
  }
}

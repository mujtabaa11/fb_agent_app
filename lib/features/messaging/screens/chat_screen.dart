/// Placeholder chat screen.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({required this.conversationId, super.key});

  final String conversationId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatTitle)),
      body: Center(child: Text(l10n.chatTitle)),
    );
  }
}

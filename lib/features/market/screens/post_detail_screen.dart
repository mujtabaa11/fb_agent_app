/// Placeholder market post detail screen.
library;

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.postDetailTitle)),
      body: Center(child: Text(l10n.postDetailTitle)),
    );
  }
}

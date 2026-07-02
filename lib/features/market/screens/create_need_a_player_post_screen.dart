/// Placeholder create "Need a Player" post screen — built out in Story 3.
library;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class CreateNeedAPlayerPostScreen extends StatelessWidget {
  const CreateNeedAPlayerPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.postTypeNeedPlayer)),
      body: Center(child: Text(l10n.postTypeNeedPlayer)),
    );
  }
}

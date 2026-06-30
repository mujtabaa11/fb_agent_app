import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'empty_state_widget.dart';

class AmEmptyState extends StatelessWidget {
  const AmEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: icon,
      title: title,
      body: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      padding: const EdgeInsetsDirectional.all(AppTokens.space32),
    );
  }
}

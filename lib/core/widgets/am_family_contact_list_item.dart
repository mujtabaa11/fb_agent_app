import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../theme/app_tokens.dart';

class AmFamilyContactListItem extends StatelessWidget {
  const AmFamilyContactListItem({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final String name;
  final String relationship;
  final String phoneNumber;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: l10n.familyContactLabel(name, relationship),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppTokens.space8,
            horizontal: AppTokens.space16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      '$relationship · $phoneNumber',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                Semantics(
                  button: true,
                  label: l10n.editLabel,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ),
                ),
              if (onDelete != null)
                Semantics(
                  button: true,
                  label: l10n.deleteLabel,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                    child: IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/am_status_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';

class ContractExpiryAlertItem extends StatelessWidget {
  const ContractExpiryAlertItem({required this.alert, super.key});

  final ContractExpiryAlert alert;

  (Color, Color) _urgencyColors() {
    return switch (alert.urgency) {
      ExpiryUrgency.critical => (AppColors.error, AppColors.errorSurface),
      ExpiryUrgency.warning => (AppColors.warning, AppColors.warningSurface),
      ExpiryUrgency.safe => (AppColors.success, AppColors.successSurface),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy');
    final (urgencyColor, urgencySurface) = _urgencyColors();

    final contractTypeLabel = switch (alert.contractType) {
      ContractType.representationAgreement =>
        l10n.contractTypeRepresentationAgreement,
      ContractType.clubContract => l10n.contractTypeClubContract,
    };

    final semanticsLabel =
        '${alert.playerName}, $contractTypeLabel, ${dateFormat.format(alert.expiryDate)}, '
        '${l10n.expiryDaysRemaining(alert.daysRemaining)}';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: () => context.push('/players/${alert.playerId}'),
        child: Container(
          margin: const EdgeInsetsDirectional.only(bottom: AppTokens.space12),
          padding: const EdgeInsetsDirectional.all(AppTokens.space12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: urgencySurface,
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.playerName,
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeMd,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      contractTypeLabel,
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      dateFormat.format(alert.expiryDate),
                      style: const TextStyle(
                        fontSize: AppTokens.fontSizeSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.space12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AmStatusBadge(
                  label: l10n.expiryDaysRemaining(alert.daysRemaining),
                  backgroundColor: urgencySurface,
                  textColor: urgencyColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

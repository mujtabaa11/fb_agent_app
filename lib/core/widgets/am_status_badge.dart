import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class AmStatusBadge extends StatelessWidget {
  const AmStatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    super.key,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppTokens.space8,
          vertical: AppTokens.space4,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTokens.fontSizeXs,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

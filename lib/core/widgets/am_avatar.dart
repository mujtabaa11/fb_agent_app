import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

enum AmAvatarSize {
  small(32),
  medium(48),
  large(96);

  const AmAvatarSize(this.diameter);
  final double diameter;
}

class AmAvatar extends StatelessWidget {
  const AmAvatar({
    this.imageUrl,
    this.name,
    this.size = AmAvatarSize.medium,
    this.semanticsLabel,
    super.key,
  });

  final String? imageUrl;
  final String? name;
  final AmAvatarSize size;
  final String? semanticsLabel;

  String? get _initials {
    if (name == null || name!.trim().isEmpty) return null;
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  double get _fontSize {
    return switch (size) {
      AmAvatarSize.small => AppTokens.fontSizeXs,
      AmAvatarSize.medium => AppTokens.fontSizeSm,
      AmAvatarSize.large => AppTokens.fontSizeXl,
    };
  }

  double get _iconSize {
    return switch (size) {
      AmAvatarSize.small => AppTokens.space16,
      AmAvatarSize.medium => AppTokens.space24,
      AmAvatarSize.large => AppTokens.space48,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.surfaceAltDark : AppColors.primarySurface;

    Widget child;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      child = ClipOval(
        child: Image.network(
          imageUrl!,
          width: size.diameter,
          height: size.diameter,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackWidget(colorScheme, bgColor),
        ),
      );
    } else {
      child = _fallbackWidget(colorScheme, bgColor);
    }

    return Semantics(
      label: semanticsLabel,
      image: imageUrl != null && imageUrl!.isNotEmpty,
      child: SizedBox(
        width: size.diameter,
        height: size.diameter,
        child: child,
      ),
    );
  }

  Widget _fallbackWidget(ColorScheme colorScheme, Color bgColor) {
    final initials = _initials;
    return Container(
      width: size.diameter,
      height: size.diameter,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: initials != null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            )
          : Icon(
              Icons.person,
              size: _iconSize,
              color: AppColors.primary,
            ),
    );
  }
}

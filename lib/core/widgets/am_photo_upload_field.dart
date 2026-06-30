import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:football_agent_mate/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AmPhotoUploadField extends StatelessWidget {
  const AmPhotoUploadField({
    required this.onTap,
    this.imageUrl,
    this.imageBytes,
    this.semanticsLabel,
    this.size = 96.0,
    super.key,
  });

  final VoidCallback onTap;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? semanticsLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.surfaceAltDark : AppColors.primarySurface;

    Widget photoContent;
    if (imageBytes != null) {
      photoContent = ClipOval(
        child: Image.memory(
          imageBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      photoContent = ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(bgColor),
        ),
      );
    } else {
      photoContent = _placeholder(bgColor);
    }

    return Semantics(
      button: true,
      label: semanticsLabel ?? l10n.photoUploadLabel,
      child: GestureDetector(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                photoContent,
                PositionedDirectional(
                  bottom: 0,
                  end: 0,
                  child: Container(
                    padding:
                        const EdgeInsetsDirectional.all(AppTokens.space4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: AppTokens.space16,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(Color bgColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: AppColors.primary,
      ),
    );
  }
}

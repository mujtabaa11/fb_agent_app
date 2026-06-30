import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

enum AmSkeletonVariant { card, listItem }

class AmLoadingSkeleton extends StatefulWidget {
  const AmLoadingSkeleton({
    this.variant = AmSkeletonVariant.card,
    super.key,
  });

  final AmSkeletonVariant variant;

  @override
  State<AmLoadingSkeleton> createState() => _AmLoadingSkeletonState();
}

class _AmLoadingSkeletonState extends State<AmLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return switch (widget.variant) {
          AmSkeletonVariant.card => _buildCardSkeleton(),
          AmSkeletonVariant.listItem => _buildListItemSkeleton(),
        };
      },
    );
  }

  Widget _buildCardSkeleton() {
    return Card(
      elevation: AppTokens.elevationSm,
      margin: EdgeInsetsDirectional.zero,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _shimmerBox(width: 48, height: 48, circular: true),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(width: 160, height: 14),
                      const SizedBox(height: AppTokens.space8),
                      _shimmerBox(width: 120, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space12),
            _shimmerBox(width: double.infinity, height: 12),
            const SizedBox(height: AppTokens.space8),
            _shimmerBox(width: 200, height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildListItemSkeleton() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: AppTokens.space8,
        horizontal: AppTokens.space16,
      ),
      child: Row(
        children: [
          _shimmerBox(width: 40, height: 40, circular: true),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: 140, height: 14),
                const SizedBox(height: AppTokens.space8),
                _shimmerBox(width: 100, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    bool circular = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surfaceAltDark : AppColors.surfaceAlt;
    final highlightColor = isDark ? AppColors.borderDark : AppColors.border;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color.lerp(baseColor, highlightColor, _animation.value),
        borderRadius: circular
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(AppTokens.radiusSm),
      ),
    );
  }
}

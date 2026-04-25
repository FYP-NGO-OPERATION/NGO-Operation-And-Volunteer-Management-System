import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';

/// Premium shimmer skeleton for loading states — replaces CircularProgressIndicator
/// with a polished, branded placeholder.
class SkeletonLoader extends StatefulWidget {
  final int lines;
  final bool showAvatar;
  final bool showImage;
  final double? width;

  const SkeletonLoader({
    super.key,
    this.lines = 3,
    this.showAvatar = false,
    this.showImage = false,
    this.width,
  });

  /// Card-shaped skeleton for campaign/donation cards
  static Widget card() {
    return const _SkeletonCard();
  }

  /// List item with avatar + 2 lines
  static Widget listItem() {
    return const SkeletonLoader(lines: 2, showAvatar: true);
  }

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.12);
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.22);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final opacity = _animation.value;
        final color = Color.lerp(baseColor, highlightColor, opacity)!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showAvatar)
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showImage)
                      Container(
                        height: 160,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: AppTokens.borderRadiusMd,
                        ),
                      ),
                    ...List.generate(widget.lines, (i) {
                      final widthFactor = i == widget.lines - 1 ? 0.6 : (i == 0 ? 0.85 : 0.95);
                      return Container(
                        height: 14,
                        width: widget.width != null ? widget.width! * widthFactor : null,
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: AppTokens.borderRadiusSm,
                        ),
                        child: widget.width == null
                            ? FractionallySizedBox(widthFactor: widthFactor)
                            : null,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.12);
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.22);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final color = Color.lerp(baseColor, highlightColor, _animation.value)!;
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCardBg : Colors.white,
            borderRadius: AppTokens.borderRadiusMd,
            border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radiusMd)),
                ),
              ),
              Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 200, decoration: BoxDecoration(color: color, borderRadius: AppTokens.borderRadiusSm)),
                    AppSpacing.vGapSm,
                    Container(height: 12, width: 280, decoration: BoxDecoration(color: color, borderRadius: AppTokens.borderRadiusSm)),
                    AppSpacing.vGapMd,
                    Container(height: 10, width: 120, decoration: BoxDecoration(color: color, borderRadius: AppTokens.borderRadiusSm)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

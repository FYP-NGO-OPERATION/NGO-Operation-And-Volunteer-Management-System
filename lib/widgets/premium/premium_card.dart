import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_animations.dart';

/// Premium Card System
class PremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool enableHover;
  final Color? backgroundColor;
  final List<BoxShadow>? shadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.enableHover = true,
    this.backgroundColor,
    this.shadow,
  });

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.darkCardBg : AppColors.lightCardBg);

    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          curve: AppAnimations.easeOut,
          transform: Matrix4.translationValues(0.0, _isHovered ? -2.0 : 0.0, 0.0),
          padding: widget.padding ?? AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppTokens.borderRadiusMd,
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            ),
            boxShadow: _isHovered ? AppTokens.shadowMedium : (widget.shadow ?? AppTokens.shadowSoft),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Stats card for dashboards
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: AppTokens.borderRadiusSm,
            ),
            child: Icon(icon, color: color, size: AppTokens.iconMd),
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.statValue(color: color)),
          AppSpacing.vGapXs,
          Text(title, style: AppTextStyles.caption(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          )),
          if (subtitle != null) ...[
            AppSpacing.vGapXs,
            Text(subtitle!, style: AppTextStyles.labelSmall(color: AppColors.success)),
          ],
        ],
      ),
    );
  }
}

/// Glass card for premium overlays
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: AppTokens.borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: AppTokens.shadowMedium,
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_animations.dart';

/// Premium Button System with multiple variants and states
enum PremiumButtonVariant { primary, secondary, ghost, outline, danger, accent }
enum PremiumButtonSize { sm, md, lg }

class PremiumButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final PremiumButtonVariant variant;
  final PremiumButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PremiumButtonVariant.primary,
    this.size = PremiumButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  // Named constructors for convenience
  const PremiumButton.primary({super.key, required this.label, this.onPressed, this.icon, this.isLoading = false, this.isExpanded = false})
      : variant = PremiumButtonVariant.primary, size = PremiumButtonSize.md;

  const PremiumButton.secondary({super.key, required this.label, this.onPressed, this.icon, this.isLoading = false, this.isExpanded = false})
      : variant = PremiumButtonVariant.secondary, size = PremiumButtonSize.md;

  const PremiumButton.ghost({super.key, required this.label, this.onPressed, this.icon, this.isLoading = false, this.isExpanded = false})
      : variant = PremiumButtonVariant.ghost, size = PremiumButtonSize.md;

  const PremiumButton.outline({super.key, required this.label, this.onPressed, this.icon, this.isLoading = false, this.isExpanded = false})
      : variant = PremiumButtonVariant.outline, size = PremiumButtonSize.md;

  const PremiumButton.danger({super.key, required this.label, this.onPressed, this.icon, this.isLoading = false, this.isExpanded = false})
      : variant = PremiumButtonVariant.danger, size = PremiumButtonSize.md;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: AppAnimations.fast);
    _scaleAnim = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: AppAnimations.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  double get _height {
    switch (widget.size) {
      case PremiumButtonSize.sm: return AppTokens.buttonHeightSm;
      case PremiumButtonSize.md: return AppTokens.buttonHeightMd;
      case PremiumButtonSize.lg: return AppTokens.buttonHeightLg;
    }
  }

  Color _bg(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    switch (widget.variant) {
      case PremiumButtonVariant.primary: return AppColors.primary;
      case PremiumButtonVariant.secondary: return AppColors.secondary;
      case PremiumButtonVariant.accent: return AppColors.accent;
      case PremiumButtonVariant.danger: return AppColors.error;
      case PremiumButtonVariant.ghost: return Colors.transparent;
      case PremiumButtonVariant.outline: return isDark ? Colors.transparent : Colors.transparent;
    }
  }

  Color _fg(BuildContext ctx) {
    switch (widget.variant) {
      case PremiumButtonVariant.primary:
      case PremiumButtonVariant.secondary:
      case PremiumButtonVariant.danger:
        return Colors.white;
      case PremiumButtonVariant.accent: return AppColors.neutral900;
      case PremiumButtonVariant.ghost: return AppColors.primary;
      case PremiumButtonVariant.outline: return AppColors.primary;
    }
  }

  BorderSide? _border() {
    if (widget.variant == PremiumButtonVariant.outline) {
      return const BorderSide(color: AppColors.primary, width: 1.5);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _pressController.forward(),
      onTapUp: disabled ? null : (_) => _pressController.reverse(),
      onTapCancel: disabled ? null : () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: SizedBox(
          width: widget.isExpanded ? double.infinity : null,
          height: _height,
          child: AnimatedOpacity(
            opacity: disabled ? AppTokens.opacityDisabled : 1.0,
            duration: AppAnimations.fast,
            child: Material(
              color: _bg(context),
              borderRadius: AppTokens.borderRadiusMd,
              child: InkWell(
                onTap: disabled ? null : widget.onPressed,
                borderRadius: AppTokens.borderRadiusMd,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.size == PremiumButtonSize.sm ? AppSpacing.md : AppSpacing.xl,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppTokens.borderRadiusMd,
                    border: _border() != null ? Border.fromBorderSide(_border()!) : null,
                  ),
                  child: Row(
                    mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: _fg(context)),
                        )
                      else ...[
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: AppTokens.iconSm, color: _fg(context)),
                          AppSpacing.hGapSm,
                        ],
                        Text(widget.label, style: AppTextStyles.button(color: _fg(context))),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

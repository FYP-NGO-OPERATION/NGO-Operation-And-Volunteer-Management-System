import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_spacing.dart';

/// Reusable button with loading state, press-scale, and outlined variant.
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.width,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _pressCtrl.dispose(); super.dispose(); }

  Widget _buildChild() {
    if (widget.isLoading) {
      return const SizedBox(
        height: 20, width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: AppTokens.iconSm),
          AppSpacing.hGapSm,
          Text(widget.text, style: AppTextStyles.button()),
        ],
      );
    }
    return Text(widget.text, style: AppTextStyles.button());
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;

    final button = widget.isOutlined
        ? OutlinedButton(onPressed: disabled ? null : widget.onPressed, child: _buildChild())
        : ElevatedButton(
            onPressed: disabled ? null : widget.onPressed,
            style: widget.backgroundColor != null
                ? ElevatedButton.styleFrom(backgroundColor: widget.backgroundColor)
                : null,
            child: _buildChild(),
          );

    return GestureDetector(
      onTapDown: disabled ? null : (_) => _pressCtrl.forward(),
      onTapUp: disabled ? null : (_) => _pressCtrl.reverse(),
      onTapCancel: disabled ? null : () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: AppTokens.buttonHeightLg,
          child: button,
        ),
      ),
    );
  }
}

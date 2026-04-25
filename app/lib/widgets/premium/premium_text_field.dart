import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_animations.dart';

/// Premium Text Field with focus glow and validation states
class PremiumTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  const PremiumTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.textInputAction,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField> {
  bool _isFocused = false;
  bool _hasError = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final borderColor = _hasError
        ? AppColors.error
        : _isFocused
            ? AppColors.primary
            : (isDark ? AppColors.darkDivider : AppColors.lightDivider);

    return AnimatedContainer(
      duration: AppAnimations.normal,
      decoration: BoxDecoration(
        borderRadius: AppTokens.borderRadiusMd,
        boxShadow: _isFocused
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 2))]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        textInputAction: widget.textInputAction,
        style: AppTextStyles.bodyMedium(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
        validator: (val) {
          final result = widget.validator?.call(val);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _hasError = result != null);
          });
          return result;
        },
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          filled: true,
          fillColor: fillColor,
          labelStyle: AppTextStyles.labelMedium(
            color: _isFocused ? AppColors.primary : (isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
          ),
          hintStyle: AppTextStyles.bodyMedium(
            color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, size: AppTokens.iconMd,
                  color: _isFocused ? AppColors.primary : (isDark ? AppColors.darkTextHint : AppColors.lightTextHint))
              : null,
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
                  icon: Icon(widget.suffixIcon, size: AppTokens.iconMd,
                    color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                  onPressed: widget.onSuffixTap,
                )
              : null,
          contentPadding: AppSpacing.inputPadding,
          border: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMd,
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMd,
            borderSide: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusMd,
            borderSide: BorderSide(color: (isDark ? AppColors.darkDivider : AppColors.lightDivider).withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }
}

/// Premium Search Field
class PremiumSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const PremiumSearchField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTokens.borderRadiusPill,
        boxShadow: AppTokens.shadowSoft,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium(
            color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.neutral400),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClear)
              : null,
          filled: true,
          fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          border: OutlineInputBorder(
            borderRadius: AppTokens.borderRadiusPill,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

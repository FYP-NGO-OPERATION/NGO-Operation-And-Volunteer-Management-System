import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';

/// Premium empty state with icon, title, subtitle, and optional action
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    String? subtitle,
    String? message,
    this.actionLabel,
    this.onAction,
  }) : subtitle = subtitle ?? message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: AppSpacing.pagePaddingWide,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkSurfaceVariant : AppColors.neutral100),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppTokens.iconHero, color: AppColors.neutral400),
            ),
            AppSpacing.vGapXl,
            Text(title, style: AppTextStyles.titleMedium(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ), textAlign: TextAlign.center),
            if (subtitle != null) ...[
              AppSpacing.vGapSm,
              Text(subtitle!, style: AppTextStyles.bodyMedium(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ), textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.vGapXl,
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                ),
                child: Text(actionLabel!, style: AppTextStyles.button(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

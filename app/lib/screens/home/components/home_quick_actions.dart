import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/feature_flags.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_tokens.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/ngo_provider.dart';
import '../../campaigns/create_campaign_screen.dart';
import '../../inventory/inventory_list_screen.dart';
import '../../profile/leaderboard_screen.dart';
import '../../admin/reports_screen.dart';
import '../../analytics/analytics_dashboard_screen.dart';

class HomeQuickActions extends StatelessWidget {
  final UserModel? user;
  final NgoProvider ngoProvider;
  final Function(int) onTabChange;

  const HomeQuickActions({
    Key? key,
    required this.user,
    required this.ngoProvider,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('quick_actions'.tr(), style: AppTextStyles.titleLarge()),
        AppSpacing.vGapMd,
        if (user?.isAdmin == true) ...[
          _buildActionTile(
            context,
            'Create Campaign',
            'Start a new campaign',
            Icons.add_circle_outline,
            AppColors.primary,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateCampaignScreen()),
            ),
          ),
          _buildActionTile(
            context,
            'Impact Metrics',
            'View NGO analytics & charts',
            Icons.bar_chart,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
            ),
          ),
          _buildActionTile(
            context,
            'inventory'.tr(),
            'Manage NGO stock and resources',
            Icons.inventory,
            AppColors.success,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InventoryListScreen()),
            ),
          ),
          if (FeatureFlags.isFyp2 || FeatureFlags.isFull)
            _buildActionTile(
              context,
              'Generate Monthly Report',
              'Download PDF operations summary',
              Icons.picture_as_pdf,
              AppColors.error,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              ),
            ),
        ],
        _buildActionTile(
          context,
          'top_volunteers'.tr(),
          'top_volunteers_desc'.tr(),
          Icons.emoji_events,
          Colors.amber,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
          ),
        ),
        if (ngoProvider.currentNgo?.features.contains('campaigns') ?? true)
          _buildActionTile(
            context,
            'view_campaigns'.tr(),
            'view_campaigns_desc'.tr(),
            Icons.list_alt,
            AppColors.info,
            () => onTabChange(1),
          ),
        _buildActionTile(
          context,
          'my_profile'.tr(),
          'my_profile_desc'.tr(),
          Icons.person_outline,
          AppColors.primaryLight,
          () => onTabChange(3),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppTokens.borderRadiusSm,
          ),
          child: Icon(icon, color: color, size: AppTokens.iconMd),
        ),
        title: Text(title, style: AppTextStyles.titleSmall()),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.neutral500 : AppColors.neutral400),
        onTap: onTap,
      ),
    );
  }
}

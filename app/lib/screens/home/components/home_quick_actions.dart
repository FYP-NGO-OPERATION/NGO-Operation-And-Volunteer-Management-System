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
import '../../disaster/disaster_map_screen.dart';
import '../../campaigns/route_optimization_screen.dart';

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
    final actions = <Widget>[
      if (user?.isAdmin == true) ...[
        _buildActionCard(
          context,
          'Create Campaign',
          Icons.add_circle_outline,
          AppColors.primary,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCampaignScreen())),
        ),
        _buildActionCard(
          context,
          'Impact Metrics',
          Icons.bar_chart,
          Colors.blue,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen())),
        ),
        _buildActionCard(
          context,
          'inventory'.tr(),
          Icons.inventory,
          AppColors.success,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryListScreen())),
        ),
        if (FeatureFlags.isFyp2 || FeatureFlags.isFull)
          _buildActionCard(
            context,
            'Generate Report',
            Icons.picture_as_pdf,
            AppColors.error,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
          ),
      ],
      _buildActionCard(
        context,
        'Top Volunteers',
        Icons.emoji_events,
        Colors.amber,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
      ),
      if (ngoProvider.currentNgo?.features.contains('campaigns') ?? true)
        _buildActionCard(
          context,
          'View Campaigns',
          Icons.list_alt,
          AppColors.info,
          () => onTabChange(1),
        ),
      _buildActionCard(
        context,
        'Disaster Map',
        Icons.map,
        Colors.orange.shade700,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DisasterMapScreen())),
      ),
      _buildActionCard(
        context,
        'Optimize Routes',
        Icons.route,
        Colors.indigo,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteOptimizationScreen())),
      ),
      _buildActionCard(
        context,
        'My Profile',
        Icons.person_outline,
        AppColors.primaryLight,
        () => onTabChange(3),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Icon(Icons.flash_on, color: AppColors.primary, size: 24),
              AppSpacing.hGapSm,
              Text(
                'quick_actions'.tr(),
                style: AppTextStyles.headlineMedium().copyWith(
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vGapLg,
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => actions[index],
          ),
        ),
        AppSpacing.vGapSm,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe_left, size: 14, color: AppColors.textHint),
              const SizedBox(width: 6),
              Text(
                'Swipe for more actions',
                style: AppTextStyles.labelSmall(color: AppColors.textHint),
              ),
              const SizedBox(width: 6),
              Icon(Icons.swipe_right, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardBg.withOpacity(0.8) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark 
                ? color.withOpacity(0.3) 
                : color.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDark ? 0.2 : 0.15),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, spreadRadius: 1),
                ],
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.labelMedium(color: isDark ? Colors.white : Colors.black87).copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

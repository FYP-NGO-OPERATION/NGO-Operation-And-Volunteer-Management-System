import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_tokens.dart';
import '../../../../providers/campaign_provider.dart';
import '../../../../utils/responsive.dart';

class HomeStatsGrid extends StatelessWidget {
  const HomeStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context);
    final campaignProvider = Provider.of<CampaignProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('overview'.tr(), style: AppTextStyles.titleLarge()),
        AppSpacing.vGapMd,
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: Responsive.isMobile(context) ? 1.15 : 1.6,
          children: [
            _buildStatCard(
              context,
              'active_campaigns'.tr(),
              '${campaignProvider.activeCampaigns}',
              Icons.campaign,
              AppColors.info,
            ),
            _buildStatCard(
              context,
              'donations'.tr(),
              'Rs.${_formatCompact(campaignProvider.totalDonationsOverall)}',
              Icons.volunteer_activism,
              AppColors.warning,
            ),
            _buildStatCard(
              context,
              'families_helped'.tr(),
              '${campaignProvider.totalBeneficiariesOverall}',
              Icons.family_restroom,
              AppColors.success,
            ),
            _buildStatCard(
              context,
              'items_distributed'.tr(),
              '${campaignProvider.totalItemsDistributedOverall}',
              Icons.inventory_2,
              AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }

  /// Format large numbers compactly: 267000 → "267K", 1500000 → "1.5M"
  String _formatCompact(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return m == m.roundToDouble()
          ? '${m.toInt()}M'
          : '${m.toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      final k = value / 1000;
      return k == k.roundToDouble()
          ? '${k.toInt()}K'
          : '${k.toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        boxShadow: AppTokens.shadowSoft,
      ),
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
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.statValue(color: color)),
          ),
          AppSpacing.vGapXs,
          Text(
            title,
            style: AppTextStyles.caption(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

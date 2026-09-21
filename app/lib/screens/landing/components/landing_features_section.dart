import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_tokens.dart';
import '../../../../utils/responsive.dart';
import '../../../../providers/campaign_provider.dart';
import '../../../../models/campaign_model.dart';

class LandingFeaturesSection extends StatelessWidget {
  final bool isDark;
  const LandingFeaturesSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ImpactStats(),
        _MissionSection(isDark: isDark),
        _RecentCampaigns(isDark: isDark),
        _NewsletterSection(isDark: isDark),
      ],
    );
  }
}

class _ImpactStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Consumer<CampaignProvider>(
      builder: (context, provider, child) {
        final stats = [
          _StatItem(
            '${provider.totalCampaigns}',
            'Total Campaigns',
            Icons.campaign,
          ),
          _StatItem(
            '${provider.totalBeneficiariesOverall}+',
            'Families Helped',
            Icons.family_restroom,
          ),
          _StatItem(
            '${provider.totalItemsDistributedOverall}+',
            'Items Donated',
            Icons.inventory_2,
          ),
        ];

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.section,
            horizontal: AppSpacing.xl,
          ),
          color: AppColors.primarySurface.withValues(alpha: 0.4),
          child: isMobile
              ? Column(
                  children: stats
                      .map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                          child: s,
                        ),
                      )
                      .toList(),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: stats,
                ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  const _StatItem(this.number, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: AppTokens.iconLg),
        AppSpacing.vGapSm,
        Text(number, style: AppTextStyles.statValue(color: AppColors.primary)),
        AppSpacing.vGapXs,
        Text(
          label,
          style: AppTextStyles.labelMedium(color: AppColors.lightTextSecondary),
        ),
      ],
    );
  }
}

class _MissionSection extends StatelessWidget {
  final bool isDark;
  const _MissionSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.page,
        horizontal: AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppTokens.borderRadiusPill,
                ),
                child: Text(
                  'OUR MISSION',
                  style: AppTextStyles.overline(color: AppColors.primary),
                ),
              ),
              AppSpacing.vGapLg,
              Text(
                'Empowering Communities Through Action',
                style: AppTextStyles.headlineLarge(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapLg,
              Text(
                'HRAS (Hamesha Rahein Apke Saath) is dedicated to bringing hope, aid, and sustainable change. '
                'We believe in the power of collective volunteerism to transform lives and build a better future for everyone.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentCampaigns extends StatelessWidget {
  final bool isDark;
  const _RecentCampaigns({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<CampaignProvider>(
      builder: (context, provider, child) {
        final campaigns = provider.allCampaigns.take(3).toList();
        if (campaigns.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.section,
            horizontal: AppSpacing.xl,
          ),
          child: Column(
            children: [
              Text(
                'Recent Campaigns',
                style: AppTextStyles.headlineMedium(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              AppSpacing.vGapXxl,
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                alignment: WrapAlignment.center,
                children: campaigns
                    .map((c) => _CampaignCard(campaign: c, isDark: isDark))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final bool isDark;
  const _CampaignCard({required this.campaign, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
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
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTokens.radiusMd),
            ),
            child:
                campaign.coverImageUrl != null &&
                    campaign.coverImageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: campaign.coverImageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => _placeholder(),
                  )
                : _placeholder(),
          ),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: AppTextStyles.titleMedium(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGapSm,
                Text(
                  campaign.description,
                  style: AppTextStyles.bodySmall(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vGapMd,
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: AppTokens.iconXs,
                      color: AppColors.primary,
                    ),
                    AppSpacing.hGapXs,
                    Expanded(
                      child: Text(
                        campaign.location,
                        style: AppTextStyles.caption(color: AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: AppColors.primarySurface,
      child: const Center(
        child: Icon(Icons.campaign, size: 48, color: AppColors.primary),
      ),
    );
  }
}

class _NewsletterSection extends StatelessWidget {
  final bool isDark;
  const _NewsletterSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.section,
        horizontal: AppSpacing.xl,
      ),
      color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
              AppSpacing.vGapLg,
              Text(
                'Stay Connected',
                style: AppTextStyles.headlineMedium(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              AppSpacing.vGapSm,
              Text(
                'Get updates on our campaigns and community impact.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              AppSpacing.vGapXl,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardBg : Colors.white,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppTokens.radiusMd),
                        ),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                      ),
                      child: Center(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: AppTextStyles.bodySmall(
                              color: isDark
                                  ? AppColors.darkTextHint
                                  : AppColors.lightTextHint,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(AppTokens.radiusMd),
                          ),
                        ),
                      ),
                      child: Text(
                        'Subscribe',
                        style: AppTextStyles.button(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

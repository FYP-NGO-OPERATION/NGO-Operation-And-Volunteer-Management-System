import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_tokens.dart';
import '../../../../utils/responsive.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/ngo_provider.dart';
import 'home_stats_grid.dart';
import 'home_latest_announcements.dart';
import 'home_quick_actions.dart';
import 'home_joined_campaigns.dart';

class HomeDashboardTab extends StatelessWidget {
  final Function(int) onTabChange;

  const HomeDashboardTab({Key? key, required this.onTabChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final ngoProvider = Provider.of<NgoProvider>(context);
    final currentNgo = ngoProvider.currentNgo;
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isMobile(context) ? AppSpacing.lg : AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Builder(builder: (context) {
                final primaryColor = Theme.of(context).primaryColor;
                return Container(
                  decoration: BoxDecoration(
                    color: currentNgo?.bannerUrl == null ? null : Colors.black,
                    image: currentNgo?.bannerUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(currentNgo!.bannerUrl!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                          )
                        : null,
                    gradient: currentNgo?.bannerUrl == null
                        ? LinearGradient(
                            colors: [primaryColor, primaryColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: AppTokens.borderRadiusLg,
                    boxShadow: AppTokens.shadowGlow(primaryColor),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: Responsive.isMobile(context) ? 28 : 35,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: user?.profileImageUrl != null
                                ? CachedNetworkImageProvider(user!.profileImageUrl!)
                                : null,
                            child: user?.profileImageUrl == null
                                ? Text(
                                    (user?.name ?? 'U')[0].toUpperCase(),
                                    style: AppTextStyles.headlineMedium(color: Colors.white),
                                  )
                                : null,
                          ),
                          AppSpacing.hGapLg,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentNgo?.welcomeText?.isNotEmpty == true
                                      ? currentNgo!.welcomeText!
                                      : 'welcome_back'.tr(),
                                  style: AppTextStyles.bodySmall(color: Colors.white.withOpacity(0.8)),
                                ),
                                AppSpacing.vGapXs,
                                Text(user?.name ?? 'User',
                                  style: AppTextStyles.headlineMedium(color: Colors.white),
                                  overflow: TextOverflow.ellipsis),
                                AppSpacing.vGapSm,
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: AppTokens.borderRadiusPill,
                                      ),
                                      child: Text(
                                        user?.isAdmin == true ? '👑 Admin' : '🤝 Volunteer',
                                        style: AppTextStyles.labelSmall(color: Colors.white),
                                      ),
                                    ),
                                    if (currentNgo != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: AppTokens.borderRadiusPill,
                                        ),
                                        child: Text(
                                          '🏢 ${currentNgo.name}',
                                          style: AppTextStyles.labelSmall(color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (currentNgo != null && (currentNgo.missionStatement?.isNotEmpty == true || currentNgo.description.isNotEmpty)) ...[
                        AppSpacing.vGapMd,
                        Text(
                          currentNgo.missionStatement?.isNotEmpty == true
                              ? currentNgo.missionStatement!
                              : currentNgo.description,
                          style: AppTextStyles.bodySmall(color: Colors.white.withOpacity(0.85)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                );
              }),
              AppSpacing.vGapXl,
              const HomeStatsGrid(),
              AppSpacing.vGapXl,
              const HomeLatestAnnouncements(),
              AppSpacing.vGapXl,
              HomeQuickActions(
                user: user,
                ngoProvider: ngoProvider,
                onTabChange: onTabChange,
              ),
              const SizedBox(height: 24),
              if (user != null && !user.isAdmin) ...[
                HomeJoinedCampaigns(
                  userId: user.uid,
                  onTabChange: onTabChange,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

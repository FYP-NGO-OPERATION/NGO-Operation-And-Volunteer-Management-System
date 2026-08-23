import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_tokens.dart';
import '../../../../config/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/ngo_provider.dart';
import '../../../../models/announcement_model.dart';
import '../../../../services/announcement_service.dart';
import '../../announcements/announcement_list_screen.dart';
import '../../../../providers/virtual_session_provider.dart';
import '../../sessions/session_list_screen.dart';
import 'home_quick_actions.dart';
import 'home_joined_campaigns.dart';

class HomeDashboardTab extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeDashboardTab({Key? key, required this.onTabChange}) : super(key: key);

  @override
  State<HomeDashboardTab> createState() => _HomeDashboardTabState();
}

class _HomeDashboardTabState extends State<HomeDashboardTab> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final currentNgo = Provider.of<NgoProvider>(context).currentNgo;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {}); // trigger rebuild
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP CAROUSEL (1:1 Ratio)
            if (user != null)
              AspectRatio(
                aspectRatio: 1.0, // Square like Rekhta
                child: Stack(
                  children: [
                    PageView(
                      controller: _pageController,
                      children: [
                        _buildWelcomeSlide(context, user, currentNgo, isDark),
                        if (currentNgo != null) _buildNgoSlide(context, currentNgo, isDark),
                        _buildStatsSlide(context, user, isDark),
                      ],
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: currentNgo != null ? 3 : 2,
                          effect: ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: Theme.of(context).primaryColor,
                            dotColor: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // QUICK ACTIONS (Horizontal Scroll)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkScaffoldBg : AppColors.lightScaffoldBg,
                border: Border(bottom: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
              ),
              child: HomeQuickActions(
                user: user,
                ngoProvider: Provider.of<NgoProvider>(context, listen: false),
                onTabChange: widget.onTabChange,
              ),
            ),

            // FEED SECTION
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Feed", style: AppTextStyles.headlineMedium()),
                  AppSpacing.vGapLg,
                  
                  // Upcoming Sessions
                  Consumer<VirtualSessionProvider>(
                    builder: (context, sessionProvider, child) {
                      final upcomingSessions = sessionProvider.sessions.where((s) => s.isUpcoming).toList();
                      if (upcomingSessions.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Upcoming Sessions', style: AppTextStyles.titleMedium().copyWith(fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Virtual Sessions')), body: const SessionListScreen())));
                                },
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: upcomingSessions.length > 3 ? 3 : upcomingSessions.length,
                              itemBuilder: (context, index) {
                                final session = upcomingSessions[index];
                                return _buildSessionCardMini(context, session, isDark);
                              },
                            ),
                          ),
                          AppSpacing.vGapLg,
                        ],
                      );
                    },
                  ),

                  // Latest Announcements Feed
                  StreamBuilder<List<AnnouncementModel>>(
                    stream: AnnouncementService().getLatestAnnouncements(5),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final announcements = snapshot.data ?? [];
                      if (announcements.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: announcements.map((a) => _buildFeedCard(context, a, isDark)).toList(),
                      );
                    },
                  ),

                  AppSpacing.vGapLg,
                  if (user != null && !user.isAdmin)
                    HomeJoinedCampaigns(
                      userId: user.uid,
                      onTabChange: widget.onTabChange,
                    ),
                  
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSlide(BuildContext context, user, currentNgo, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: user?.profileImageUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(user!.profileImageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
              )
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (user?.profileImageUrl == null)
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  child: Text((user?.name ?? 'U')[0].toUpperCase(), style: AppTextStyles.displayMedium(color: Colors.white)),
                ),
              if (user?.profileImageUrl == null) AppSpacing.vGapLg,
              
              Text(
                'Welcome Back',
                style: AppTextStyles.headlineSmall(color: Colors.white70),
              ),
              AppSpacing.vGapSm,
              Text(
                user?.name ?? 'Volunteer',
                style: AppTextStyles.displayMedium(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapLg,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: AppTokens.borderRadiusPill,
                  border: Border.all(color: Colors.white38),
                ),
                child: Text(
                  user?.isAdmin == true ? '👑 Administrator' : '🤝 Community Volunteer',
                  style: AppTextStyles.titleSmall(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNgoSlide(BuildContext context, currentNgo, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        image: currentNgo?.bannerUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(currentNgo!.bannerUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              )
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.apartment, size: 60, color: Colors.white),
              AppSpacing.vGapLg,
              Text(
                currentNgo?.name ?? 'NGO',
                style: AppTextStyles.displayMedium(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapMd,
              Text(
                currentNgo?.missionStatement ?? currentNgo?.description ?? '',
                style: AppTextStyles.titleMedium(color: Colors.white70),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSlide(BuildContext context, user, bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkCardBg : AppColors.primaryLight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 80, color: Colors.amber.shade400),
              AppSpacing.vGapLg,
              Text('Your Impact', style: AppTextStyles.displaySmall(color: isDark ? Colors.white : Colors.black87)),
              AppSpacing.vGapMd,
              Text('Every action makes a difference.', style: AppTextStyles.titleMedium(color: isDark ? Colors.white70 : Colors.black54)),
              AppSpacing.vGapXl,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCircle('Level', '${user?.level ?? 1}', isDark),
                  _buildStatCircle('XP', '${user?.xp ?? 0}', isDark),
                  _buildStatCircle('Hours', '${user?.volunteerHours ?? 0}', isDark),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCircle(String label, String value, bool isDark) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Center(
            child: Text(value, style: AppTextStyles.headlineMedium(color: isDark ? Colors.white : AppColors.primary)),
          ),
        ),
        AppSpacing.vGapSm,
        Text(label, style: AppTextStyles.labelLarge(color: isDark ? Colors.white70 : Colors.black87)),
      ],
    );
  }

  Widget _buildFeedCard(BuildContext context, AnnouncementModel a, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusLg,
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementListScreen()));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.imageUrl != null)
              CachedNetworkImage(
                imageUrl: a.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(height: 250, color: AppColors.neutral200, child: const Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => Container(height: 250, color: AppColors.neutral200, child: const Icon(Icons.error)),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ANNOUNCEMENT',
                          style: AppTextStyles.labelSmall(color: AppColors.error),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM dd').format(a.createdAt),
                        style: AppTextStyles.labelMedium(color: AppColors.textHint),
                      ),
                    ],
                  ),
                  AppSpacing.vGapMd,
                  Text(
                    a.title,
                    style: AppTextStyles.headlineSmall(color: isDark ? Colors.white : Colors.black87),
                  ),
                  AppSpacing.vGapSm,
                  Text(
                    a.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium(color: isDark ? Colors.white70 : AppColors.textSecondary),
                  ),
                  AppSpacing.vGapMd,
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary,
                        child: Text(a.authorName[0].toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                      AppSpacing.hGapSm,
                      Text(a.authorName, style: AppTextStyles.labelMedium()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCardMini(BuildContext context, dynamic session, bool isDark) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionListScreen()));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (session.imageUrl != null)
              CachedNetworkImage(
                imageUrl: session.imageUrl!,
                height: 80,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 80,
                width: double.infinity,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.videocam, color: AppColors.primary),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.title, style: AppTextStyles.titleSmall().copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat('MMM d • hh:mm a').format(session.sessionDate),
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
      ),
    );
  }
}

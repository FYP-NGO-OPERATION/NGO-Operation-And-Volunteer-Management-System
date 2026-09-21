import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
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
import '../../../../models/incident_model.dart';
import '../../../../services/announcement_service.dart';
import '../../announcements/announcement_list_screen.dart';
import '../../../../providers/virtual_session_provider.dart';
import '../../sessions/session_list_screen.dart';
import 'home_quick_actions.dart';
import 'home_joined_campaigns.dart';
import '../../volunteers/volunteer_disaster_map_screen.dart';
import '../../../../widgets/common/dynamic_banner_carousel.dart';

class HomeDashboardTab extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeDashboardTab({Key? key, required this.onTabChange})
    : super(key: key);

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
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Welcome Banner
            if (user != null)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _AnimatedUserBanner(
                  user: user,
                  currentNgo: currentNgo,
                  theme: Theme.of(context),
                ),
              ),

            // TOP DYNAMIC BANNER CAROUSEL
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        AppSpacing.hGapSm,
                        Text(
                          'Trending Now',
                          style: AppTextStyles.headlineMedium().copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.vGapMd,
                    const DynamicBannerCarousel(),
                  ],
                ),
              ),

            // QUICK ACTIONS (Horizontal Scroll)
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkScaffoldBg
                    : AppColors.lightScaffoldBg,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
                  ),
                ),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.dynamic_feed_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      AppSpacing.hGapSm,
                      Text(
                        "Today's Feed",
                        style: AppTextStyles.headlineMedium().copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vGapLg,

                  // My Active SOS Alerts
                  if (user != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('sos_alerts')
                          .where('userId', isEqualTo: user.uid)
                          .where('status', isEqualTo: 'active')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                          return const SizedBox.shrink();
                        return Column(
                          children: snapshot.data!.docs
                              .map(
                                (doc) => Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                    bottom: AppSpacing.lg,
                                  ),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: AppTokens.borderRadiusLg,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.error.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          "Your SOS Alert is Active!",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: AppColors.error,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('sos_alerts')
                                              .doc(doc.id)
                                              .update({'status': 'resolved'});
                                        },
                                        child: const Text(
                                          "CANCEL SOS",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),

                  // Emergency Alerts (Volunteers only)
                  if (user?.isAdmin != true)
                    StreamBuilder<List<IncidentModel>>(
                      stream: IncidentService().getActiveIncidents(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty)
                          return const SizedBox.shrink();
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Scaffold(
                                      body: SafeArea(
                                        child: VolunteerDisasterMapScreen(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  gradient: AppColors.emergencyGradient,
                                  borderRadius: AppTokens.borderRadiusLg,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.error.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'EMERGENCY MISSION',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${snapshot.data!.length} active disaster(s) near you.',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AppSpacing.vGapLg,
                          ],
                        );
                      },
                    ),

                  // Upcoming Sessions
                  Consumer<VirtualSessionProvider>(
                    builder: (context, sessionProvider, child) {
                      final upcomingSessions = sessionProvider.sessions
                          .where((s) => s.isUpcoming)
                          .toList();
                      if (upcomingSessions.isEmpty)
                        return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Upcoming Sessions',
                                style: AppTextStyles.titleMedium().copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(
                                          title: const Text('Virtual Sessions'),
                                        ),
                                        body: const SessionListScreen(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: upcomingSessions.length > 3
                                  ? 3
                                  : upcomingSessions.length,
                              itemBuilder: (context, index) {
                                final session = upcomingSessions[index];
                                return _buildSessionCardMini(
                                  context,
                                  session,
                                  isDark,
                                );
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
                        children: announcements
                            .map((a) => _buildFeedCard(context, a, isDark))
                            .toList(),
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

  Widget _buildWelcomeSlide(
    BuildContext context,
    user,
    currentNgo,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: user?.profileImageUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(user!.profileImageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.6),
                  BlendMode.darken,
                ),
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
                  child: Text(
                    (user?.name ?? 'U')[0].toUpperCase(),
                    style: AppTextStyles.displayMedium(color: Colors.white),
                  ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: AppTokens.borderRadiusPill,
                  border: Border.all(color: Colors.white38),
                ),
                child: Text(
                  user?.isAdmin == true
                      ? '👑 Administrator'
                      : '🤝 Community Volunteer',
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
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
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
              Text(
                'Your Impact',
                style: AppTextStyles.displaySmall(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              AppSpacing.vGapMd,
              Text(
                'Every action makes a difference.',
                style: AppTextStyles.titleMedium(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              AppSpacing.vGapXl,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCircle('Level', '${user?.level ?? 1}', isDark),
                  _buildStatCircle('XP', '${user?.xp ?? 0}', isDark),
                  _buildStatCircle(
                    'Hours',
                    '${user?.volunteerHours ?? 0}',
                    isDark,
                  ),
                ],
              ),
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
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: Text(
              value,
              style: AppTextStyles.headlineMedium(
                color: isDark ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ),
        AppSpacing.vGapSm,
        Text(
          label,
          style: AppTextStyles.labelLarge(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedCard(
    BuildContext context,
    AnnouncementModel a,
    bool isDark,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              AppColors.primary.withOpacity(0.03),
            ],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnnouncementListScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          a.authorName.isNotEmpty
                              ? a.authorName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.hGapMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.authorName,
                            style: AppTextStyles.titleMedium().copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(a.createdAt),
                            style: AppTextStyles.labelSmall(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.campaign,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Update',
                            style: AppTextStyles.labelSmall(
                              color: AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  a.title,
                  style: AppTextStyles.headlineSmall().copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  a.message,
                  style: const TextStyle(height: 1.6, fontSize: 15),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (a.imageUrl != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: a.imageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        color: AppColors.neutral200,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: AppColors.neutral200,
                        child: const Center(
                          child: Icon(Icons.error, color: AppColors.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCardMini(
    BuildContext context,
    dynamic session,
    bool isDark,
  ) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SessionListScreen()),
          );
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
                  Text(
                    session.title,
                    style: AppTextStyles.titleSmall().copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat(
                            'MMM d • hh:mm a',
                          ).format(session.sessionDate),
                          style: AppTextStyles.caption(
                            color: AppColors.primary,
                          ),
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

class _AnimatedUserBanner extends StatelessWidget {
  final dynamic user;
  final dynamic currentNgo;
  final ThemeData theme;

  const _AnimatedUserBanner({
    required this.user,
    required this.currentNgo,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTokens.borderRadiusLg,
        border: Border.all(
          color: isDark
              ? Colors.tealAccent.withOpacity(0.35)
              : Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.tealAccent.withOpacity(0.2)
                : const Color(0xFF2E7D32).withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppTokens.borderRadiusLg,
        child: Stack(
          children: [
            // Static multi-gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A), // Deep Slate
                            const Color(0xFF312E81), // Deep Indigo
                            const Color(0xFF115E59), // Deep Teal
                            const Color(0xFF0F172A),
                          ]
                        : [
                            const Color(0xFF021B0B), // Extremely dark green
                            const Color(0xFF052B14),
                            const Color(0xFF093D1E),
                            const Color(0xFF021B0B),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            // Static Magical Stars
            ...List.generate(18, (index) {
              final opacity = 0.6 + (index % 3) * 0.15;
              final size = 2.0 + (index % 4) * 1.5;

              final top = 10.0 + (index * 31.0) % 110;
              final left = 10.0 + (index * 83.0) % 320;

              final starColors = [
                Colors.white,
                Colors.yellowAccent.shade100,
                Colors.cyanAccent.shade100,
                Colors.lightGreenAccent.shade100,
              ];
              final starColor = starColors[index % starColors.length];

              return Positioned(
                top: top,
                left: left,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: starColor,
                      boxShadow: [
                        BoxShadow(
                          color: starColor.withOpacity(0.8),
                          blurRadius: size * 1.5,
                          spreadRadius: size * 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Frosted glass overlay
            Positioned.fill(
              child: Container(
                color: isDark
                    ? Colors.black.withOpacity(0.15)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  // Profile pic with static neon ring
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: isDark
                            ? [
                                Colors.tealAccent,
                                Colors.cyanAccent,
                                Colors.greenAccent,
                                Colors.tealAccent,
                              ]
                            : [
                                Colors.white,
                                Colors.greenAccent,
                                Colors.white,
                                Colors.lightGreenAccent,
                                Colors.white,
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.tealAccent.withOpacity(0.6)
                              : Colors.greenAccent.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      backgroundImage: user?.profileImageUrl != null
                          ? CachedNetworkImageProvider(user!.profileImageUrl!)
                          : null,
                      child: user?.profileImageUrl == null
                          ? Text(
                              (user?.name ?? 'V')[0].toUpperCase(),
                              style: AppTextStyles.displaySmall(
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  AppSpacing.hGapLg,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: AppTextStyles.bodyMedium(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        AppSpacing.vGapXs,
                        Text(
                          user?.name ?? 'Volunteer',
                          style: AppTextStyles.headlineLarge(
                            color: Colors.white,
                          ).copyWith(letterSpacing: 0.5),
                        ),
                        AppSpacing.vGapSm,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              isDark ? 0.08 : 0.18,
                            ),
                            borderRadius: AppTokens.borderRadiusPill,
                            border: Border.all(
                              color: isDark
                                  ? Colors.tealAccent.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.6),
                            ),
                            boxShadow: isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.tealAccent.withOpacity(
                                        0.12,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            '🤝 ${currentNgo?.name ?? 'Community Volunteer'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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

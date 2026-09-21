import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../screens/admin/analytics_screen.dart';
import '../../screens/campaigns/campaign_list_screen.dart';
import '../../screens/announcements/announcement_list_screen.dart';
import '../../screens/sessions/create_session_screen.dart';
import '../../screens/sessions/session_list_screen.dart';
import '../../widgets/common/dynamic_banner_carousel.dart';
import '../../utils/cleanup_test_data.dart';

class AdminDashboardScreen extends StatefulWidget {
  final void Function(int)? onNavigate;

  const AdminDashboardScreen({super.key, this.onNavigate});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // One-time cleanup of test data
    CleanupTestData.run();
    _secureScreen();
  }

  Future<void> _secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void dispose() {
    FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _AnimatedAdminBanner(user: user, theme: theme),
            AppSpacing.vGapXl,

            // Banners Section
            Row(
              children: [
                Icon(
                  Icons.view_carousel_rounded,
                  color: theme.primaryColor,
                  size: 24,
                ),
                AppSpacing.hGapSm,
                Text('Featured Banners', style: AppTextStyles.headlineSmall()),
              ],
            ),
            AppSpacing.vGapMd,
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: DynamicBannerCarousel(),
            ),
            AppSpacing.vGapXl,

            Text('Quick Access', style: AppTextStyles.headlineSmall()),
            AppSpacing.vGapMd,
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildActionCard(
                  context,
                  title: 'Impact Metrics',
                  icon: Icons.analytics,
                  color: isDark ? Colors.lightBlueAccent : Colors.blue.shade600,
                  isDark: isDark,
                  onTap: () {
                    if (widget.onNavigate != null) {
                      widget.onNavigate!(7); // 7 is Analytics
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnalyticsScreen(),
                        ),
                      );
                    }
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Virtual Sessions',
                  icon: Icons.video_call,
                  color: isDark
                      ? Colors.purpleAccent.shade200
                      : Colors.purple.shade500,
                  isDark: isDark,
                  onTap: () {
                    if (widget.onNavigate != null) {
                      widget.onNavigate!(6); // 6 is Virtual Sessions
                    } else {
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
                    }
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Campaigns',
                  icon: Icons.campaign,
                  color: isDark
                      ? Colors.greenAccent.shade400
                      : AppColors.primary,
                  isDark: isDark,
                  onTap: () {
                    if (widget.onNavigate != null) {
                      widget.onNavigate!(2); // 2 is Campaigns
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: const Text('Campaigns')),
                            body: const CampaignListScreen(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Announcements',
                  icon: Icons.announcement,
                  color: isDark ? Colors.amberAccent : AppColors.warning,
                  isDark: isDark,
                  onTap: () {
                    if (widget.onNavigate != null) {
                      widget.onNavigate!(5); // 5 is Announcements
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const Scaffold(body: AnnouncementListScreen()),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),

            AppSpacing.vGapXl,
            Text('Management', style: AppTextStyles.headlineSmall()),
            AppSpacing.vGapMd,

            _buildListAction(
              context,
              title: 'Schedule New Session',
              subtitle: 'Host a virtual training or orientation',
              icon: Icons.calendar_today,
              color: isDark ? Colors.greenAccent.shade400 : AppColors.primary,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateSessionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.darkCardBg, AppColors.darkCardBg.withOpacity(0.8)]
                : [Colors.white, Colors.white70],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(isDark ? 0.7 : 0.4),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDark ? 0.5 : 0.3),
              blurRadius: 20,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: color.withOpacity(isDark ? 0.25 : 0.1),
              blurRadius: 30,
              spreadRadius: 6,
            ),
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.white,
              blurRadius: 10,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.35), color.withOpacity(0.12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: color.withOpacity(isDark ? 0.85 : 0.6),
                  width: 2.5,
                ),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.titleMedium(
                color: isDark ? Colors.white : Colors.black87,
              ).copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListAction(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkCardBg, AppColors.darkCardBg.withOpacity(0.9)]
              : [Colors.white, Colors.white.withOpacity(0.9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 6),
            ],
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleSmall().copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.labelSmall(color: AppColors.textHint),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }
}

class _AnimatedAdminBanner extends StatelessWidget {
  final UserModel? user;
  final ThemeData theme;

  const _AnimatedAdminBanner({required this.user, required this.theme});

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
            blurRadius: 10,
            spreadRadius: 3,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 10,
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
                          color: starColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
                              (user?.name ?? 'A')[0].toUpperCase(),
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
                          user?.name ?? 'Admin',
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
                          child: const Text(
                            '\u{1F451} HRAS Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
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

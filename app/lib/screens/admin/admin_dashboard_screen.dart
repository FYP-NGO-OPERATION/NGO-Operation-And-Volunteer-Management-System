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

class AdminDashboardScreen extends StatelessWidget {
  final void Function(int)? onNavigate;

  const AdminDashboardScreen({Key? key, this.onNavigate}) : super(key: key);

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
                Icon(Icons.view_carousel_rounded, color: theme.primaryColor, size: 24),
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
                  color: Colors.blue.shade600,
                  isDark: isDark,
                  onTap: () {
                    if (onNavigate != null) {
                      onNavigate!(7); // 7 is Analytics
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                    }
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Virtual Sessions',
                  icon: Icons.video_call,
                  color: Colors.purple.shade500,
                  isDark: isDark,
                  onTap: () {
                    if (onNavigate != null) {
                      onNavigate!(6); // 6 is Virtual Sessions
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Virtual Sessions')), body: const SessionListScreen())));
                    }
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Campaigns',
                  icon: Icons.campaign,
                  color: AppColors.primary,
                  isDark: isDark,
                  onTap: () {
                    if (onNavigate != null) {
                      onNavigate!(2); // 2 is Campaigns
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Campaigns')), body: const CampaignListScreen())));
                    }
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Announcements',
                  icon: Icons.announcement,
                  color: AppColors.warning,
                  isDark: isDark,
                  onTap: () {
                    if (onNavigate != null) {
                      onNavigate!(5); // 5 is Announcements
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(body: AnnouncementListScreen())));
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
              icon: Icons.event,
              color: Colors.indigo,
              isDark: isDark,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateSessionScreen())),
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
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 8),
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
                  BoxShadow(color: color.withOpacity(0.45), blurRadius: 16, spreadRadius: 2),
                ],
                border: Border.all(color: color.withOpacity(0.7), width: 2),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.titleMedium(color: isDark ? Colors.white : Colors.black87).copyWith(fontWeight: FontWeight.bold),
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
            color: color.withOpacity(0.1),
            blurRadius: 8,
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
        title: Text(title, style: AppTextStyles.titleSmall().copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: AppTextStyles.labelSmall(color: AppColors.textHint)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.white54 : Colors.black54),
      ),
    );
  }
}

class _AnimatedAdminBanner extends StatefulWidget {
  final dynamic user;
  final ThemeData theme;
  const _AnimatedAdminBanner({required this.user, required this.theme});

  @override
  State<_AnimatedAdminBanner> createState() => _AnimatedAdminBannerState();
}

class _AnimatedAdminBannerState extends State<_AnimatedAdminBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * math.pi;

        return Container(
          decoration: BoxDecoration(
            borderRadius: AppTokens.borderRadiusLg,
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF0D3B1E).withOpacity(0.85),
                      const Color(0xFF0A2F2A).withOpacity(0.85),
                    ]
                  : [
                      const Color(0xFF1B8A4A).withOpacity(0.75),
                      const Color(0xFF0D7377).withOpacity(0.75),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark
                  ? Colors.tealAccent.withOpacity(0.25)
                  : Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.tealAccent.withOpacity(0.15)
                    : const Color(0xFF2E7D32).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppTokens.borderRadiusLg,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    // Profile pic with animated neon glow ring
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          startAngle: angle,
                          endAngle: angle + math.pi * 2,
                          colors: isDark
                              ? [
                                  Colors.tealAccent,
                                  Colors.greenAccent.shade400,
                                  Colors.cyanAccent,
                                  Colors.tealAccent,
                                ]
                              : [
                                  Colors.white,
                                  Colors.greenAccent.shade200,
                                  Colors.white,
                                  Colors.tealAccent.shade100,
                                  Colors.white,
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.tealAccent.withOpacity(0.4 + 0.15 * math.sin(angle * 2))
                                : Colors.green.withOpacity(0.3 + 0.1 * math.sin(angle * 2)),
                            blurRadius: 18,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        backgroundImage: widget.user?.profileImageUrl != null
                            ? CachedNetworkImageProvider(widget.user!.profileImageUrl!)
                            : null,
                        child: widget.user?.profileImageUrl == null
                            ? Text(
                                (widget.user?.name ?? 'A')[0].toUpperCase(),
                                style: AppTextStyles.displaySmall(color: Colors.white),
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
                            style: AppTextStyles.bodyMedium(color: Colors.white.withOpacity(0.85)),
                          ),
                          AppSpacing.vGapXs,
                          Text(
                            widget.user?.name ?? 'Admin',
                            style: AppTextStyles.headlineLarge(color: Colors.white),
                          ),
                          AppSpacing.vGapSm,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                              borderRadius: AppTokens.borderRadiusPill,
                              border: Border.all(
                                color: isDark
                                    ? Colors.tealAccent.withOpacity(0.4)
                                    : Colors.white.withOpacity(0.5),
                              ),
                              boxShadow: isDark
                                  ? [
                                      BoxShadow(
                                        color: Colors.tealAccent.withOpacity(0.15),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            child: const Text(
                              '\u{1F451} HRAS Admin',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

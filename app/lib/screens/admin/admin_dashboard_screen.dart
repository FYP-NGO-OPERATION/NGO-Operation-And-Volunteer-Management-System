import 'package:flutter/material.dart';
import 'dart:math' as math;
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
                  colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, spreadRadius: 1),
                ],
                border: Border.all(color: color.withOpacity(0.5)),
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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Rotating gradient using sine and cosine for a smooth magical effect
        final angle = _controller.value * 2 * math.pi;
        final beginAlign = Alignment(math.cos(angle), math.sin(angle));
        final endAlign = Alignment(math.cos(angle + math.pi), math.sin(angle + math.pi));

        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.theme.primaryColor,
                Colors.teal.shade500,
                Colors.indigo.shade400,
                widget.theme.primaryColor,
              ],
              begin: beginAlign,
              end: endAlign,
            ),
            borderRadius: AppTokens.borderRadiusLg,
            boxShadow: AppTokens.shadowGlow(widget.theme.primaryColor),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5 + 0.3 * math.sin(angle * 2)), // Pulsing glow
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.3),
                      blurRadius: 35,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
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
                      style: AppTextStyles.bodyMedium(color: Colors.white70),
                    ),
                    AppSpacing.vGapXs,
                    Text(
                      widget.user?.name ?? 'Admin',
                      style: AppTextStyles.headlineLarge(color: Colors.white).copyWith(
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          )
                        ]
                      ),
                    ),
                    AppSpacing.vGapXs,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppTokens.borderRadiusPill,
                        border: Border.all(color: Colors.white.withOpacity(0.4)),
                        boxShadow: [
                           BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 10, spreadRadius: 2)
                        ]
                      ),
                      child: const Text(
                        '👑 HRAS Admin',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

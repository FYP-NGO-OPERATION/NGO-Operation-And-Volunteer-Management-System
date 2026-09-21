import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as dart_convert;
import 'dart:math' as math;
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/feature_flags.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/ngo_provider.dart';
import '../../utils/responsive.dart';
import '../auth/login_screen.dart';
import '../campaigns/campaign_list_screen.dart';
import '../campaigns/campaign_map_screen.dart';
import '../campaigns/campaign_calendar_screen.dart';
import '../profile/user_list_screen.dart';
import '../ngos/ngo_selection_screen.dart';
import '../admin/analytics_screen.dart';
import '../sessions/engagement_tab_screen.dart';
import '../../widgets/web/web_shell.dart';
import 'components/home_dashboard_tab.dart';
import 'components/home_profile_tab.dart';
import 'components/campaign_search_delegate.dart';
import 'components/home_speed_dial.dart';
import '../shop/shop_list_screen.dart';
import '../profile/leaderboard_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../disaster/disaster_map_screen.dart';
import '../campaigns/route_optimization_screen.dart';
import '../announcements/announcement_list_screen.dart';
import '../../config/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isAdmin = user?.isAdmin == true;
    final isSuperAdmin =
        isAdmin &&
        (user?.currentNgoId == null ||
            user?.currentNgoId == 'HRAS_DEFAULT_ID' ||
            user?.currentNgoId == '');
    final isDesktopOrTablet = !Responsive.isMobile(context);
    final ngoProvider = Provider.of<NgoProvider>(context);
    final currentNgo = ngoProvider.currentNgo;

    // Build dynamic tabs
    final List<Map<String, dynamic>> activeTabs = [
      {
        'label': 'home'.tr(),
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard,
        'screen': HomeDashboardTab(
          onTabChange: (i) => setState(() => _currentIndex = i),
        ),
      },
    ];

    if (currentNgo?.features.contains('campaigns') ?? true) {
      activeTabs.add({
        'label': 'campaigns'.tr(),
        'icon': Icons.campaign_outlined,
        'activeIcon': Icons.campaign,
        'screen': const CampaignListScreen(),
      });
    }

    if ((currentNgo?.features.contains('virtual_sessions') ?? false) ||
        (currentNgo?.features.contains('engagement') ?? false) ||
        (currentNgo?.features.contains('volunteers') ?? true)) {
      activeTabs.add({
        'label': isAdmin ? 'Users' : 'Engagement',
        'icon': Icons.people_outline,
        'activeIcon': Icons.people,
        'screen': isAdmin ? UserListScreen() : const EngagementTabScreen(),
      });
    }

    activeTabs.add({
      'label': 'E-Store',
      'icon': Icons.shopping_bag_outlined,
      'activeIcon': Icons.shopping_bag,
      'screen': const ShopListScreen(),
    });

    activeTabs.add({
      'label': 'Leaderboard',
      'icon': Icons.emoji_events_outlined,
      'activeIcon': Icons.emoji_events,
      'screen': const LeaderboardScreen(),
    });

    activeTabs.add({
      'label': 'profile'.tr(),
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'screen': HomeProfileTab(onLogout: () => _showLogoutDialog(context)),
    });

    if (isAdmin && FeatureFlags.isAnalyticsEnabled) {
      activeTabs.add({
        'label': 'Analytics',
        'icon': Icons.analytics_outlined,
        'activeIcon': Icons.analytics,
        'screen': const AnalyticsScreen(),
      });
    }

    if (_currentIndex >= activeTabs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = 0);
      });
    }

    int safeIndex = _currentIndex < activeTabs.length ? _currentIndex : 0;

    if (isDesktopOrTablet) {
      return WebShell(
        currentIndex: safeIndex,
        onIndexChanged: (i) => setState(() => _currentIndex = i),
        tabs: activeTabs,
        isAdmin: isAdmin,
        userName: user?.name ?? 'User',
        userImageUrl: user?.profileImageUrl,
        onLogout: () => _showLogoutDialog(context),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      currentNgo?.logoUrl != null &&
                          currentNgo!.logoUrl!.isNotEmpty
                      ? (currentNgo.logoUrl!.startsWith('data:image')
                            ? Image.memory(
                                dart_convert.base64Decode(
                                  currentNgo.logoUrl!.split(',').last,
                                ),
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: currentNgo.logoUrl!,
                                fit: BoxFit.cover,
                              ))
                      : Image.asset(AppConstants.logoPath, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  currentNgo?.name ?? AppConstants.orgName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            if (_currentIndex == 1) ...[
              IconButton(
                icon: const Icon(Icons.calendar_month),
                tooltip: 'calendar_view'.tr(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CampaignCalendarScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search Campaigns',
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: CampaignSearchDelegate(
                      Provider.of<CampaignProvider>(context, listen: false),
                    ),
                  );
                },
              ),
            ],
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  tooltip: themeProvider.isDarkMode
                      ? 'Light Mode'
                      : 'Dark Mode',
                  onPressed: () => themeProvider.toggleTheme(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'Explore Live Map',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CampaignMapScreen()),
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkScaffoldBg
              : AppColors.lightScaffoldBg,
          child: Column(
            children: [
              _AnimatedDrawerHeader(
                user: user,
                currentNgo: currentNgo,
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _currentIndex = 0);
                      },
                      isSelected: _currentIndex == 0,
                    ),
                    if (currentNgo?.features.contains('campaigns') ?? true)
                      _buildDrawerItem(
                        context,
                        icon: Icons.campaign,
                        title: 'Campaigns',
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 1);
                        },
                        isSelected: _currentIndex == 1,
                      ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.map,
                      title: 'Disaster Map',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DisasterMapScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.route,
                      title: 'Optimize Routes',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RouteOptimizationScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.announcement,
                      title: 'Announcements',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                Scaffold(body: const AnnouncementListScreen()),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.emoji_events,
                      title: 'Leaderboard',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: activeTabs[safeIndex]['screen'] as Widget,
        floatingActionButton: HomeSpeedDial(
          isAdmin: isAdmin,
          isSuperAdmin: isSuperAdmin,
          currentNgo: currentNgo,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: activeTabs
              .map(
                (t) => BottomNavigationBarItem(
                  icon: Icon(t['icon'] as IconData),
                  activeIcon: Icon(t['activeIcon'] as IconData),
                  label: t['label'] as String,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final navigator = Navigator.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (authProvider.user != null) {
        final ngoProvider = Provider.of<NgoProvider>(context, listen: false);
        final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
        final sessionProvider = Provider.of<VirtualSessionProvider>(context, listen: false);
        
        await ngoProvider.clearNgo(authProvider.user!);
        // Clear sensitive cache arrays
        campaignProvider.clear();
        sessionProvider.clear();
      }
      await authProvider.logout();
      if (mounted) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _switchNgo(BuildContext context) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final ngoProvider = Provider.of<NgoProvider>(context, listen: false);
    await ngoProvider.clearNgo(user);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const NgoSelectionScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected ? AppColors.primaryGradient : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(
            icon,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.neutral600),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.neutral800),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _AnimatedDrawerHeader extends StatelessWidget {
  final dynamic user;
  final dynamic currentNgo;
  final bool isDark;

  const _AnimatedDrawerHeader({
    required this.user,
    required this.currentNgo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.tealAccent.withOpacity(0.2)
                : const Color(0xFF2E7D32).withOpacity(0.25),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Stack(
          children: [
            // Static multi-gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A),
                            const Color(0xFF312E81),
                            const Color(0xFF115E59),
                            const Color(0xFF0F172A),
                          ]
                        : [
                            const Color(0xFF021B0B),
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
            ...List.generate(12, (index) {
              final opacity = 0.6 + (index % 3) * 0.15;
              final size = 2.0 + (index % 4) * 1.5;

              final top = 10.0 + (index * 31.0) % 150;
              final left = 10.0 + (index * 83.0) % 250;

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
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      radius: 36,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      backgroundImage: user?.profileImageUrl != null
                          ? CachedNetworkImageProvider(user!.profileImageUrl!)
                          : null,
                      child: user?.profileImageUrl == null
                          ? Text(
                              (user?.name ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Volunteer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentNgo?.name ?? 'Community Volunteer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
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

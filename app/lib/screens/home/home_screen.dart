import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as dart_convert;
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
import '../profile/user_list_screen.dart';
import '../ngos/ngo_selection_screen.dart';
import '../admin/analytics_screen.dart';
import '../sessions/engagement_tab_screen.dart';
import '../../widgets/web/web_shell.dart';
import 'components/home_dashboard_tab.dart';
import 'components/home_profile_tab.dart';
import 'components/campaign_search_delegate.dart';
import 'components/home_speed_dial.dart';

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
    final isSuperAdmin = isAdmin && (user?.currentNgoId == null || user?.currentNgoId == 'HRAS_DEFAULT_ID' || user?.currentNgoId == '');
    final isDesktopOrTablet = !Responsive.isMobile(context);
    final ngoProvider = Provider.of<NgoProvider>(context);
    final currentNgo = ngoProvider.currentNgo;

    // Build dynamic tabs
    final List<Map<String, dynamic>> activeTabs = [
      {
        'label': 'home'.tr(),
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard,
        'screen': HomeDashboardTab(onTabChange: (i) => setState(() => _currentIndex = i)),
      }
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
                  child: currentNgo?.logoUrl != null && currentNgo!.logoUrl!.isNotEmpty
                      ? (currentNgo.logoUrl!.startsWith('data:image')
                          ? Image.memory(
                              dart_convert.base64Decode(currentNgo.logoUrl!.split(',').last),
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: currentNgo.logoUrl!,
                              fit: BoxFit.cover,
                            ))
                      : Image.asset(
                          AppConstants.logoPath,
                          fit: BoxFit.contain,
                        ),
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
            if (_currentIndex == 1)
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
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
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
        body: activeTabs[safeIndex]['screen'] as Widget,
        floatingActionButton: HomeSpeedDial(
          isAdmin: isAdmin,
          isSuperAdmin: isSuperAdmin,
          currentNgo: currentNgo,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: activeTabs.map((t) => BottomNavigationBarItem(
            icon: Icon(t['icon'] as IconData),
            activeIcon: Icon(t['activeIcon'] as IconData),
            label: t['label'] as String,
          )).toList(),
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
      final ngoProvider = Provider.of<NgoProvider>(context, listen: false);
      if (authProvider.user != null) {
        await ngoProvider.clearNgo(authProvider.user!);
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
}

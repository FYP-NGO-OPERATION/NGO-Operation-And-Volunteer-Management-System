import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/feature_flags.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/admin/analytics_screen.dart';
import '../../screens/admin/admin_donations_screen.dart';
import '../../screens/profile/user_list_screen.dart';
import '../../screens/campaigns/campaign_list_screen.dart';
import '../../screens/campaigns/create_campaign_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../screens/announcements/create_announcement_screen.dart';
import '../../screens/admin/platform_requests_screen.dart';
import '../../screens/admin/blood_emergency_screen.dart';
import '../../screens/admin/sentiment_analysis_screen.dart';
import '../../screens/campaigns/route_optimization_screen.dart';
import '../../screens/disaster/disaster_map_screen.dart';
import '../../providers/disaster_provider.dart';
import '../../widgets/common/custom_speed_dial.dart';
import '../profile_tab_widget.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  late final List<Widget> _pages = [
    FeatureFlags.isAnalyticsEnabled
        ? const AnalyticsScreen()
        : const AdminDonationsScreen(), // FYP1: show donations as default dashboard
    const UserListScreen(),
    const CampaignListScreen(),
    const AdminDonationsScreen(),
    const PlatformRequestsScreen(),
    _buildAdminProfile(),
  ];

  Widget _buildAdminProfile() {
    return ProfileTab(
      onLogout: () {
        Provider.of<AuthProvider>(context, listen: false).logout();
      },
    );
  }

  final List<NavigationRailDestination> _destinations = const [
    NavigationRailDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: Text('Dashboard'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: Text('Users'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.campaign_outlined),
      selectedIcon: Icon(Icons.campaign),
      label: Text('Campaigns'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.monetization_on_outlined),
      selectedIcon: Icon(Icons.monetization_on),
      label: Text('Donations'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.verified_user_outlined),
      selectedIcon: Icon(Icons.verified_user),
      label: Text('Platform Requests'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Profile'),
    ),
  ];

  void _listenToVoiceCommand() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            final text = val.recognizedWords.toLowerCase();
            if (val.hasConfidenceRating && val.confidence > 0) {
              _processVoiceCommand(text);
            }
          },
        );
        // Stop listening after 4 seconds
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted && _isListening) {
            _speech.stop();
            setState(() => _isListening = false);
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processVoiceCommand(String text) {
    setState(() => _isListening = false);
    _speech.stop();
    
    if (text.contains('route') || text.contains('tsp')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteOptimizationScreen()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice Command: Opening Route Optimization')));
    } else if (text.contains('sentiment') || text.contains('ai')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SentimentAnalysisScreen()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice Command: Opening AI Sentiment')));
    } else if (text.contains('disaster') || text.contains('map')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DisasterMapScreen()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voice Command: Opening Disaster Map')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Admin Panel'),
              backgroundColor: Provider.of<DisasterProvider>(context).isEmergencyMode ? Colors.red : null,
              actions: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.amber : null),
                  tooltip: 'Voice Command',
                  onPressed: _listenToVoiceCommand,
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return IconButton(
                      icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                      tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                      onPressed: () => themeProvider.toggleTheme(),
                    );
                  },
                ),
                Consumer<DisasterProvider>(
                  builder: (context, dp, _) => IconButton(
                    icon: Icon(dp.isEmergencyMode ? Icons.warning : Icons.health_and_safety, color: dp.isEmergencyMode ? Colors.yellow : null),
                    tooltip: 'Toggle Disaster Mode',
                    onPressed: () => dp.toggleEmergencyMode(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => authProvider.logout(),
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: theme.primaryColor),
                    child: const Text(
                      'NGO Admin',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  for (int i = 0; i < _destinations.length; i++)
                    ListTile(
                      leading: _selectedIndex == i
                          ? _destinations[i].selectedIcon
                          : _destinations[i].icon,
                      title: _destinations[i].label,
                      selected: _selectedIndex == i,
                      onTap: () {
                        setState(() => _selectedIndex = i);
                        Navigator.pop(context); // Close drawer
                      },
                    ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () => authProvider.logout(),
                  ),
                ],
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              extended: MediaQuery.of(context).size.width >= 1000,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              leading: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                    radius: 25,
                    child: Icon(Icons.admin_panel_settings, color: theme.primaryColor),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Logout',
                      onPressed: () => authProvider.logout(),
                    ),
                  ),
                ),
              ),
              destinations: _destinations,
            ),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      floatingActionButton: CustomSpeedDial(
        actions: [
          SpeedDialAction(
            icon: Icons.campaign,
            label: 'Add Campaign',
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCampaignScreen()));
            },
          ),
          SpeedDialAction(
            icon: Icons.announcement,
            label: 'Add Announcement',
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()));
            },
          ),
          SpeedDialAction(
            icon: Icons.bloodtype,
            label: 'Blood Emergency',
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodEmergencyScreen()));
            },
          ),
          SpeedDialAction(
            icon: Icons.map,
            label: 'Disaster Map',
            backgroundColor: Colors.orange.shade800,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DisasterMapScreen()));
            },
          ),
          SpeedDialAction(
            icon: Icons.route,
            label: 'Optimize Routes',
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteOptimizationScreen()));
            },
          ),
          SpeedDialAction(
            icon: Icons.pie_chart,
            label: 'AI Sentiment',
            backgroundColor: Colors.purple.shade600,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SentimentAnalysisScreen()));
            },
          ),
        ],
      ),
    );
  }
}

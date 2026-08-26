import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/feature_flags.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../screens/admin/analytics_screen.dart';
import '../../screens/admin/admin_donations_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/profile/user_list_screen.dart';
import '../../screens/campaigns/campaign_list_screen.dart';
import '../../screens/campaigns/create_campaign_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../screens/announcements/announcement_list_screen.dart';
import '../../screens/sessions/session_list_screen.dart';
import '../../screens/admin/platform_requests_screen.dart';
import '../../screens/admin/blood_emergency_screen.dart';
import '../../screens/admin/sentiment_analysis_screen.dart';
import '../../screens/campaigns/route_optimization_screen.dart';
import '../../screens/disaster/disaster_map_screen.dart';
import '../../screens/admin/admin_banner_management_screen.dart';
import '../../screens/admin/manage_website_screen.dart';
import '../../screens/splash/splash_screen.dart';
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
    AdminDashboardScreen(onNavigate: (index) {
      if (mounted) {
        setState(() => _selectedIndex = index);
      }
    }), // 0. Dashboard
    const UserListScreen(), // 1. Users
    const CampaignListScreen(), // 2. Campaigns
    const AdminDonationsScreen(), // 3. Donations
    const PlatformRequestsScreen(), // 4. Platform Requests
    const AnnouncementListScreen(), // 5. Announcements
    const SessionListScreen(), // 6. Virtual Sessions
    const AnalyticsScreen(), // 7. Analytics
    const SizedBox.shrink(), // 8. Disaster Map (placeholder, pushed instead)
    const AdminBannerManagementScreen(), // 9. Banners
    const SizedBox.shrink(), // 10. Route Optimization (placeholder, pushed instead)
    const SizedBox.shrink(), // 11. Blood Emergency (placeholder, pushed instead)
    const SizedBox.shrink(), // 12. AI Sentiment (placeholder, pushed instead)
    const ManageWebsiteScreen(), // 13. Manage Website
    _buildAdminProfile(), // 14. Profile
  ];

  @override
  void initState() {
    super.initState();
    _listenForSosAlerts();
  }

  void _listenForSosAlerts() {
    FirebaseFirestore.instance
        .collection('sos_alerts')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          _showSosEmergencyDialog(data['userName'] ?? 'A Volunteer', change.doc.id);
        }
      }
    });
  }

  void _showSosEmergencyDialog(String userName, String docId) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 40),
            SizedBox(width: 10),
            Text('EMERGENCY SOS!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('$userName has triggered an SOS Alert! They need immediate assistance.', style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('sos_alerts').doc(docId).update({'status': 'resolved'});
              Navigator.pop(context);
            },
            child: const Text('MARK RESOLVED', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade900),
            onPressed: () {
              Navigator.pop(context);
              // In real app, open DisasterMapScreen and zoom to their location
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DisasterMapScreen()));
            },
            child: const Text('VIEW ON MAP', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProfile() {
    return ProfileTab(
      onLogout: _handleLogout,
    );
  }

  Future<void> _handleLogout() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.orange, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Logout?',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout == true) {
      if (context.mounted) {
        await Provider.of<AuthProvider>(context, listen: false).logout();
        if (context.mounted) {
           Navigator.of(context).pushAndRemoveUntil(
             MaterialPageRoute(builder: (_) => const SplashScreen()), 
             (route) => false,
           );
        }
      }
    }
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
      label: Text('Requests'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.announcement_outlined),
      selectedIcon: Icon(Icons.announcement),
      label: Text('News'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.video_call_outlined),
      selectedIcon: Icon(Icons.video_call),
      label: Text('Sessions'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: Text('Analytics'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: Text('Disasters'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.view_carousel_outlined),
      selectedIcon: Icon(Icons.view_carousel),
      label: Text('Banners'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.route_outlined),
      selectedIcon: Icon(Icons.route),
      label: Text('Routes'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.bloodtype_outlined),
      selectedIcon: Icon(Icons.bloodtype),
      label: Text('Blood Emerg.'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.pie_chart_outline),
      selectedIcon: Icon(Icons.pie_chart),
      label: Text('Sentiment'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.web_outlined),
      selectedIcon: Icon(Icons.web),
      label: Text('Website'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: Text('Profile'),
    ),
  ];

  void _listenToVoiceCommand() async {
    if (!_isListening) {
      bool available = false;
      try {
        available = await _speech.initialize();
      } catch (e) {
        available = false;
      }
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
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Microphone Required'),
              content: const Text('Please allow microphone access in your device settings to use voice commands.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        }
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

  Future<bool> _onWillPop() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.exit_to_app, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                'Exit Application?',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to close the app?',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Exit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }

        final bool shouldPop = await _onWillPop();
        if (shouldPop) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
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
                    onPressed: () async {
                      if (!dp.isEmergencyMode) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Activate Emergency Mode?'),
                            content: const Text('This will alert all volunteers and change the UI to disaster mode. Are you sure?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(context, true), 
                                child: const Text('Activate', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) dp.toggleEmergencyMode();
                      } else {
                        dp.toggleEmergencyMode(); // Turn it off without prompt
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _handleLogout,
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : Drawer(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.darkScaffoldBg : AppColors.lightScaffoldBg,
          child: Column(
            children: [
              _AnimatedDrawerHeader(user: authProvider.user, isDark: Theme.of(context).brightness == Brightness.dark),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      children: [
                        for (int i = 0; i < _destinations.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: _selectedIndex == i
                                    ? AppColors.primaryGradient
                                    : null,
                                boxShadow: _selectedIndex == i
                                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))]
                                    : [],
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                leading: Icon(
                                  _selectedIndex == i
                                      ? (_destinations[i].selectedIcon as Icon).icon
                                      : (_destinations[i].icon as Icon).icon,
                                  color: _selectedIndex == i
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : AppColors.neutral600),
                                ),
                                title: Text(
                                  (_destinations[i].label as Text).data!,
                                  style: TextStyle(
                                    color: _selectedIndex == i
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : AppColors.neutral800),
                                    fontWeight: _selectedIndex == i ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                selected: _selectedIndex == i,
                                onTap: () {
                                  Navigator.pop(context); // Close drawer
                                  if (i == 8) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DisasterMapScreen()));
                                  } else if (i == 10) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteOptimizationScreen()));
                                  } else if (i == 11) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodEmergencyScreen()));
                                  } else if (i == 12) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SentimentAnalysisScreen()));
                                  } else {
                                    setState(() => _selectedIndex = i);
                                  }
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
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
                if (index == 8) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DisasterMapScreen()));
                } else if (index == 10) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteOptimizationScreen()));
                } else if (index == 11) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BloodEmergencyScreen()));
                } else if (index == 12) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SentimentAnalysisScreen()));
                } else {
                  setState(() => _selectedIndex = index);
                }
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
                      onPressed: _handleLogout,
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
            label: 'Announcements',
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Scaffold(body: AnnouncementListScreen())));
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
    ));
  }
}

class _AnimatedDrawerHeader extends StatefulWidget {
  final dynamic user;
  final bool isDark;
  
  const _AnimatedDrawerHeader({required this.user, required this.isDark});

  @override
  State<_AnimatedDrawerHeader> createState() => _AnimatedDrawerHeaderState();
}

class _AnimatedDrawerHeaderState extends State<_AnimatedDrawerHeader> with SingleTickerProviderStateMixin {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * math.pi;
        final shiftX = math.cos(angle) * 0.5;
        final shiftY = math.sin(angle) * 0.5;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? Colors.tealAccent.withOpacity(0.2)
                    : const Color(0xFF2E7D32).withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.35 : 0.08),
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
                // Animated multi-gradient background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isDark
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
                        begin: Alignment(shiftX, shiftY),
                        end: Alignment(-shiftX, -shiftY),
                      ),
                    ),
                  ),
                ),
                // Magical Stars
                ...List.generate(12, (index) {
                  final starAngle = angle * (index % 2 == 0 ? 1 : -1) + (index * math.pi / 4);
                  final opacity = (math.sin(starAngle * (2 + index % 3)) + 1) / 2 * 0.9;
                  final sizeScale = (math.cos(starAngle * 3) + 1) / 2;
                  final baseSize = 2.0 + (index % 4) * 2.0;
                  final size = baseSize + (sizeScale * 3.5);
                  
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
                              color: starColor.withOpacity(0.9),
                              blurRadius: size * 2.0,
                              spreadRadius: size * 0.8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                // Frosted glass overlay
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      color: widget.isDark
                          ? Colors.black.withOpacity(0.15)
                          : Colors.white.withOpacity(0.08),
                    ),
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
                            startAngle: angle,
                            endAngle: angle + math.pi * 2,
                            colors: widget.isDark
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
                              color: widget.isDark
                                  ? Colors.tealAccent.withOpacity(0.55 + 0.25 * math.sin(angle * 2))
                                  : Colors.greenAccent.withOpacity(0.55 + 0.25 * math.sin(angle * 2)),
                              blurRadius: 24,
                              spreadRadius: 6,
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
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.user?.name ?? 'Admin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'HRAS Admin',
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
      },
    );
  }
}


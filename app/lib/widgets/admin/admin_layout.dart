import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/admin/analytics_screen.dart';

import '../../screens/admin/admin_donations_screen.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AnalyticsScreen(),
    const Center(child: Text('User Management (Coming Soon)')),
    const Center(child: Text('Campaign Management (Coming Soon)')),
    const AdminDonationsScreen(),
  ];

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
  ];

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
              actions: [
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
    );
  }
}

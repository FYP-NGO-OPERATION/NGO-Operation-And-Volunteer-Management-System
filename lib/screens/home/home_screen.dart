import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';
import '../auth/login_screen.dart';

/// Main home screen after login — shows dashboard with bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                AppConstants.logoPath,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                AppConstants.orgName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Campaigns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement_outlined),
            activeIcon: Icon(Icons.announcement),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard(context);
      case 1:
        return _buildPlaceholder('Campaigns', Icons.campaign, 'Coming in Phase 3');
      case 2:
        return _buildPlaceholder('Announcements', Icons.announcement, 'Coming in Phase 7');
      case 3:
        return _buildProfileTab(context);
      default:
        return _buildDashboard(context);
    }
  }

  Widget _buildDashboard(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final columns = Responsive.gridColumns(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isMobile(context) ? 16 : 24,
        vertical: 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: Responsive.isMobile(context) ? 28 : 35,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 22 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.name ?? 'User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.isMobile(context) ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user?.isAdmin == true ? '👑 Admin' : '🤝 Volunteer',
                                style: const TextStyle(
                                  color: Colors.white,
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
              ),
              const SizedBox(height: 24),

              // Stats Grid
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: Responsive.isMobile(context) ? 1.4 : 1.6,
                children: [
                  _buildStatCard('Campaigns', '0', Icons.campaign, AppColors.primary),
                  _buildStatCard('Volunteers', '0', Icons.people, AppColors.info),
                  _buildStatCard('Donations', '0', Icons.volunteer_activism, AppColors.warning),
                  _buildStatCard('Families', '0', Icons.family_restroom, AppColors.success),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (user?.isAdmin == true) ...[
                _buildActionTile(
                  'Create Campaign',
                  'Start a new campaign',
                  Icons.add_circle_outline,
                  AppColors.primary,
                  () {},
                ),
                _buildActionTile(
                  'Add Donation',
                  'Record a new donation',
                  Icons.card_giftcard,
                  AppColors.warning,
                  () {},
                ),
              ],
              _buildActionTile(
                'View Campaigns',
                'Browse all campaigns',
                Icons.list_alt,
                AppColors.info,
                () => setState(() => _currentIndex = 1),
              ),
              _buildActionTile(
                'My Profile',
                'View and edit your profile',
                Icons.person_outline,
                AppColors.primaryLight,
                () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 26),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isMobile(context) ? 16 : 24,
        vertical: 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  (user?.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'User',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Chip(
                label: Text(
                  user?.isAdmin == true ? 'Admin' : 'Volunteer',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: AppColors.primary,
                side: BorderSide.none,
              ),
              const SizedBox(height: 24),

              // Info cards
              Card(
                child: Column(
                  children: [
                    _profileTile(Icons.phone, 'Phone', _formatPhone(user?.phone)),
                    const Divider(height: 1),
                    _profileTile(Icons.location_on, 'Address', user?.address ?? 'Not set'),
                    const Divider(height: 1),
                    _profileTile(Icons.campaign, 'Campaigns Joined', '${user?.campaignsJoined ?? 0}'),
                    const Divider(height: 1),
                    _profileTile(Icons.calendar_today, 'Member Since',
                        user?.joinedAt != null
                            ? '${user!.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}'
                            : 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Format phone: 03001234567 → 0300-1234567
  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'N/A';
    if (phone.length == 11 && !phone.contains('-')) {
      return '${phone.substring(0, 4)}-${phone.substring(4)}';
    }
    return phone;
  }

  Widget _profileTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}

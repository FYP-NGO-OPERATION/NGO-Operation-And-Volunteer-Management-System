import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../models/volunteer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/volunteer_service.dart';
import '../../utils/responsive.dart';
import '../auth/login_screen.dart';
import '../campaigns/campaign_list_screen.dart';
import '../campaigns/campaign_detail_screen.dart';
import '../campaigns/create_campaign_screen.dart';
import '../../widgets/common/custom_speed_dial.dart';
import '../profile/change_password_screen.dart';
import '../profile/user_list_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/about_us_screen.dart';
import '../admin/analytics_screen.dart';
import '../announcements/create_announcement_screen.dart';
import '../announcements/announcement_list_screen.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import 'package:intl/intl.dart';

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
    final user = Provider.of<AuthProvider>(context).user;
    final isAdmin = user?.isAdmin == true;

    return Scaffold(
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
          // Search (campaigns tab)
          if (_currentIndex == 1)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search Campaigns',
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _CampaignSearchDelegate(
                    Provider.of<CampaignProvider>(context, listen: false),
                  ),
                );
              },
            ),
          // Dark Mode Toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: _buildBody(context),
      // FAB Speed Dial (Admin on Dashboard & Campaigns tab)
      floatingActionButton: isAdmin
          ? CustomSpeedDial(
              actions: [
                SpeedDialAction(
                  icon: Icons.campaign,
                  label: 'Add Campaign',
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateCampaignScreen()),
                    );
                  },
                ),
                SpeedDialAction(
                  icon: Icons.announcement,
                  label: 'Add Announcement',
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()),
                    );
                  },
                ),
                SpeedDialAction(
                  icon: Icons.analytics,
                  label: 'Analytics & Reports',
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                    );
                  },
                ),
                SpeedDialAction(
                  icon: Icons.manage_accounts,
                  label: 'Manage Users',
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserListScreen()),
                    );
                  },
                ),
              ],
            )
          : null,
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
        return const CampaignListScreen();
      case 2:
        return const AnnouncementListScreen();
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
                        backgroundImage: user?.profileImageUrl != null
                            ? CachedNetworkImageProvider(user!.profileImageUrl!)
                            : null,
                        child: user?.profileImageUrl == null
                            ? Text(
                                (user?.name ?? 'U')[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: Responsive.isMobile(context) ? 22 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
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
                  _buildStatCard('Active Campaigns',
                      '${Provider.of<CampaignProvider>(context).activeCampaigns}',
                      Icons.campaign, AppColors.info),
                  _buildStatCard('Donations',
                      'Rs.${Provider.of<CampaignProvider>(context).totalDonationsOverall.toStringAsFixed(0)}',
                      Icons.volunteer_activism, AppColors.warning),
                  _buildStatCard('Families Helped',
                      '${Provider.of<CampaignProvider>(context).totalBeneficiariesOverall}',
                      Icons.family_restroom, AppColors.success),
                  _buildStatCard('Items Distributed',
                      '${Provider.of<CampaignProvider>(context).totalItemsDistributedOverall}',
                      Icons.inventory_2, AppColors.primary),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Latest Announcements ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Updates',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnnouncementListScreen()),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildLatestAnnouncements(),
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
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateCampaignScreen()),
                  ),
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
              const SizedBox(height: 24),

              // ─── My Joined Campaigns (Volunteer view) ───
              if (user != null && !user.isAdmin) ...[
                Text(
                  'My Campaigns',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMyJoinedCampaigns(user.uid),
              ],
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

  /// Shows list of campaigns the current volunteer has joined
  Widget _buildMyJoinedCampaigns(String userId) {
    return StreamBuilder<List<VolunteerModel>>(
      stream: VolunteerService().getUserCampaignsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.campaign_outlined, size: 40, color: AppColors.lightTextHint),
                  const SizedBox(height: 8),
                  const Text(
                    'Not joined any campaign yet',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: const Text('Browse Campaigns →'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: records.take(5).map((record) {
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _volunteerStatusColor(record.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.campaign, color: _volunteerStatusColor(record.status)),
                ),
                title: Text(
                  record.campaignTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Status: ${record.status.label}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _volunteerStatusColor(record.status),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  // Navigate to campaign detail
                  final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
                  final campaign = campaignProvider.campaigns.firstWhere(
                    (c) => c.id == record.campaignId,
                    orElse: () => campaignProvider.campaigns.first,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CampaignDetailScreen(campaign: campaign),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLatestAnnouncements() {
    return StreamBuilder<List<AnnouncementModel>>(
      stream: AnnouncementService().getLatestAnnouncements(2),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final announcements = snapshot.data ?? [];
        if (announcements.isEmpty) {
          return const Text('No recent announcements', style: TextStyle(color: AppColors.textHint));
        }

        return Column(
          children: announcements.map((a) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: AppColors.warning.withValues(alpha: 0.1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: const Icon(Icons.campaign, color: AppColors.warning),
                title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  a.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  DateFormat('MMM dd').format(a.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnnouncementListScreen()),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Color _volunteerStatusColor(dynamic status) {
    switch (status.toString()) {
      case 'VolunteerStatus.registered':
        return AppColors.info;
      case 'VolunteerStatus.confirmed':
        return AppColors.warning;
      case 'VolunteerStatus.attended':
        return AppColors.success;
      case 'VolunteerStatus.absent':
        return AppColors.error;
      default:
        return AppColors.info;
    }
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
                backgroundImage: user?.profileImageUrl != null
                    ? CachedNetworkImageProvider(user!.profileImageUrl!)
                    : null,
                child: user?.profileImageUrl == null
                    ? Text(
                        (user?.name ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
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
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
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
              if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    user.bio!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Info cards
              Card(
                child: Column(
                  children: [
                    _profileTile(Icons.email, 'Email', user?.email ?? 'N/A'),
                    const Divider(height: 1),
                    _profileTile(Icons.phone, 'Phone', _formatPhone(user?.phone)),
                    const Divider(height: 1),
                    _profileTile(Icons.info_outline, 'Bio', user?.bio != null && user!.bio!.isNotEmpty ? user.bio! : 'Not set'),
                    const Divider(height: 1),
                    _profileTile(Icons.location_on, 'Address', user?.address ?? 'Not set'),
                    const Divider(height: 1),
                    _profileTile(Icons.star, 'Skills', user?.skills.isNotEmpty == true ? user!.skills.join(', ') : 'No skills listed'),
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

              // Edit Profile
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // About Us
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                    );
                  },
                  icon: const Icon(Icons.info_outline, color: AppColors.primary),
                  label: const Text('About NGO', style: TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Password and Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                  icon: const Icon(Icons.lock, color: AppColors.primary),
                  label: const Text('Change Password', style: TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
      title: Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
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

/// Search delegate for campaigns — wired to the search icon on campaigns tab.
class _CampaignSearchDelegate extends SearchDelegate<String> {
  final CampaignProvider _provider;

  _CampaignSearchDelegate(this._provider);

  @override
  String get searchFieldLabel => 'Search campaigns...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final q = query.toLowerCase();
    final results = _provider.allCampaigns.where((c) =>
        c.title.toLowerCase().contains(q) ||
        c.description.toLowerCase().contains(q) ||
        c.location.toLowerCase().contains(q)).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No campaigns found', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final campaign = results[index];
        return ListTile(
          leading: Icon(Icons.campaign, color: AppColors.primary),
          title: Text(campaign.title),
          subtitle: Text(campaign.location, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            close(context, '');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CampaignDetailScreen(campaign: campaign),
              ),
            );
          },
        );
      },
    );
  }
}

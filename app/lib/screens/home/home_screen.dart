import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
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
import '../../widgets/web/web_shell.dart';
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
    final isDesktopOrTablet = !Responsive.isMobile(context);

    // ─── DESKTOP / TABLET: Use WebShell sidebar ───
    if (isDesktopOrTablet) {
      // Build all possible tabs for desktop
      final desktopTabs = <Widget>[
        _buildDashboard(context),           // 0
        const CampaignListScreen(),         // 1
        if (isAdmin) const UserListScreen(),// 2 (admin only)
        _buildProfileTab(context),          // 3 (or 2 for non-admin)
        if (isAdmin) const AnalyticsScreen(), // 4 (admin only)
      ];

      return WebShell(
        currentIndex: _currentIndex,
        onIndexChanged: (i) => setState(() => _currentIndex = i),
        tabs: desktopTabs,
        isAdmin: isAdmin,
        userName: user?.name ?? 'User',
        userImageUrl: user?.profileImageUrl,
        onLogout: () => _showLogoutDialog(context),
      );
    }

    // ─── MOBILE: Original bottom nav layout ───
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
      body: _buildMobileBody(context),
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

  Widget _buildMobileBody(BuildContext context) {
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
        horizontal: Responsive.isMobile(context) ? AppSpacing.lg : AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card — Premium gradient
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: AppTokens.borderRadiusLg,
                  boxShadow: AppTokens.shadowGlow(AppColors.primary),
                ),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: Responsive.isMobile(context) ? 28 : 35,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: user?.profileImageUrl != null
                          ? CachedNetworkImageProvider(user!.profileImageUrl!)
                          : null,
                      child: user?.profileImageUrl == null
                          ? Text(
                              (user?.name ?? 'U')[0].toUpperCase(),
                              style: AppTextStyles.headlineMedium(color: Colors.white),
                            )
                          : null,
                    ),
                    AppSpacing.hGapLg,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: AppTextStyles.bodySmall(color: Colors.white.withValues(alpha: 0.8))),
                          AppSpacing.vGapXs,
                          Text(user?.name ?? 'User',
                            style: AppTextStyles.headlineMedium(color: Colors.white),
                            overflow: TextOverflow.ellipsis),
                          AppSpacing.vGapSm,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: AppTokens.borderRadiusPill,
                            ),
                            child: Text(
                              user?.isAdmin == true ? '👑 Admin' : '🤝 Volunteer',
                              style: AppTextStyles.labelSmall(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.vGapXl,

              // Stats Grid
              Text('Overview', style: AppTextStyles.titleLarge()),
              AppSpacing.vGapMd,

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
              AppSpacing.vGapXl,

              // ─── Latest Announcements ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Latest Updates', style: AppTextStyles.titleLarge()),
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
              AppSpacing.vGapSm,
              _buildLatestAnnouncements(),
              AppSpacing.vGapXl,

              // Quick Actions
              Text('Quick Actions', style: AppTextStyles.titleLarge()),
              AppSpacing.vGapMd,

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        boxShadow: AppTokens.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: AppTokens.borderRadiusSm,
            ),
            child: Icon(icon, color: color, size: AppTokens.iconMd),
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.statValue(color: color)),
          AppSpacing.vGapXs,
          Text(title, style: AppTextStyles.caption(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ), overflow: TextOverflow.ellipsis),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppTokens.borderRadiusSm,
          ),
          child: Icon(icon, color: color, size: AppTokens.iconMd),
        ),
        title: Text(title, style: AppTextStyles.titleSmall()),
        subtitle: Text(subtitle, style: AppTextStyles.caption(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        )),
        trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.neutral500 : AppColors.neutral400),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isMobile(context) ? AppSpacing.lg : AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              // ─── Premium Avatar Header ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl, horizontal: AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: AppTokens.borderRadiusLg,
                  boxShadow: AppTokens.shadowGlow(AppColors.primary),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: user?.profileImageUrl != null
                            ? CachedNetworkImageProvider(user!.profileImageUrl!)
                            : null,
                        child: user?.profileImageUrl == null
                            ? Text((user?.name ?? 'U')[0].toUpperCase(),
                                style: AppTextStyles.displayMedium(color: Colors.white))
                            : null,
                      ),
                    ),
                    AppSpacing.vGapLg,
                    Text(user?.name ?? 'User', style: AppTextStyles.headlineMedium(color: Colors.white)),
                    AppSpacing.vGapXs,
                    Text(user?.email ?? '', style: AppTextStyles.bodySmall(color: Colors.white.withValues(alpha: 0.7))),
                    AppSpacing.vGapSm,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: AppTokens.borderRadiusPill,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        user?.isAdmin == true ? '👑 Admin' : '🤝 Volunteer',
                        style: AppTextStyles.labelSmall(color: Colors.white),
                      ),
                    ),
                    if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                      AppSpacing.vGapMd,
                      Text(user.bio!, textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall(color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ],
                ),
              ),
              AppSpacing.vGapXl,

              // ─── Info Card ───
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBg : Colors.white,
                  borderRadius: AppTokens.borderRadiusMd,
                  border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  boxShadow: AppTokens.shadowSoft,
                ),
                child: Column(
                  children: [
                    _profileTile(Icons.email, 'Email', user?.email ?? 'N/A'),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(Icons.phone, 'Phone', _formatPhone(user?.phone)),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(Icons.location_on, 'Address', user?.address ?? 'Not set'),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(Icons.star, 'Skills', user?.skills.isNotEmpty == true ? user!.skills.join(', ') : 'No skills listed'),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(Icons.campaign, 'Campaigns Joined', '${user?.campaignsJoined ?? 0}'),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(Icons.calendar_today, 'Member Since',
                        user?.joinedAt != null
                            ? '${user!.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}'
                            : 'N/A'),
                  ],
                ),
              ),
              AppSpacing.vGapXl,

              // ─── Action Buttons ───
              _profileActionBtn(Icons.edit, 'Edit Profile', AppColors.primary, Colors.white,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              AppSpacing.vGapMd,
              _profileActionBtn(Icons.info_outline, 'About NGO', isDark ? AppColors.darkCardBg : Colors.white, AppColors.primary,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                outlined: true),
              AppSpacing.vGapMd,
              _profileActionBtn(Icons.lock, 'Change Password', isDark ? AppColors.darkCardBg : Colors.white, AppColors.primary,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                outlined: true),
              AppSpacing.vGapMd,
              _profileActionBtn(Icons.logout, 'Logout', isDark ? AppColors.darkCardBg : Colors.white, AppColors.error,
                () => _showLogoutDialog(context),
                outlined: true),
              AppSpacing.vGapXl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileActionBtn(IconData icon, String label, Color bg, Color fg, VoidCallback onTap, {bool outlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: AppTokens.buttonHeightLg,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: fg, size: AppTokens.iconSm),
              label: Text(label, style: AppTextStyles.button(color: fg)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: fg.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: fg, size: AppTokens.iconSm),
              label: Text(label, style: AppTextStyles.button(color: fg)),
              style: ElevatedButton.styleFrom(
                backgroundColor: bg, foregroundColor: fg,
                shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
              ),
            ),
    );
  }

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'N/A';
    if (phone.length == 11 && !phone.contains('-')) {
      return '${phone.substring(0, 4)}-${phone.substring(4)}';
    }
    return phone;
  }

  Widget _profileTile(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: AppTokens.borderRadiusSm,
        ),
        child: Icon(icon, color: AppColors.primary, size: AppTokens.iconSm),
      ),
      title: Text(label, style: AppTextStyles.caption(
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      subtitle: Text(value, style: AppTextStyles.bodyMedium()),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      await authProvider.logout();
      if (mounted) {
        navigator.pushAndRemoveUntil(
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

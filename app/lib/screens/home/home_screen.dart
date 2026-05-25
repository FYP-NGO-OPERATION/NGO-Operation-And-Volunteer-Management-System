import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as dart_convert;
import 'package:easy_localization/easy_localization.dart';
import '../../config/feature_flags.dart';
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
import '../profile/edit_profile_screen.dart';
import '../profile/about_us_screen.dart';
import '../profile/change_password_screen.dart';
import '../profile/user_list_screen.dart';
import '../profile/leaderboard_screen.dart';
import '../inventory/inventory_list_screen.dart';
import '../../services/certificate_service.dart';
import '../../widgets/profile_tab_widget.dart';
import '../ngos/ngo_selection_screen.dart';
import '../ngos/create_ngo_screen.dart';
import '../../providers/ngo_provider.dart';
import '../admin/analytics_screen.dart';
import '../admin/manage_ngos_screen.dart';
import '../admin/workspace_settings_screen.dart';
import '../announcements/create_announcement_screen.dart';
import '../announcements/announcement_list_screen.dart';
import '../sessions/engagement_tab_screen.dart';
import '../sessions/create_session_screen.dart';
import '../../services/pdf_report_service.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import '../../widgets/web/web_shell.dart';
import 'package:intl/intl.dart';
// FYP-02 screens
import '../campaigns/recommended_campaigns_screen.dart';
import '../campaigns/qr_scan_screen.dart';
import '../campaigns/campaign_map_screen.dart';
import '../../services/pdf_report_service.dart' as import_pdf_service;
import 'components/home_stats_grid.dart';
import 'components/home_quick_actions.dart';
import 'components/home_latest_announcements.dart';
import 'components/home_joined_campaigns.dart';

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
    final isSuperAdmin = isAdmin && (user?.currentNgoId == null || user?.currentNgoId == 'HRAS_DEFAULT_ID' || user?.currentNgoId == '');
    final isDesktopOrTablet = !Responsive.isMobile(context);
    final ngoProvider = Provider.of<NgoProvider>(context);
    final currentNgo = ngoProvider.currentNgo;

    // Campaigns are already filtered via CampaignProvider.init(ngoId)

    // Build dynamic tabs based on NGO features
    final List<Map<String, dynamic>> activeTabs = [
      {
        'label': 'home'.tr(),
        'icon': Icons.dashboard_outlined,
        'activeIcon': Icons.dashboard,
        'screen': _buildDashboard(context),
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
      'screen': ProfileTab(onLogout: () => _showLogoutDialog(context)),
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
      // Defer state update to avoid build phase conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = 0);
      });
    }
    
    int safeIndex = _currentIndex < activeTabs.length ? _currentIndex : 0;

    // ─── DESKTOP / TABLET: Use WebShell sidebar ───
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

    // ─── MOBILE: Original bottom nav layout ───
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
            icon: const Icon(Icons.map),
            tooltip: 'Explore Live Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CampaignMapScreen()),
              );
            },
          ),
          // Switch NGO / Exit workspace
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch NGO',
            onPressed: () => _switchNgo(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: activeTabs[safeIndex]['screen'] as Widget,
      // FAB Speed Dial (Admin on Dashboard & Campaigns tab)
      floatingActionButton: isAdmin
          ? CustomSpeedDial(
              actions: [
                if (currentNgo?.features.contains('campaigns') ?? true)
                  SpeedDialAction(
                    icon: Icons.campaign,
                    label: 'add_campaign'.tr(),
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
                  label: 'add_announcement'.tr(),
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()),
                    );
                  },
                ),
                if (currentNgo?.features.contains('virtual_sessions') ?? false)
                  SpeedDialAction(
                    icon: Icons.videocam,
                    label: 'schedule_session'.tr(),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
                      );
                    },
                  ),
                if (FeatureFlags.isAnalyticsEnabled)
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
                        MaterialPageRoute(builder: (_) => UserListScreen()),
                      );
                    },
                  ),
                  if (isAdmin && currentNgo != null && currentNgo.adminId == user?.uid)
                    SpeedDialAction(
                      icon: Icons.settings_applications,
                      label: 'Workspace Settings',
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WorkspaceSettingsScreen()),
                        );
                      },
                    ),
                  if (isSuperAdmin)
                    SpeedDialAction(
                      icon: Icons.admin_panel_settings,
                      label: 'Manage NGOs',
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManageNgosScreen()),
                        );
                      },
                    ),
                ],
              )
          // ─── Volunteer FAB (FYP-02 features) ───
          : (FeatureFlags.isSmartMatchingEnabled || FeatureFlags.isQrAttendanceEnabled)
              ? Builder(
                  builder: (context) {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    return CustomSpeedDial(
                      mainIcon: Icons.auto_awesome,
                      activeIcon: Icons.close,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      actions: [
                        if (FeatureFlags.isSmartMatchingEnabled)
                          SpeedDialAction(
                            icon: Icons.recommend,
                            label: 'recommended_campaigns'.tr(),
                            backgroundColor: AppColors.info,
                            foregroundColor: Colors.white,
                            onTap: () {
                              final user = auth.user;
                              if (user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RecommendedCampaignsScreen(user: user),
                                  ),
                                );
                              }
                            },
                          ),
                        if (FeatureFlags.isQrAttendanceEnabled)
                          SpeedDialAction(
                            icon: Icons.qr_code_scanner,
                            label: 'scan_qr_attendance'.tr(),
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            onTap: () {
                              final user = auth.user;
                              if (user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QrScanScreen(
                                      userId: user.uid,
                                      userName: user.name,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                      ],
                    );
                  },
                )
              : null,
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



  Widget _buildDashboard(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final ngoProvider = Provider.of<NgoProvider>(context);
    final currentNgo = ngoProvider.currentNgo;
    final columns = Responsive.gridColumns(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
              // Welcome Card — Premium gradient (uses NGO primary color)
              Builder(builder: (context) {
                final primaryColor = Theme.of(context).primaryColor;
                return Container(
                  decoration: BoxDecoration(
                    color: currentNgo?.bannerUrl == null ? null : Colors.black,
                    image: currentNgo?.bannerUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(currentNgo!.bannerUrl!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                          )
                        : null,
                    gradient: currentNgo?.bannerUrl == null
                        ? LinearGradient(
                            colors: [primaryColor, primaryColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: AppTokens.borderRadiusLg,
                    boxShadow: AppTokens.shadowGlow(primaryColor),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: Responsive.isMobile(context) ? 28 : 35,
                            backgroundColor: Colors.white.withOpacity(0.2),
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
                                Text(
                                  currentNgo?.welcomeText?.isNotEmpty == true
                                      ? currentNgo!.welcomeText!
                                      : 'welcome_back'.tr(),
                                  style: AppTextStyles.bodySmall(color: Colors.white.withOpacity(0.8)),
                                ),
                                AppSpacing.vGapXs,
                                Text(user?.name ?? 'User',
                                  style: AppTextStyles.headlineMedium(color: Colors.white),
                                  overflow: TextOverflow.ellipsis),
                                AppSpacing.vGapSm,
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: AppTokens.borderRadiusPill,
                                      ),
                                      child: Text(
                                        user?.isAdmin == true ? '👑 Admin' : '🤝 Volunteer',
                                        style: AppTextStyles.labelSmall(color: Colors.white),
                                      ),
                                    ),
                                    if (currentNgo != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius: AppTokens.borderRadiusPill,
                                        ),
                                        child: Text(
                                          '🏢 ${currentNgo.name}',
                                          style: AppTextStyles.labelSmall(color: Colors.white),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (currentNgo != null && (currentNgo.missionStatement?.isNotEmpty == true || currentNgo.description.isNotEmpty)) ...[
                        AppSpacing.vGapMd,
                        Text(
                          currentNgo.missionStatement?.isNotEmpty == true
                              ? currentNgo.missionStatement!
                              : currentNgo.description,
                          style: AppTextStyles.bodySmall(color: Colors.white.withOpacity(0.85)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                );
              }),
              AppSpacing.vGapXl,
              const HomeStatsGrid(),
              AppSpacing.vGapXl,
              const HomeLatestAnnouncements(),
              AppSpacing.vGapXl,
              HomeQuickActions(
                user: user,
                ngoProvider: ngoProvider,
                onTabChange: (index) => setState(() => _currentIndex = index),
              ),
              const SizedBox(height: 24),
              if (user != null && !user.isAdmin) ...[
                HomeJoinedCampaigns(
                  userId: user.uid,
                  onTabChange: (index) => setState(() => _currentIndex = index),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildProfileTab(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(user?.name ?? 'User', style: AppTextStyles.headlineMedium(color: Colors.white)),
                        if ((user?.campaignsJoined ?? 0) >= 3) ...[
                          AppSpacing.hGapSm,
                          const Tooltip(
                            message: 'Top Volunteer',
                            child: Icon(Icons.stars, color: Colors.amber, size: 28),
                          ),
                        ],
                      ],
                    ),
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
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen()))),
              AppSpacing.vGapMd,
              _profileActionBtn(Icons.swap_horiz, 'Switch Workspace', isDark ? AppColors.darkCardBg : Colors.white, AppColors.info,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NgoSelectionScreen())),
                outlined: true),
              AppSpacing.vGapMd,
              _profileActionBtn(Icons.business_center, 'Partner your NGO', isDark ? AppColors.darkCardBg : Colors.white, AppColors.success,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateNgoScreen())),
                outlined: true),
              AppSpacing.vGapMd,
              _profileActionBtn(Icons.info_outline, 'About NGO', isDark ? AppColors.darkCardBg : Colors.white, AppColors.primary,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                outlined: true),
              AppSpacing.vGapMd,
              _profileActionBtn(Icons.lock, 'Change Password', isDark ? AppColors.darkCardBg : Colors.white, AppColors.primary,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChangePasswordScreen())),
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
      // Clear NGO state so login screen shows default green
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

  /// Switch to another NGO workspace
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

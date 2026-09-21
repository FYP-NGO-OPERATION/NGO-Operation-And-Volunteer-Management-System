import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../providers/auth_provider.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/profile/change_password_screen.dart';
import '../../screens/profile/about_us_screen.dart';
import '../../screens/ngos/ngo_selection_screen.dart';
import '../../screens/ngos/create_ngo_screen.dart';
import '../../services/certificate_service.dart';
import '../../providers/ngo_provider.dart';
import '../../screens/volunteer/carbon_tracker_screen.dart';

class ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileTab({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppTokens.borderRadiusLg,
              boxShadow: AppTokens.shadowSoft,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage: user?.profileImageUrl != null
                      ? CachedNetworkImageProvider(user!.profileImageUrl!)
                      : null,
                  child: user?.profileImageUrl == null
                      ? Text(
                          (user?.name ?? 'U')[0].toUpperCase(),
                          style: AppTextStyles.headlineMedium(
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                AppSpacing.hGapLg,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: AppTextStyles.titleLarge(),
                      ),
                      AppSpacing.vGapXs,
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.bodyMedium(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      AppSpacing.vGapSm,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user?.isAdmin == true
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.info.withValues(alpha: 0.1),
                          borderRadius: AppTokens.borderRadiusPill,
                        ),
                        child: Text(
                          user?.isAdmin == true ? '👑 Admin' : '🤝 Volunteer',
                          style: AppTextStyles.labelSmall(
                            color: user?.isAdmin == true
                                ? AppColors.primary
                                : AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vGapXl,

          // Achievements Section
          if (user != null && user.isAdmin != true)
            _buildAchievementsSection(context, user),
          if (user != null && user.isAdmin != true) AppSpacing.vGapXl,

          // Settings Section
          _buildSettingsTile(
            context,
            title: 'edit_profile'.tr(),
            subtitle: 'update_name_photo'.tr(),
            icon: Icons.person_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            title: 'change_password'.tr(),
            subtitle: 'update_login_password'.tr(),
            icon: Icons.lock_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          const Divider(height: 32),
          _buildSettingsTile(
            context,
            title: 'switch_workspace'.tr(),
            subtitle: 'access_another_ngo'.tr(),
            icon: Icons.swap_horiz,
            color: AppColors.info,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NgoSelectionScreen()),
            ),
          ),
          _buildSettingsTile(
            context,
            title: 'partner_ngo'.tr(),
            subtitle: 'partner_ngo_desc'.tr(),
            icon: Icons.business_center,
            color: AppColors.success,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateNgoScreen()),
            ),
          ),
          const Divider(height: 32),
          _buildSettingsTile(
            context,
            title: '${'language'.tr()} / زبان',
            subtitle: context.locale.languageCode == 'en'
                ? 'switch_to_urdu'.tr()
                : 'switch_to_english'.tr(),
            icon: Icons.language,
            onTap: () {
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('ur'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
          ),
          const Divider(height: 32),
          _buildSettingsTile(
            context,
            title: 'about_hras'.tr(),
            subtitle: 'about_hras_desc'.tr(),
            icon: Icons.info_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
            ),
          ),
          const Divider(height: 32),
          _buildSettingsTile(
            context,
            title: 'Carbon Footprint Tracker',
            subtitle: 'Track your eco-friendly impact',
            icon: Icons.eco,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CarbonTrackerScreen()),
            ),
          ),
          const Divider(height: 32),
          _buildSettingsTile(
            context,
            title: 'logout'.tr(),
            subtitle: 'Sign out of your account',
            icon: Icons.logout,
            color: AppColors.error,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final iconColor = color ?? AppColors.primary;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: AppTokens.borderRadiusMd,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: AppTextStyles.titleSmall(color: color)),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.caption(color: theme.hintColor),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildAchievementsSection(BuildContext context, user) {
    int attended = user.campaignsJoined ?? 0;
    String badgeText = "no_badges".tr();
    Color badgeColor = Colors.grey;

    if (attended >= 20) {
      badgeText = "gold_badge".tr();
      badgeColor = Colors.amber;
    } else if (attended >= 10) {
      badgeText = "silver_badge".tr();
      badgeColor = Colors.blueGrey;
    } else if (attended >= 5) {
      badgeText = "bronze_badge".tr();
      badgeColor = Colors.brown[400]!;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: AppTokens.borderRadiusLg,
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: badgeColor, size: 32),
              AppSpacing.hGapSm,
              Text(
                'achievements'.tr(),
                style: AppTextStyles.titleLarge(color: badgeColor),
              ),
            ],
          ),
          AppSpacing.vGapMd,
          Text(
            '${'campaigns_completed'.tr()}: $attended',
            style: AppTextStyles.bodyLarge(),
          ),
          AppSpacing.vGapSm,
          Row(
            children: [
              Text(
                '${'current_badge'.tr()}: ',
                style: AppTextStyles.bodyMedium(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (attended >= 5) ...[
            AppSpacing.vGapLg,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final ngoProvider = Provider.of<NgoProvider>(
                    context,
                    listen: false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating PDF...')),
                  );
                  await CertificateService.generateAndDownloadCertificate(
                    volunteerName: user.name,
                    campaignsAttended: attended,
                    ngoName: ngoProvider.currentNgo?.name ?? 'HRAS Platform',
                  );
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: Text(
                  'download_certificate'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: badgeColor),
              ),
            ),
          ] else ...[
            AppSpacing.vGapLg,
            Text(
              'no_campaigns_joined'.tr(),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

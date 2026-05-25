import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_tokens.dart';
import '../../../../config/app_colors.dart';
import '../../../../utils/responsive.dart';
import '../../../../providers/auth_provider.dart';
import '../../profile/edit_profile_screen.dart';
import '../../profile/about_us_screen.dart';
import '../../profile/change_password_screen.dart';
import '../../ngos/ngo_selection_screen.dart';
import '../../ngos/create_ngo_screen.dart';

class HomeProfileTab extends StatelessWidget {
  final VoidCallback onLogout;

  const HomeProfileTab({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.only(
        left: Responsive.isMobile(context) ? AppSpacing.lg : AppSpacing.xl,
        right: Responsive.isMobile(context) ? AppSpacing.lg : AppSpacing.xl,
        top: AppSpacing.lg,
        bottom: 100, // Extra padding so FAB doesn't overlap Logout
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
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withOpacity(0.2),
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
                    Text(user?.email ?? '', style: AppTextStyles.bodySmall(color: Colors.white.withOpacity(0.7))),
                    AppSpacing.vGapSm,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: AppTokens.borderRadiusPill,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        user?.isAdmin == true ? '👑 Admin' : '🤝 Volunteer',
                        style: AppTextStyles.labelSmall(color: Colors.white),
                      ),
                    ),
                    if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                      AppSpacing.vGapMd,
                      Text(user.bio!, textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall(color: Colors.white.withOpacity(0.8))),
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
                    _profileTile(context, Icons.email, 'Email', user?.email ?? 'N/A', isDark),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(context, Icons.phone, 'Phone', _formatPhone(user?.phone), isDark),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(context, Icons.location_on, 'Address', user?.address ?? 'Not set', isDark),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(context, Icons.star, 'Skills', user?.skills.isNotEmpty == true ? user!.skills.join(', ') : 'No skills listed', isDark),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(context, Icons.campaign, 'Campaigns Joined', '${user?.campaignsJoined ?? 0}', isDark),
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _profileTile(context, Icons.calendar_today, 'Member Since',
                        user?.joinedAt != null
                            ? '${user!.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}'
                            : 'N/A', isDark),
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
                onLogout,
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
                side: BorderSide(color: fg.withOpacity(0.4)),
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

  Widget _profileTile(BuildContext context, IconData icon, String label, String value, bool isDark) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
          borderRadius: AppTokens.borderRadiusSm,
        ),
        child: Icon(icon, color: AppColors.primary, size: AppTokens.iconSm),
      ),
      title: Text(label, style: AppTextStyles.caption(
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      subtitle: Text(value, style: AppTextStyles.bodyMedium()),
    );
  }
}

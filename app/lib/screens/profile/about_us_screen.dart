import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../config/feature_flags.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us', style: AppTextStyles.titleLarge()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    boxShadow: AppTokens.shadowGlow(AppColors.primary),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppConstants.logoPath,
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                AppSpacing.vGapXl,
                Text(
                  'HRAS',
                  style: AppTextStyles.displayMedium(color: AppColors.primary),
                ),
                AppSpacing.vGapSm,
                Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.bodyLarge(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                AppSpacing.vGapXxl,

                // Mission Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardBg : Colors.white,
                    borderRadius: AppTokens.borderRadiusMd,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                    boxShadow: AppTokens.shadowSoft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: AppTokens.borderRadiusSm,
                            ),
                            child: Icon(
                              Icons.flag_rounded,
                              color: AppColors.primary,
                              size: AppTokens.iconMd,
                            ),
                          ),
                          AppSpacing.hGapMd,
                          Text(
                            'Our Mission',
                            style: AppTextStyles.titleMedium(),
                          ),
                        ],
                      ),
                      AppSpacing.vGapMd,
                      Text(
                        'To bring hope, aid, and sustainable change to communities in need. '
                        'We believe in the power of collective volunteerism to transform lives '
                        'and build a better future for everyone.',
                        style: AppTextStyles.bodyMedium(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGapXxl,

                // Official Bank Details
                Text(
                  'Official Donation Accounts',
                  style: AppTextStyles.titleLarge(),
                ),
                AppSpacing.vGapLg,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusMd,
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance,
                            color: AppColors.success,
                          ),
                          AppSpacing.hGapMd,
                          Text(
                            'JazzCash / Easypaisa',
                            style: AppTextStyles.titleMedium(),
                          ),
                        ],
                      ),
                      AppSpacing.vGapMd,
                      Text(
                        'Account Title: HRAS Foundation',
                        style: AppTextStyles.bodyMedium().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vGapXs,
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Account No: 0300-1234567',
                              style: AppTextStyles.bodyLarge(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy,
                              color: AppColors.success,
                              size: 20,
                            ),
                            tooltip: 'Copy Account Number',
                            onPressed: () {
                              Clipboard.setData(
                                const ClipboardData(text: '03001234567'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Account number copied!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGapXxl,

                // Social Links
                Text('Connect With Us', style: AppTextStyles.titleLarge()),
                AppSpacing.vGapLg,
                _SocialButton(
                  iconWidget: FaIcon(
                    FontAwesomeIcons.instagram,
                    color: const Color(0xFFE1306C),
                    size: 28,
                  ),
                  label: 'Instagram',
                  color: const Color(0xFFE1306C),
                  onTap: () => _launchUrl(
                    'https://www.instagram.com/hras_hamesharaheinapkesaath',
                  ),
                ),
                AppSpacing.vGapMd,
                _SocialButton(
                  iconWidget: Icon(
                    Icons.facebook,
                    color: const Color(0xFF1877F2),
                    size: 28,
                  ),
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                  onTap: () =>
                      _launchUrl('https://www.facebook.com/share/18JqaHAKdM/'),
                ),
                AppSpacing.vGapMd,
                _SocialButton(
                  iconWidget: FaIcon(
                    FontAwesomeIcons.tiktok,
                    color: isDark ? Colors.white : Colors.black,
                    size: 28,
                  ),
                  label: 'TikTok',
                  color: isDark ? Colors.white : Colors.black,
                  onTap: () =>
                      _launchUrl('https://www.tiktok.com/@hras_official'),
                ),

                AppSpacing.vGapXxl,

                // ─── Feature Status Roadmap ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardBg : Colors.white,
                    borderRadius: AppTokens.borderRadiusMd,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                    boxShadow: AppTokens.shadowSoft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: AppTokens.borderRadiusSm,
                            ),
                            child: Icon(
                              Icons.rocket_launch_rounded,
                              color: AppColors.info,
                              size: AppTokens.iconMd,
                            ),
                          ),
                          AppSpacing.hGapMd,
                          Text(
                            'App Features',
                            style: AppTextStyles.titleMedium(),
                          ),
                        ],
                      ),
                      AppSpacing.vGapMd,
                      _featureItem('Campaign Management', true, isDark),
                      AppSpacing.vGapSm,
                      _featureItem('Volunteer Registration', true, isDark),
                      AppSpacing.vGapSm,
                      _featureItem('Donation Tracking', true, isDark),
                      AppSpacing.vGapSm,
                      _featureItem(
                        'Smart Volunteer-Campaign Matching',
                        FeatureFlags.isSmartMatchingEnabled,
                        isDark,
                      ),
                      AppSpacing.vGapSm,
                      _featureItem(
                        'Push Notifications (FCM)',
                        FeatureFlags.isPushNotificationsEnabled,
                        isDark,
                      ),
                      AppSpacing.vGapSm,
                      _featureItem(
                        'QR Attendance System',
                        FeatureFlags.isQrAttendanceEnabled,
                        isDark,
                      ),
                      AppSpacing.vGapSm,
                      _featureItem(
                        'Analytics Dashboard',
                        FeatureFlags.isAnalyticsEnabled,
                        isDark,
                      ),
                      AppSpacing.vGapSm,
                      _featureItem('Google Sign-In', true, isDark),
                      AppSpacing.vGapSm,
                      _featureItem('CSV/Excel Export', false, isDark),
                      AppSpacing.vGapSm,
                      _featureItem('Urdu Language Support', false, isDark),
                    ],
                  ),
                ),

                AppSpacing.vGapMd,

                // Phase Badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: AppTokens.borderRadiusMd,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified, color: AppColors.primary, size: 18),
                      AppSpacing.hGapSm,
                      Text(
                        'Running: ${FeatureFlags.phaseLabel}',
                        style: AppTextStyles.labelMedium(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.vGapXxl,
                AppSpacing.vGapLg,
                Text(
                  'Version ${AppConstants.appVersion}\n${AppConstants.appName}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(
                    color: isDark
                        ? AppColors.darkTextHint
                        : AppColors.lightTextHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureItem(String title, bool isActive, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.success : AppColors.neutral400,
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyMedium(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: (isActive ? AppColors.success : AppColors.neutral400)
                .withValues(alpha: 0.1),
            borderRadius: AppTokens.borderRadiusPill,
          ),
          child: Text(
            isActive ? '● LIVE' : '○ PLANNED',
            style: AppTextStyles.labelSmall(
              color: isActive ? AppColors.success : AppColors.neutral400,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.iconWidget,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          borderRadius: AppTokens.borderRadiusMd,
        ),
        child: Row(
          children: [
            iconWidget,
            AppSpacing.hGapLg,
            Text(label, style: AppTextStyles.titleMedium()),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: AppTokens.iconXs,
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
            ),
          ],
        ),
      ),
    );
  }
}

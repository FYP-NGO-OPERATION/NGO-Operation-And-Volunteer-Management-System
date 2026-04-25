import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
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
      appBar: AppBar(title: Text('About Us', style: AppTextStyles.titleLarge())),
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
                    child: Image.asset(AppConstants.logoPath, width: 72, height: 72, fit: BoxFit.contain),
                  ),
                ),
                AppSpacing.vGapXl,
                Text('HRAS', style: AppTextStyles.displayMedium(color: AppColors.primary)),
                AppSpacing.vGapSm,
                Text(AppConstants.appTagline,
                  style: AppTextStyles.bodyLarge(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                AppSpacing.vGapXxl,

                // Mission Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardBg : Colors.white,
                    borderRadius: AppTokens.borderRadiusMd,
                    border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
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
                            child: Icon(Icons.flag_rounded, color: AppColors.primary, size: AppTokens.iconMd),
                          ),
                          AppSpacing.hGapMd,
                          Text('Our Mission', style: AppTextStyles.titleMedium()),
                        ],
                      ),
                      AppSpacing.vGapMd,
                      Text(
                        'To bring hope, aid, and sustainable change to communities in need. '
                        'We believe in the power of collective volunteerism to transform lives '
                        'and build a better future for everyone.',
                        style: AppTextStyles.bodyMedium(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
                AppSpacing.vGapXxl,

                // Social Links
                Text('Connect With Us', style: AppTextStyles.titleLarge()),
                AppSpacing.vGapLg,
                _SocialButton(
                  icon: Icons.camera_alt,
                  label: 'Instagram',
                  color: const Color(0xFFE1306C),
                  onTap: () => _launchUrl('https://www.instagram.com/hras_hamesharaheinapkesaath'),
                ),
                AppSpacing.vGapMd,
                _SocialButton(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                  onTap: () => _launchUrl('https://www.facebook.com/share/18JqaHAKdM/'),
                ),
                AppSpacing.vGapMd,
                _SocialButton(
                  icon: Icons.music_note,
                  label: 'TikTok',
                  color: isDark ? Colors.white : Colors.black,
                  onTap: () => _launchUrl('https://www.tiktok.com/@hras_official'),
                ),

                AppSpacing.vGapXxl,
                AppSpacing.vGapLg,
                Text(
                  'Version ${AppConstants.appVersion}\n${AppConstants.appName}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          borderRadius: AppTokens.borderRadiusMd,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: AppTokens.iconLg),
            AppSpacing.hGapLg,
            Text(label, style: AppTextStyles.titleMedium()),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: AppTokens.iconXs,
              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
          ],
        ),
      ),
    );
  }
}

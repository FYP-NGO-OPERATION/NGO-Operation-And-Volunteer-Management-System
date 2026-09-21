import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_constants.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_tokens.dart';
import '../../../../utils/responsive.dart';

class LandingFooterSection extends StatelessWidget {
  const LandingFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return Container(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.section : AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.neutral900, Color(0xFF0D0D0D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // ─── Desktop: 4-column layout | Mobile: stacked ───
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Column 1 — Brand
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HRAS',
                                style: AppTextStyles.headlineMedium(
                                  color: Colors.white,
                                ),
                              ),
                              AppSpacing.vGapSm,
                              Text(
                                AppConstants.appTagline,
                                style: AppTextStyles.bodySmall(
                                  color: AppColors.neutral400,
                                ),
                              ),
                              AppSpacing.vGapLg,
                              Row(
                                children: [
                                  _SocialBtn(
                                    const FaIcon(
                                      FontAwesomeIcons.instagram,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    'https://www.instagram.com/hras_hamesharaheinapkesaath',
                                  ),
                                  AppSpacing.hGapMd,
                                  _SocialBtn(
                                    const Icon(
                                      Icons.facebook,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    'https://www.facebook.com/share/18JqaHAKdM/',
                                  ),
                                  AppSpacing.hGapMd,
                                  _SocialBtn(
                                    const FaIcon(
                                      FontAwesomeIcons.tiktok,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    'https://www.tiktok.com/@hras_official',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Column 2 — Quick Links
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Links',
                                style: AppTextStyles.labelLarge(
                                  color: Colors.white,
                                ),
                              ),
                              AppSpacing.vGapMd,
                              _footerLink('About Us'),
                              _footerLink('Our Campaigns'),
                              _footerLink('Become a Volunteer'),
                              _footerLink('Donate Now'),
                            ],
                          ),
                        ),
                        // Column 3 — Resources
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resources',
                                style: AppTextStyles.labelLarge(
                                  color: Colors.white,
                                ),
                              ),
                              AppSpacing.vGapMd,
                              _footerLink('Privacy Policy'),
                              _footerLink('Terms of Service'),
                              _footerLink('Annual Reports'),
                              _footerLink('Media Kit'),
                            ],
                          ),
                        ),
                        // Column 4 — Contact
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact',
                                style: AppTextStyles.labelLarge(
                                  color: Colors.white,
                                ),
                              ),
                              AppSpacing.vGapMd,
                              _footerContactRow(
                                Icons.email_outlined,
                                'hras.ngo@gmail.com',
                              ),
                              _footerContactRow(
                                Icons.phone_outlined,
                                '+92 300 1234567',
                              ),
                              _footerContactRow(
                                Icons.location_on_outlined,
                                'Karachi, Pakistan',
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                          'HRAS',
                          style: AppTextStyles.headlineMedium(
                            color: Colors.white,
                          ),
                        ),
                        AppSpacing.vGapSm,
                        Text(
                          AppConstants.appTagline,
                          style: AppTextStyles.caption(
                            color: AppColors.neutral400,
                          ),
                        ),
                        AppSpacing.vGapXl,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialBtn(
                              const FaIcon(
                                FontAwesomeIcons.instagram,
                                color: Colors.white,
                                size: 20,
                              ),
                              'https://www.instagram.com/hras_hamesharaheinapkesaath',
                            ),
                            AppSpacing.hGapLg,
                            _SocialBtn(
                              const Icon(
                                Icons.facebook,
                                color: Colors.white,
                                size: 20,
                              ),
                              'https://www.facebook.com/share/18JqaHAKdM/',
                            ),
                            AppSpacing.hGapLg,
                            _SocialBtn(
                              const FaIcon(
                                FontAwesomeIcons.tiktok,
                                color: Colors.white,
                                size: 20,
                              ),
                              'https://www.tiktok.com/@hras_official',
                            ),
                          ],
                        ),
                      ],
                    ),
              const SizedBox(height: AppSpacing.xxl),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              AppSpacing.vGapMd,
              Text(
                '© 2026 HRAS NGO. All rights reserved.',
                style: AppTextStyles.labelSmall(color: AppColors.neutral600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _footerLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTextStyles.bodySmall(color: AppColors.neutral400),
      ),
    );
  }

  static Widget _footerContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.neutral500),
          AppSpacing.hGapSm,
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall(color: AppColors.neutral400),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final Widget iconWidget;
  final String url;
  const _SocialBtn(this.iconWidget, this.url);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri)) {
          debugPrint('Could not launch $url');
        }
      },
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: iconWidget,
      ),
    );
  }
}

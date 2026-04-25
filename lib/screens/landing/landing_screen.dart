import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_animations.dart';
import '../../providers/campaign_provider.dart';
import '../../models/campaign_model.dart';
import '../../utils/responsive.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Premium landing page — first impression for unauthenticated users
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Sticky Navbar ───
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: isDark ? AppColors.darkAppBarBg : Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                ClipOval(child: Image.asset(AppConstants.logoPath, width: 32, height: 32, fit: BoxFit.contain)),
                AppSpacing.hGapSm,
                Text('HRAS', style: AppTextStyles.titleLarge(color: AppColors.primary)),
              ],
            ),
            actions: [
              // Desktop nav links
              if (!Responsive.isMobile(context)) ...[
                TextButton(
                  onPressed: () {},
                  child: Text('About', style: AppTextStyles.labelLarge(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Campaigns', style: AppTextStyles.labelLarge(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Contact', style: AppTextStyles.labelLarge(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                ),
                AppSpacing.hGapSm,
              ],
              TextButton(
                onPressed: () => Navigator.push(context, AppAnimations.fadeRoute(const LoginScreen())),
                child: Text('Sign In', style: AppTextStyles.labelLarge(color: AppColors.primary)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, AppAnimations.slideUpRoute(const RegisterScreen())),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  ),
                  child: Text('Join Us', style: AppTextStyles.button(color: Colors.white)),
                ),
              ),
            ],
          ),

          // ─── Content ───
          SliverToBoxAdapter(
            child: Column(
              children: [
                _HeroSection(),
                _ImpactStats(),
                _MissionSection(isDark: isDark),
                _RecentCampaigns(isDark: isDark),
                _NewsletterSection(isDark: isDark),
                _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? AppSpacing.hero : 120,
        horizontal: AppSpacing.xl,
      ),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        children: [
          Icon(Icons.volunteer_activism, size: isMobile ? 56 : 72, color: Colors.white.withValues(alpha: 0.9)),
          AppSpacing.vGapXl,
          Text(
            'Hamesha Rahein\nApke Saath',
            textAlign: TextAlign.center,
            style: isMobile
                ? AppTextStyles.displayMedium(color: Colors.white)
                : AppTextStyles.displayLarge(color: Colors.white),
          ),
          AppSpacing.vGapLg,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              'Join our community of volunteers and donors to deliver real, transparent impact where it matters most.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge(color: Colors.white.withValues(alpha: 0.85)),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl + AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, AppAnimations.slideUpRoute(const RegisterScreen())),
                icon: const Icon(Icons.favorite, size: 20),
                label: Text('Become a Volunteer', style: AppTextStyles.button()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(context, AppAnimations.fadeRoute(const LoginScreen())),
                icon: const Icon(Icons.login, size: 20),
                label: Text('Sign In', style: AppTextStyles.button()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Consumer<CampaignProvider>(
      builder: (context, provider, child) {
        final stats = [
          _StatItem('${provider.totalCampaigns}', 'Total Campaigns', Icons.campaign),
          _StatItem('${provider.totalBeneficiariesOverall}+', 'Families Helped', Icons.family_restroom),
          _StatItem('${provider.totalItemsDistributedOverall}+', 'Items Donated', Icons.inventory_2),
        ];

        return Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.section, horizontal: AppSpacing.xl),
          color: AppColors.primarySurface.withValues(alpha: 0.4),
          child: isMobile
              ? Column(children: stats.map((s) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.xl), child: s)).toList())
              : Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: stats),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  const _StatItem(this.number, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: AppTokens.iconLg),
        AppSpacing.vGapSm,
        Text(number, style: AppTextStyles.statValue(color: AppColors.primary)),
        AppSpacing.vGapXs,
        Text(label, style: AppTextStyles.labelMedium(color: AppColors.lightTextSecondary)),
      ],
    );
  }
}

class _MissionSection extends StatelessWidget {
  final bool isDark;
  const _MissionSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.page, horizontal: AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppTokens.borderRadiusPill,
                ),
                child: Text('OUR MISSION', style: AppTextStyles.overline(color: AppColors.primary)),
              ),
              AppSpacing.vGapLg,
              Text('Empowering Communities Through Action',
                style: AppTextStyles.headlineLarge(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapLg,
              Text(
                'HRAS (Hamesha Rahein Apke Saath) is dedicated to bringing hope, aid, and sustainable change. '
                'We believe in the power of collective volunteerism to transform lives and build a better future for everyone.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentCampaigns extends StatelessWidget {
  final bool isDark;
  const _RecentCampaigns({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<CampaignProvider>(
      builder: (context, provider, child) {
        final campaigns = provider.allCampaigns.take(3).toList();
        if (campaigns.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.section, horizontal: AppSpacing.xl),
          child: Column(
            children: [
              Text('Recent Campaigns', style: AppTextStyles.headlineMedium(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              )),
              AppSpacing.vGapXxl,
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                alignment: WrapAlignment.center,
                children: campaigns.map((c) => _CampaignCard(campaign: c, isDark: isDark)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final bool isDark;
  const _CampaignCard({required this.campaign, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        boxShadow: AppTokens.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radiusMd)),
            child: campaign.coverImageUrl != null && campaign.coverImageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: campaign.coverImageUrl!,
                    height: 180, width: double.infinity, fit: BoxFit.cover,
                    errorWidget: (context, url, error) => _placeholder(),
                  )
                : _placeholder(),
          ),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(campaign.title, style: AppTextStyles.titleMedium(), maxLines: 2, overflow: TextOverflow.ellipsis),
                AppSpacing.vGapSm,
                Text(campaign.description, style: AppTextStyles.bodySmall(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ), maxLines: 2, overflow: TextOverflow.ellipsis),
                AppSpacing.vGapMd,
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: AppTokens.iconXs, color: AppColors.primary),
                    AppSpacing.hGapXs,
                    Expanded(child: Text(campaign.location,
                      style: AppTextStyles.caption(color: AppColors.primary),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180, width: double.infinity,
      color: AppColors.primarySurface,
      child: const Center(child: Icon(Icons.campaign, size: 48, color: AppColors.primary)),
    );
  }
}

class _NewsletterSection extends StatelessWidget {
  final bool isDark;
  const _NewsletterSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.section, horizontal: AppSpacing.xl),
      color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Icon(Icons.mail_outline_rounded, size: 48, color: AppColors.primary.withValues(alpha: 0.6)),
              AppSpacing.vGapLg,
              Text('Stay Connected', style: AppTextStyles.headlineMedium(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
              AppSpacing.vGapSm,
              Text('Get updates on our campaigns and community impact.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              AppSpacing.vGapXl,
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardBg : Colors.white,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppTokens.radiusMd)),
                        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                      ),
                      child: Center(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: AppTextStyles.bodySmall(
                              color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(AppTokens.radiusMd)),
                        ),
                      ),
                      child: Text('Subscribe', style: AppTextStyles.button(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return Container(
      padding: EdgeInsets.all(isDesktop ? AppSpacing.section : AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.neutral900, Color(0xFF0D0D0D)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                              Text('HRAS', style: AppTextStyles.headlineMedium(color: Colors.white)),
                              AppSpacing.vGapSm,
                              Text(AppConstants.appTagline, style: AppTextStyles.bodySmall(color: AppColors.neutral400)),
                              AppSpacing.vGapLg,
                              Row(
                                children: [
                                  _SocialBtn(Icons.camera_alt, 'https://www.instagram.com/hras_hamesharaheinapkesaath'),
                                  AppSpacing.hGapMd,
                                  _SocialBtn(Icons.facebook, 'https://www.facebook.com/share/18JqaHAKdM/'),
                                  AppSpacing.hGapMd,
                                  _SocialBtn(Icons.music_note, 'https://www.tiktok.com/@hras_official'),
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
                              Text('Quick Links', style: AppTextStyles.labelLarge(color: Colors.white)),
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
                              Text('Resources', style: AppTextStyles.labelLarge(color: Colors.white)),
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
                              Text('Contact', style: AppTextStyles.labelLarge(color: Colors.white)),
                              AppSpacing.vGapMd,
                              _footerContactRow(Icons.email_outlined, 'hras.ngo@gmail.com'),
                              _footerContactRow(Icons.phone_outlined, '+92 300 1234567'),
                              _footerContactRow(Icons.location_on_outlined, 'Karachi, Pakistan'),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text('HRAS', style: AppTextStyles.headlineMedium(color: Colors.white)),
                        AppSpacing.vGapSm,
                        Text(AppConstants.appTagline, style: AppTextStyles.caption(color: AppColors.neutral400)),
                        AppSpacing.vGapXl,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialBtn(Icons.camera_alt, 'https://www.instagram.com/hras_hamesharaheinapkesaath'),
                            AppSpacing.hGapLg,
                            _SocialBtn(Icons.facebook, 'https://www.facebook.com/share/18JqaHAKdM/'),
                            AppSpacing.hGapLg,
                            _SocialBtn(Icons.music_note, 'https://www.tiktok.com/@hras_official'),
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
      child: Text(text, style: AppTextStyles.bodySmall(color: AppColors.neutral400)),
    );
  }

  static Widget _footerContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.neutral500),
          AppSpacing.hGapSm,
          Expanded(child: Text(text, style: AppTextStyles.bodySmall(color: AppColors.neutral400))),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String url;
  const _SocialBtn(this.icon, this.url);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri)) { debugPrint('Could not launch $url'); }
      },
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: AppTokens.iconMd),
      ),
    );
  }
}


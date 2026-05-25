import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_animations.dart';
import '../../utils/responsive.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'components/landing_hero_section.dart';
import 'components/landing_features_section.dart';
import 'components/landing_footer_section.dart';

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
                const LandingHeroSection(),
                LandingFeaturesSection(isDark: isDark),
                const LandingFooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_tokens.dart';
import '../../../../theme/app_animations.dart';
import '../../../../utils/responsive.dart';
import '../../auth/login_screen.dart';
import '../../auth/register_screen.dart';

class LandingHeroSection extends StatelessWidget {
  const LandingHeroSection({Key? key}) : super(key: key);

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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_animations.dart';
import '../auth/login_screen.dart';

/// Premium onboarding — 3 pages with smooth transitions
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.volunteer_activism,
      color: AppColors.primary,
      title: 'Donate with Purpose',
      subtitle: 'Every contribution reaches families in need — tracked transparently from your wallet to their hands.',
    ),
    _OnboardingPage(
      icon: Icons.groups_3,
      color: AppColors.secondary,
      title: 'Volunteer Your Time',
      subtitle: 'Join campaigns, attend events, and earn recognition for making a real impact in your community.',
    ),
    _OnboardingPage(
      icon: Icons.insights,
      color: AppColors.accent,
      title: 'Track Real Impact',
      subtitle: 'See exactly how many families helped, items distributed, and lives changed — all in real-time.',
    ),
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      Navigator.pushReplacement(context, AppAnimations.fadeRoute(const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text('Skip', style: AppTextStyles.labelLarge(color: AppColors.neutral400)),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: AppSpacing.pagePaddingWide,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: AppAnimations.medium,
                          curve: AppAnimations.easeOut,
                          builder: (context, val, child) => Transform.scale(scale: val, child: child),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: page.color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: page.color.withValues(alpha: 0.15), width: 2),
                            ),
                            child: Icon(page.icon, size: 64, color: page.color),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sectionLg),

                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineLarge(color: Theme.of(context).colorScheme.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Subtitle
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot indicators
                  Row(
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: AppAnimations.normal,
                        curve: AppAnimations.easeOut,
                        width: isActive ? 28 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: AppSpacing.xs),
                        decoration: BoxDecoration(
                          borderRadius: AppTokens.borderRadiusPill,
                          color: isActive ? _pages[_currentPage].color : AppColors.neutral300,
                        ),
                      );
                    }),
                  ),

                  // CTA button
                  SizedBox(
                    height: AppTokens.buttonHeightMd,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLast) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: AppAnimations.normal,
                            curve: AppAnimations.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: isLast && _pages[_currentPage].color == AppColors.accent
                            ? AppColors.neutral900
                            : Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: isLast ? AppSpacing.xxl : AppSpacing.xl),
                        shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isLast ? 'Get Started' : 'Next', style: AppTextStyles.button()),
                          if (!isLast) ...[
                            const SizedBox(width: AppSpacing.xs),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

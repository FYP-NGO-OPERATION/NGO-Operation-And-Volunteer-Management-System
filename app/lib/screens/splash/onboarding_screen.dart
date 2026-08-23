import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_animations.dart';
import '../auth/login_screen.dart';
import 'dart:ui' as ui;

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
      image: 'assets/images/onboarding1.png', // Fallback if no image
      icon: Icons.volunteer_activism,
      color: AppColors.primary,
      title: 'Donate with Purpose',
      subtitle: 'Every contribution reaches families in need.\nTracked transparently from your wallet to their hands.',
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding2.png',
      icon: Icons.groups_3,
      color: AppColors.secondary,
      title: 'Volunteer Your Time',
      subtitle: 'Join campaigns, attend events, and earn recognition\nfor making a real impact in your community.',
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding3.png',
      icon: Icons.insights,
      color: AppColors.accent,
      title: 'Track Real Impact',
      subtitle: 'See exactly how many families helped, items\ndistributed, and lives changed — all in real-time.',
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
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          // Dynamic Background Elements
          Positioned(
            top: -100,
            right: -50,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_currentPage].color.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pages[_currentPage].color.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                      child: const Text('Skip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),

                // Main Content (PageView)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Beautiful floating icon container
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.8, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.elasticOut,
                              builder: (context, val, child) => Transform.scale(scale: val, child: child),
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: page.color.withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                    BoxShadow(
                                      color: isDark ? Colors.black26 : Colors.black12,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Icon(page.icon, size: 80, color: page.color),
                              ),
                            ),
                            const SizedBox(height: 60),

                            // Title with gradient color or matching color
                            Text(
                              page.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Subtitle
                            Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Smooth Page Indicators
                      Row(
                        children: List.generate(_pages.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: isActive ? 32 : 8,
                            decoration: BoxDecoration(
                              color: isActive ? _pages[_currentPage].color : Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),

                      // Next / Get Started Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 56,
                        width: isLast ? 160 : 70,
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: _pages[_currentPage].color,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _pages[_currentPage].color.withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: () {
                              if (isLast) {
                                _finishOnboarding();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Center(
                              child: isLast
                                  ? const Text(
                                      'Get Started',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String image;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.image,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

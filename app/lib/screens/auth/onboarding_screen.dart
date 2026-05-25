import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHome', true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() => isLastPage = index == 2);
          },
          children: [
            _buildPage(
              color: Colors.teal.shade100,
              icon: Icons.volunteer_activism,
              title: 'Welcome to HRAS',
              subtitle: 'Join hands with Hamesha Rahein Apke Saath to make a lasting impact in our community.',
            ),
            _buildPage(
              color: Colors.orange.shade100,
              icon: Icons.event_available,
              title: 'Discover Campaigns',
              subtitle: 'Find and participate in local NGO campaigns ranging from food distribution to education.',
            ),
            _buildPage(
              color: Colors.blue.shade100,
              icon: Icons.emoji_events,
              title: 'Earn Badges & Certs',
              subtitle: 'Track your hours, earn gamified badges, and download official certificates for your CV.',
            ),
          ],
        ),
      ),
      bottomSheet: isLastPage
          ? TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(80),
              ),
              onPressed: _finishOnboarding,
              child: const Text('Get Started', style: TextStyle(fontSize: 24)),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _controller.jumpToPage(2),
                    child: const Text('SKIP'),
                  ),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      effect: WormEffect(
                        spacing: 16,
                        dotColor: Colors.black26,
                        activeDotColor: AppColors.primary,
                      ),
                      onDotClicked: (index) => _controller.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
                    child: const Text('NEXT'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPage({required Color color, required IconData icon, required String title, required String subtitle}) {
    return Container(
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 150, color: AppColors.primary),
          const SizedBox(height: 64),
          Text(title, style: AppTextStyles.headlineMedium().copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../landing/landing_screen.dart';
import '../home/home_screen.dart';
import '../../widgets/admin/admin_layout.dart';
import 'onboarding_screen.dart';

/// Premium splash screen with cinematic logo reveal
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Logo: scale + fade in (0–1.2s)
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Cubic(0.34, 1.56, 0.64, 1.0)),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    // Content: fade + slide up (0.6–1.4s)
    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    // Pulse glow for loading ring
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Sequence
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _contentController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });
    Future.delayed(const Duration(seconds: 3), _checkAuth);
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkAuthState();
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    if (!mounted) return;

    Widget nextScreen;
    if (isLoggedIn) {
      nextScreen = authProvider.isAdmin ? const AdminLayout() : const HomeScreen();
    } else if (!hasSeenOnboarding) {
      nextScreen = const OnboardingScreen();
    } else {
      nextScreen = const LandingScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = Responsive.logoSize(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // ─── Animated Logo ───
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoFade.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: logoSize + 24,
                  height: logoSize + 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: ClipOval(
                    child: Image.asset(AppConstants.logoPath, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ─── Title + Tagline ───
              SlideTransition(
                position: _contentSlide,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: Column(
                    children: [
                      Text(
                        AppConstants.orgName,
                        style: AppTextStyles.headlineLarge(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs + 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppTokens.borderRadiusPill,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          AppConstants.appTagline,
                          style: AppTextStyles.labelMedium(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ─── Loading indicator ───
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Opacity(
                    opacity: _pulseAnim.value,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white.withValues(alpha: 0.8),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Preparing your experience...',
                      style: AppTextStyles.caption(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionLg),
            ],
          ),
        ),
      ),
    );
  }
}

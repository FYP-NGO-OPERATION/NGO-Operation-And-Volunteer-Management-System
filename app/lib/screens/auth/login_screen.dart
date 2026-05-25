import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/ngo_provider.dart';
import '../../providers/virtual_session_provider.dart';
import '../../utils/validators.dart';
import '../../utils/responsive.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home/home_screen.dart';
import '../../widgets/admin/admin_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/ngo_service.dart';

/// Premium login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: AppAnimations.medium);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: AppAnimations.easeOut);
    _slideAnim = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeCtrl, curve: AppAnimations.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      SnackbarHelper.showSuccess(context, 'Welcome back, ${authProvider.user?.name ?? ''}!');
      await _handlePostAuth();
    } else {
      SnackbarHelper.showError(context, authProvider.error ?? 'Login failed.');
    }
  }

  Future<void> _handlePostAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ngoProvider = Provider.of<NgoProvider>(context, listen: false);
    final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
    
    final prefs = await SharedPreferences.getInstance();
    final pendingNgoId = prefs.getString('pending_invite_ngo_id');
    
    if (pendingNgoId != null && authProvider.user != null) {
      final targetNgo = await NgoService().getNgo(pendingNgoId);
      if (targetNgo != null) {
        await ngoProvider.selectNgo(authProvider.user!, targetNgo);
        await prefs.remove('pending_invite_ngo_id');
        // Force refresh user from DB since we updated currentNgoId
        await authProvider.checkAuthState();
      }
    }
    
    if (authProvider.user == null) return;
    await ngoProvider.loadNgoForUser(authProvider.user!);
    if (!mounted) return;
    
    final ngoId = authProvider.user!.currentNgoId ?? 'HRAS_DEFAULT_ID';
    campaignProvider.init(ngoId);
    Provider.of<VirtualSessionProvider>(context, listen: false).init(ngoId);
    Widget nextScreen = authProvider.isAdmin ? const AdminLayout() : const HomeScreen();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => nextScreen),
      (route) => false,
    );
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.signInWithGoogle();
    if (!mounted) return;

    if (success) {
      SnackbarHelper.showSuccess(context, 'Welcome, ${authProvider.user?.name ?? ''}!');
      await _handlePostAuth();
    } else {
      SnackbarHelper.showError(context, authProvider.error ?? 'Google sign-in failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoSize = Responsive.logoSize(context) - 10;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePaddingWide,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ResponsiveCenter(
                  maxWidth: 420,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ─── Logo ───
                        Center(
                          child: Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: AppTokens.shadowGlow(AppColors.primary),
                            ),
                            child: ClipOval(
                              child: Image.asset(AppConstants.logoPath, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        AppSpacing.vGapXl,

                        // ─── Title ───
                        Text(
                          'Welcome Back',
                          style: AppTextStyles.headlineLarge(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.vGapXs,
                        Text(
                          'Sign in to continue making an impact',
                          style: AppTextStyles.bodyMedium(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),

                        // ─── Email ───
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'you@example.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                        ),
                        AppSpacing.vGapLg,

                        // ─── Password ───
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          validator: Validators.password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: AppTokens.iconMd,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),

                        // ─── Forgot password ───
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context, AppAnimations.slideLeftRoute(const ForgotPasswordScreen()),
                            ),
                            child: Text('Forgot Password?', style: AppTextStyles.labelMedium(color: AppColors.primary)),
                          ),
                        ),
                        AppSpacing.vGapMd,

                        // ─── Login Button ───
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return CustomButton(
                              text: 'Sign In',
                              isLoading: auth.isLoading,
                              onPressed: _login,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // ─── Divider ───
                        Row(
                          children: [
                            Expanded(child: Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              child: Text('or', style: AppTextStyles.caption(color: AppColors.neutral400)),
                            ),
                            Expanded(child: Divider(color: isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                          ],
                        ),
                        AppSpacing.vGapLg,

                        // ─── Google Sign-In ───
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return SizedBox(
                              width: double.infinity,
                              height: AppTokens.buttonHeightMd,
                              child: OutlinedButton.icon(
                                onPressed: auth.isLoading ? null : _signInWithGoogle,
                                icon: Image.network(
                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
                                ),
                                label: Text('Continue with Google', style: AppTextStyles.button(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusMd),
                                ),
                              ),
                            );
                          },
                        ),
                        AppSpacing.vGapLg,

                        // ─── Register ───
                        CustomButton(
                          text: 'Create New Account',
                          isOutlined: true,
                          onPressed: () => Navigator.push(
                            context, AppAnimations.slideUpRoute(const RegisterScreen()),
                          ),
                        ),
                        AppSpacing.vGapLg,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

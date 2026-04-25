import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../theme/app_animations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/responsive.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../home/home_screen.dart';
import '../../widgets/admin/admin_layout.dart';

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
      Widget nextScreen = authProvider.isAdmin ? const AdminLayout() : const HomeScreen();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    } else {
      SnackbarHelper.showError(context, authProvider.error ?? 'Login failed.');
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

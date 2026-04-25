import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_animations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/responsive.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: AppAnimations.medium);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: AppAnimations.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); _emailController.dispose(); super.dispose(); }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(_emailController.text);
    if (!mounted) return;
    if (success) {
      setState(() => _emailSent = true);
      SnackbarHelper.showSuccess(context, 'Password reset email sent!');
    } else {
      SnackbarHelper.showError(context, authProvider.error ?? 'Failed to send reset email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password', style: AppTextStyles.titleLarge())),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePaddingWide,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ResponsiveCenter(maxWidth: 420, child: _emailSent ? _buildSuccessView() : _buildFormView()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 2),
          ),
          child: const Icon(Icons.lock_reset, size: 36, color: AppColors.primary),
        )),
        AppSpacing.vGapXl,
        Text('Forgot Password?', style: AppTextStyles.headlineMedium(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary), textAlign: TextAlign.center),
        AppSpacing.vGapSm,
        Text("Enter your email and we'll send you a reset link.", style: AppTextStyles.bodyMedium(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary), textAlign: TextAlign.center),
        AppSpacing.vGapXxl,
        CustomTextField(controller: _emailController, label: 'Email Address', hint: 'you@example.com',
          prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: Validators.email),
        AppSpacing.vGapXl,
        Consumer<AuthProvider>(builder: (context, auth, _) =>
          CustomButton(text: 'Send Reset Link', isLoading: auth.isLoading, onPressed: _resetPassword)),
      ]),
    );
  }

  Widget _buildSuccessView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: const Icon(Icons.mark_email_read, size: 56, color: AppColors.success),
      ),
      AppSpacing.vGapXl,
      Text('Email Sent!', style: AppTextStyles.headlineMedium(color: AppColors.success)),
      AppSpacing.vGapMd,
      Text('Check your inbox at', style: AppTextStyles.bodyMedium(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      AppSpacing.vGapXs,
      Text(_emailController.text, style: AppTextStyles.titleMedium(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
      AppSpacing.vGapXs,
      Text('and follow the link to reset your password.', style: AppTextStyles.bodyMedium(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary), textAlign: TextAlign.center),
      AppSpacing.vGapXxl,
      CustomButton(text: 'Back to Login', onPressed: () => Navigator.pop(context)),
    ]);
  }
}

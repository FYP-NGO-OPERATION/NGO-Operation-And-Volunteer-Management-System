import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../utils/phone_formatter.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
  void dispose() {
    _fadeCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
    final cleanPhone = _phoneController.text.replaceAll('-', '');
    final success = await authProvider.register(
      name: _nameController.text, email: _emailController.text,
      password: _passwordController.text, phone: cleanPhone,
    );
    if (!mounted) return;
    if (success) {
      await authProvider.logout();
      if (!mounted) return;
      SnackbarHelper.showSuccess(context, 'Account created! Please login.');
      Navigator.pop(context);
    } else {
      SnackbarHelper.showError(context, authProvider.error ?? 'Registration failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text('Create Account', style: AppTextStyles.titleLarge())),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ResponsiveCenter(
                maxWidth: 420,
                padding: AppSpacing.pagePaddingWide,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: AppTokens.shadowGlow(AppColors.primary)),
                          child: ClipOval(child: Image.asset(AppConstants.logoPath, fit: BoxFit.contain)),
                        ),
                      ),
                      AppSpacing.vGapLg,
                      Text('Join ${AppConstants.orgName}',
                        style: AppTextStyles.headlineMedium(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        textAlign: TextAlign.center),
                      AppSpacing.vGapXs,
                      Text('Register to start volunteering',
                        style: AppTextStyles.bodyMedium(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        textAlign: TextAlign.center),
                      AppSpacing.vGapXxl,

                      CustomTextField(controller: _nameController, label: 'Full Name', hint: 'Enter your full name',
                        prefixIcon: Icons.person_outline, validator: Validators.name, textInputAction: TextInputAction.next,
                        inputFormatters: [LengthLimitingTextInputFormatter(50)]),
                      AppSpacing.vGapMd,
                      CustomTextField(controller: _emailController, label: 'Email Address', hint: 'you@example.com',
                        prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next, validator: Validators.email),
                      AppSpacing.vGapMd,
                      CustomTextField(controller: _phoneController, label: 'Phone Number', hint: '03XX-XXXXXXX',
                        prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (v) => Validators.phone(v?.replaceAll('-', '')),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneInputFormatter()]),
                      AppSpacing.vGapMd,
                      CustomTextField(controller: _passwordController, label: 'Password', hint: 'Minimum 6 characters',
                        prefixIcon: Icons.lock_outline, obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next, validator: Validators.password,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: AppTokens.iconMd),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword))),
                      AppSpacing.vGapMd,
                      CustomTextField(controller: _confirmPasswordController, label: 'Confirm Password', hint: 'Re-enter password',
                        prefixIcon: Icons.lock_outline, obscureText: _obscureConfirm, validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: AppTokens.iconMd),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm))),
                      AppSpacing.vGapXxl,

                      Consumer<AuthProvider>(builder: (context, auth, _) =>
                        CustomButton(text: 'Create Account', isLoading: auth.isLoading, onPressed: _register)),
                      AppSpacing.vGapLg,
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Already have an account? ', style: AppTextStyles.bodySmall(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        TextButton(onPressed: () => Navigator.pop(context),
                          child: Text('Sign In', style: AppTextStyles.labelLarge(color: AppColors.primary))),
                      ]),
                      AppSpacing.vGapLg,
                    ],
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

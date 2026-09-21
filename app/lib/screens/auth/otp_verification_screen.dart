import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/ngo_provider.dart';
import '../../providers/virtual_session_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/snackbar_helper.dart';
import '../home/home_screen.dart';
import '../../widgets/admin/admin_layout.dart';
import '../../services/secure_storage_service.dart';
import '../../services/ngo_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // In a real app, make sure phone number includes country code e.g. +92
    String phone = widget.phoneNumber;
    if (!phone.startsWith('+')) {
      phone =
          '+92${phone.replaceFirst(RegExp(r'^0'), '')}'; // Simple fallback for PK numbers
    }

    final success = await auth.verifyPhoneNumber(phone);
    if (!mounted) return;

    if (success) {
      setState(() => _codeSent = true);
      SnackbarHelper.showSuccess(context, 'OTP sent to $phone');
    } else {
      SnackbarHelper.showError(context, auth.error ?? 'Failed to send OTP.');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 6) {
      SnackbarHelper.showError(context, 'Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.verifyOTP(_otpController.text.trim());

    if (!mounted) return;

    if (success) {
      SnackbarHelper.showSuccess(context, 'OTP Verified successfully!');
      await _handlePostAuth();
    } else {
      SnackbarHelper.showError(context, auth.error ?? 'Invalid OTP');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePostAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ngoProvider = Provider.of<NgoProvider>(context, listen: false);
    final campaignProvider = Provider.of<CampaignProvider>(
      context,
      listen: false,
    );

    final pendingNgoId = await SecureStorageService.readString('pending_invite_ngo_id');

    if (pendingNgoId != null && authProvider.user != null) {
      final targetNgo = await NgoService().getNgo(pendingNgoId);
      if (targetNgo != null) {
        await ngoProvider.selectNgo(authProvider.user!, targetNgo);
        await SecureStorageService.delete('pending_invite_ngo_id');
        await authProvider.checkAuthState();
      }
    }

    if (authProvider.user == null) return;
    await ngoProvider.loadNgoForUser(authProvider.user!);
    if (!mounted) return;

    final ngoId = authProvider.user!.currentNgoId ?? 'HRAS_DEFAULT_ID';
    campaignProvider.init(ngoId);
    Provider.of<VirtualSessionProvider>(context, listen: false).init(ngoId);
    Widget nextScreen = authProvider.isAdmin
        ? const AdminLayout()
        : const HomeScreen();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => nextScreen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePaddingWide,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 80, color: AppColors.primary),
                AppSpacing.vGapXl,
                Text(
                  'Verify Your Account',
                  style: AppTextStyles.headlineMedium(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.vGapXs,
                Text(
                  'We have sent a 6-digit OTP code to\n${widget.phoneNumber}',
                  style: AppTextStyles.bodyMedium(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),

                CustomTextField(
                  controller: _otpController,
                  label: '6-Digit OTP',
                  hint: 'Enter OTP',
                  prefixIcon: Icons.lock_clock,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),
                AppSpacing.vGapLg,

                CustomButton(
                  text: 'Verify OTP',
                  isLoading: _isLoading && _codeSent,
                  onPressed: _verifyOtp,
                ),

                AppSpacing.vGapLg,
                if (!_isLoading)
                  TextButton(
                    onPressed: _sendOtp,
                    child: Text(
                      'Resend Code',
                      style: AppTextStyles.button(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../enums/app_enums.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final double amount;
  final String donorName;

  const PaymentProcessingScreen({
    super.key,
    required this.paymentMethod,
    required this.amount,
    required this.donorName,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> with SingleTickerProviderStateMixin {
  String _statusMessage = 'Initializing secure connection...';
  double _progress = 0.0;
  bool _isSuccess = false;
  late String _transactionId;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _simulatePaymentFlow();
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  Future<void> _simulatePaymentFlow() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() { _progress = 0.3; _statusMessage = 'Connecting to ${widget.paymentMethod.label} Gateway...'; });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() { _progress = 0.7; _statusMessage = 'Processing payment for Rs.${widget.amount.toStringAsFixed(0)}...'; });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() { _progress = 1.0; _isSuccess = true; _statusMessage = 'Payment Successful!'; });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context, _transactionId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffoldBg : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isSuccess
                    ? Container(
                        key: const ValueKey('success'),
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withValues(alpha: 0.1),
                          boxShadow: AppTokens.shadowGlow(AppColors.success),
                        ),
                        child: const Icon(Icons.check_circle, color: AppColors.success, size: 80),
                      )
                    : FadeTransition(
                        key: const ValueKey('loading'),
                        opacity: Tween(begin: 0.6, end: 1.0).animate(_pulseCtrl),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 110, height: 110,
                              child: CircularProgressIndicator(
                                value: _progress,
                                color: AppColors.primary,
                                strokeWidth: 6,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            Text(widget.paymentMethod.icon, style: const TextStyle(fontSize: 40)),
                          ],
                        ),
                      ),
              ),
              AppSpacing.vGapXxl,
              Text(_statusMessage,
                style: _isSuccess
                    ? AppTextStyles.titleLarge(color: AppColors.success)
                    : AppTextStyles.titleLarge(),
                textAlign: TextAlign.center),
              AppSpacing.vGapLg,
              if (!_isSuccess)
                Text('Please do not close this window or press back.',
                  style: AppTextStyles.bodySmall(color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                  textAlign: TextAlign.center),
              if (_isSuccess) ...[
                AppSpacing.vGapSm,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppTokens.borderRadiusPill,
                  ),
                  child: Text('ID: $_transactionId',
                    style: AppTextStyles.labelSmall(color: AppColors.success)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

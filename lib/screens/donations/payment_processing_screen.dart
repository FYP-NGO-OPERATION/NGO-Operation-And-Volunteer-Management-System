import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    _simulatePaymentFlow();
  }

  Future<void> _simulatePaymentFlow() async {
    // 1. Initialize
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _progress = 0.3;
      _statusMessage = 'Connecting to ${widget.paymentMethod.label} Gateway...';
    });

    // 2. Process
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _progress = 0.7;
      _statusMessage = 'Processing payment for Rs.${widget.amount.toStringAsFixed(0)}...';
    });

    // 3. Complete
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _progress = 1.0;
      _isSuccess = true;
      _statusMessage = 'Payment Successful!';
    });

    // 4. Return to previous screen with TXN ID
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context, _transactionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isSuccess
                    ? const Icon(Icons.check_circle, color: AppColors.success, size: 100, key: ValueKey('success'))
                    : Stack(
                        alignment: Alignment.center,
                        key: const ValueKey('loading'),
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: _progress,
                              color: AppColors.primary,
                              strokeWidth: 8,
                            ),
                          ),
                          Text(widget.paymentMethod.icon, style: const TextStyle(fontSize: 40)),
                        ],
                      ),
              ),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!_isSuccess)
                const Text(
                  'Please do not close this window or press back.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

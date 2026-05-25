import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../config/app_colors.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/custom_button.dart';

class VolunteerKycScreen extends StatefulWidget {
  const VolunteerKycScreen({super.key});

  @override
  State<VolunteerKycScreen> createState() => _VolunteerKycScreenState();
}

class _VolunteerKycScreenState extends State<VolunteerKycScreen> {
  bool _isProcessing = false;
  String _scanResult = '';

  Future<void> _scanIdCard() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _isProcessing = true;
      _scanResult = 'Analyzing Document...';
    });

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String extractedText = recognizedText.text.toUpperCase();
      
      await textRecognizer.close();

      // Basic matching logic: check if user's name or a CNIC format exists
      final authProvider = context.read<AuthProvider>();
      final userName = authProvider.user?.name.toUpperCase() ?? '';

      // Clean up the name parts to match with ID
      List<String> nameParts = userName.split(' ');
      bool nameMatchFound = false;
      for (var part in nameParts) {
        if (part.length > 2 && extractedText.contains(part)) {
          nameMatchFound = true;
          break;
        }
      }

      // Check for CNIC pattern: XXXXX-XXXXXXX-X (Pakistan)
      RegExp cnicPattern = RegExp(r'\d{5}[\s\-]?\d{7}[\s\-]?\d{1}');
      bool cnicFound = cnicPattern.hasMatch(extractedText);

      if (nameMatchFound || cnicFound) {
        // Success
        await authProvider.updateVerificationStatus(true);
        setState(() {
          _scanResult = 'Verification Successful! Identity confirmed.';
        });
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'Your ID has been verified!');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pop(context);
          });
        }
      } else {
        setState(() {
          _scanResult = 'Verification Failed. Name or ID number not clearly visible. Please try again in good lighting.';
        });
      }

    } catch (e) {
      setState(() {
        _scanResult = 'Error during scanning: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isVerified = user?.isIdVerified ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Identity Verification', style: AppTextStyles.titleLarge()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: isVerified
            ? _buildVerifiedState()
            : _buildUnverifiedState(),
      ),
    );
  }

  Widget _buildVerifiedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified, color: AppColors.primary, size: 100),
          AppSpacing.vGapLg,
          Text(
            'You are Verified!',
            style: AppTextStyles.headlineMedium().copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.vGapMd,
          const Text(
            'Your identity has been securely verified on-device. Your ID picture was not uploaded to our servers.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          AppSpacing.vGapXl,
          CustomButton(
            text: 'Go Back',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUnverifiedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.badge, size: 80, color: AppColors.primary),
        AppSpacing.vGapLg,
        Text(
          'e-KYC Verification',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium().copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.vGapSm,
        const Text(
          'To ensure trust within the NGO network, please scan your National ID card.\n\n🔒 We use On-Device Machine Learning. Your photo is never uploaded to the cloud.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        AppSpacing.vGapXl,
        if (_scanResult.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _scanResult.contains('Successful') ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _scanResult,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _scanResult.contains('Successful') ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppSpacing.vGapLg,
        ],
        const Spacer(),
        CustomButton(
          text: 'Scan ID Card',
          isLoading: _isProcessing,
          onPressed: _scanIdCard,
          icon: Icons.camera_alt,
        ),
        AppSpacing.vGapLg,
      ],
    );
  }
}

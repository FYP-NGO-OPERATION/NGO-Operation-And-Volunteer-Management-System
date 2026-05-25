import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';

class EkycVerificationScreen extends StatefulWidget {
  const EkycVerificationScreen({super.key});

  @override
  State<EkycVerificationScreen> createState() => _EkycVerificationScreenState();
}

class _EkycVerificationScreenState extends State<EkycVerificationScreen> {
  File? _imageFile;
  bool _isProcessing = false;
  String _statusMessage = 'Center your face in the camera frame.';
  double _livenessScore = 0.0;

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _statusMessage = 'Analyzing liveness...';
      });
      _simulateLivenessDetection();
    }
  }

  Future<void> _simulateLivenessDetection() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _statusMessage = 'Checking face angle...';
      _livenessScore = 0.4;
    });

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _statusMessage = 'Detecting eye blink...';
      _livenessScore = 0.8;
    });

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _statusMessage = 'Liveness Confirmed!';
      _livenessScore = 1.0;
      _isProcessing = false;
    });
  }

  Future<void> _submitVerification() async {
    if (_livenessScore < 1.0) return;

    setState(() => _isProcessing = true);
    
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'isIdVerified': true,
        });
        
        if (mounted) {
          SnackbarHelper.showSuccess(context, 'e-KYC Verification Successful!');
          Navigator.pop(context, true); // true = verified
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Verification failed: $e');
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('e-KYC Verification'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.face_retouching_natural, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Verify Your Identity',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Take a clear selfie to prove you are a real person. This helps us maintain a secure community.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              if (_imageFile == null)
                ElevatedButton.icon(
                  onPressed: _takeSelfie,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Open Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                )
              else ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _livenessScore == 1.0 ? AppColors.success : AppColors.primary,
                          width: 4,
                        ),
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_isProcessing)
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 6,
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _livenessScore == 1.0 ? AppColors.success : Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                if (_livenessScore > 0)
                  LinearProgressIndicator(
                    value: _livenessScore,
                    color: _livenessScore == 1.0 ? AppColors.success : AppColors.primary,
                    minHeight: 8,
                  ),
                const SizedBox(height: 32),
                if (_livenessScore == 1.0 && !_isProcessing)
                  ElevatedButton(
                    onPressed: _submitVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text('Submit Verification'),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

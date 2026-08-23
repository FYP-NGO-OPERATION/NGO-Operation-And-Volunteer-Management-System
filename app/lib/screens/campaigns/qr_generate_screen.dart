import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../services/qr_service.dart';

/// Admin screen to generate a QR code for campaign attendance.
///
/// Features a premium, glassmorphism UI with glowing effects
/// for a highly aesthetically pleasing experience.
class QrGenerateScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const QrGenerateScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  State<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrData = QrService.generateQrPayload(
      campaignId: widget.campaignId,
      campaignTitle: widget.campaignTitle,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Scan for Attendance', style: AppTextStyles.titleLarge().copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSpacing.vGapXl,
                
                // Animated Glowing Background behind QR
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow pulse
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Glassmorphism Card containing QR
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              // Campaign title inside card
                              Text(
                                widget.campaignTitle,
                                style: AppTextStyles.titleLarge().copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppSpacing.vGapLg,
                              
                              // Actual QR Code
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: 240,
                                  backgroundColor: Colors.white,
                                  embeddedImage: const AssetImage('assets/images/logo.png'),
                                  embeddedImageStyle: const QrEmbeddedImageStyle(
                                    size: Size(50, 50),
                                  ),
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: AppColors.primaryDark,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              
                              AppSpacing.vGapLg,
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.qr_code_scanner, color: Colors.white70, size: 20),
                                  AppSpacing.hGapSm,
                                  Text(
                                    'Ready to scan',
                                    style: AppTextStyles.bodyMedium(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                AppSpacing.vGapXxl,
                
                // Instructions Card (Glassmorphism)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.info_outline, color: AppColors.accentLight, size: 20),
                              ),
                              AppSpacing.hGapMd,
                              Text('How it works', style: AppTextStyles.labelLarge(color: Colors.white)),
                            ],
                          ),
                          AppSpacing.vGapMd,
                          _buildInstructionStep('1', 'Show this code to arriving volunteers'),
                          AppSpacing.vGapSm,
                          _buildInstructionStep('2', 'Volunteers scan it with their HRAS app'),
                          AppSpacing.vGapSm,
                          _buildInstructionStep('3', 'Attendance is instantly recorded'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$step.',
          style: AppTextStyles.bodyMedium(color: Colors.white70).copyWith(fontWeight: FontWeight.bold),
        ),
        AppSpacing.hGapSm,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

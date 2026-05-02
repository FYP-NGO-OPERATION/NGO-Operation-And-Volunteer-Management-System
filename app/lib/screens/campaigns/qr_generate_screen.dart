import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../services/qr_service.dart';

/// Admin screen to generate a QR code for campaign attendance.
///
/// Displays a scannable QR code that volunteers can scan
/// with the QR Scanner screen to mark their attendance.
class QrGenerateScreen extends StatelessWidget {
  final String campaignId;
  final String campaignTitle;

  const QrGenerateScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qrData = QrService.generateQrPayload(
      campaignId: campaignId,
      campaignTitle: campaignTitle,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance QR Code', style: AppTextStyles.titleLarge()),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campaign title
              Text(
                campaignTitle,
                style: AppTextStyles.titleLarge(),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapMd,
              Text(
                'Show this QR code to volunteers for attendance',
                style: AppTextStyles.bodyMedium(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.vGapXxl,

              // QR Code
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTokens.borderRadiusLg,
                  boxShadow: AppTokens.shadowSoft,
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 260,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1A1A2E),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              AppSpacing.vGapXxl,

              // Instructions
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: AppTokens.borderRadiusMd,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.info, size: 20),
                        AppSpacing.hGapSm,
                        Text('How it works', style: AppTextStyles.labelLarge(color: AppColors.info)),
                      ],
                    ),
                    AppSpacing.vGapSm,
                    Text(
                      '1. Show this QR code at the campaign venue\n'
                      '2. Volunteers open the app and tap "Scan QR"\n'
                      '3. Their attendance is automatically recorded',
                      style: AppTextStyles.bodySmall(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

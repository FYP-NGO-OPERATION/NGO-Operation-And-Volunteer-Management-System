import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../config/app_colors.dart';
import '../../utils/snackbar_helper.dart';
import '../../widgets/common/custom_button.dart';

class BloodEmergencyScreen extends StatefulWidget {
  const BloodEmergencyScreen({super.key});

  @override
  State<BloodEmergencyScreen> createState() => _BloodEmergencyScreenState();
}

class _BloodEmergencyScreenState extends State<BloodEmergencyScreen> {
  String? _selectedBloodGroup;
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendEmergencyAlert() async {
    if (_selectedBloodGroup == null || _messageController.text.trim().isEmpty) {
      SnackbarHelper.showError(
        context,
        'Please select a blood group and enter a message.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // In a real app, this would call a Cloud Function or backend to query users with
      // this blood group and send an FCM push notification.
      // For FYP demonstration, we simulate the broadcast:

      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate network request

      if (mounted) {
        SnackbarHelper.showSuccess(
          context,
          '🚨 Emergency Alert sent to all $_selectedBloodGroup donors!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        SnackbarHelper.showError(context, 'Failed to send alert: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blood Emergency',
          style: AppTextStyles.titleLarge(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.bloodtype, size: 80, color: Colors.red),
            AppSpacing.vGapLg,
            Text(
              'Broadcast Urgent Request',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vGapSm,
            const Text(
              'Send a High-Priority Push Notification to all verified volunteers matching the required blood group in your NGO.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            AppSpacing.vGapXxl,

            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              decoration: const InputDecoration(
                labelText: 'Required Blood Group',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search, color: Colors.red),
              ),
              items: _bloodGroups.map((bg) {
                return DropdownMenuItem(
                  value: bg,
                  child: Text(
                    bg,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBloodGroup = val),
            ),
            AppSpacing.vGapLg,

            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Emergency Message',
                hintText:
                    'e.g., Urgent need of O- blood at City Hospital for an accident victim. Please reach out ASAP.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            AppSpacing.vGapXxl,

            CustomButton(
              text: '🚨 BROADCAST ALERT',
              backgroundColor: Colors.red.shade700,
              isLoading: _isLoading,
              onPressed: _sendEmergencyAlert,
            ),
          ],
        ),
      ),
    );
  }
}

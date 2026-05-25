import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DonationTrackerScreen extends StatelessWidget {
  final String donationId;
  final double amount;
  
  const DonationTrackerScreen({
    super.key,
    this.donationId = 'DON-98234710',
    this.amount = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transparent Tracker'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Blockchain Mock Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Icon(Icons.security, color: Colors.green, size: 40),
                  const SizedBox(height: 8),
                  Text('Blockchain Verified', style: AppTextStyles.titleMedium(color: Colors.green)),
                  const SizedBox(height: 8),
                  Text(
                    'Tx Hash: 0x7F9B8A...D4C2\nAmount: \$${amount.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Custom Timeline
            _buildTimelineNode(
              title: 'Donation Received',
              description: 'Funds safely deposited in NGO Escrow Account.',
              date: 'Oct 12, 10:00 AM',
              isCompleted: true,
              isFirst: true,
            ),
            _buildTimelineNode(
              title: 'Material Purchased',
              description: 'Vendor: City Supermart (Invoice #1029)',
              date: 'Oct 13, 02:30 PM',
              isCompleted: true,
            ),
            _buildTimelineNode(
              title: 'Allocated to Campaign',
              description: 'Food distribution drive in Sector 11.',
              date: 'Oct 14, 09:00 AM',
              isCompleted: true,
            ),
            _buildTimelineNode(
              title: 'Handed over to Beneficiary',
              description: 'Beneficiary #B-452. Verified via biometric.',
              date: 'Oct 14, 01:45 PM',
              isCompleted: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineNode({
    required String title,
    required String description,
    required String date,
    required bool isCompleted,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : (isCompleted ? Colors.green : Colors.grey),
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.green : Colors.grey,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : (isCompleted ? Colors.green : Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium()),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.bodyMedium(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

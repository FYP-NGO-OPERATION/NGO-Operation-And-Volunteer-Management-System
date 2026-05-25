import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodDonationScreen extends StatefulWidget {
  const BloodDonationScreen({super.key});

  @override
  State<BloodDonationScreen> createState() => _BloodDonationScreenState();
}

class _BloodDonationScreenState extends State<BloodDonationScreen> {
  final _bloodReqController = TextEditingController();
  final _hospitalController = TextEditingController();
  String _selectedType = 'A+';
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Emergency Network', style: AppTextStyles.titleLarge()),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildInfoBanner(user?.bloodGroup, user?.isBloodDonor ?? false),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('blood_requests').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No active blood requests.'));
                }

                final reqs = snapshot.data!.docs;
                return ListView.builder(
                  padding: AppSpacing.pagePaddingWide,
                  itemCount: reqs.length,
                  itemBuilder: (ctx, i) {
                    final data = reqs[i].data() as Map<String, dynamic>;
                    final isMatch = user?.bloodGroup == data['bloodGroup'] && (user?.isBloodDonor ?? false);
                    return _buildRequestCard(data, isMatch, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRequestDialog(context),
        backgroundColor: AppColors.error,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text('Need Blood', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInfoBanner(String? myGroup, bool isDonor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.error.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Your Group: ${myGroup ?? 'Unknown'}', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (isDonor) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(12)),
                  child: const Text('Registered Donor', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ]
            ],
          ),
          if (!isDonor)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('Update your profile to register as a donor and save lives.', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data, bool isMatch, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isMatch ? AppColors.error : Colors.transparent, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.error.withOpacity(0.2),
                      child: Text(data['bloodGroup'], style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Patient: ${data['patientName']}', style: AppTextStyles.titleMedium(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                        Text('Units Needed: ${data['units']}', style: AppTextStyles.bodyMedium(color: AppColors.error)),
                      ],
                    ),
                  ],
                ),
                if (isMatch)
                  const Icon(Icons.stars, color: AppColors.error, size: 30),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.local_hospital, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(data['hospital'], style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  launchUrl(Uri.parse('tel:${data['contactPhone']}'));
                },
                icon: const Icon(Icons.phone),
                label: const Text('Contact Family'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Request Blood'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _bloodReqController, decoration: const InputDecoration(labelText: 'Patient Name')),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setDialogState(() => _selectedType = v!),
                      decoration: const InputDecoration(labelText: 'Blood Group Needed'),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: _hospitalController, decoration: const InputDecoration(labelText: 'Hospital Name & City')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (_bloodReqController.text.isEmpty || _hospitalController.text.isEmpty) return;
                    
                    final user = context.read<AuthProvider>().user;
                    await FirebaseFirestore.instance.collection('blood_requests').add({
                      'patientName': _bloodReqController.text,
                      'bloodGroup': _selectedType,
                      'hospital': _hospitalController.text,
                      'contactPhone': user?.phone ?? '0000000000',
                      'units': 1,
                      'requesterId': user?.uid,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    
                    if (mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  child: const Text('Submit Request'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

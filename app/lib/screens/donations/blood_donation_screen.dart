import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class BloodDonationScreen extends StatefulWidget {
  const BloodDonationScreen({super.key});

  @override
  State<BloodDonationScreen> createState() => _BloodDonationScreenState();
}

class _BloodDonationScreenState extends State<BloodDonationScreen> {
  final _bloodReqController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _contactController = TextEditingController();
  String _selectedType = 'A+';
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

  @override
  void dispose() {
    _bloodReqController.dispose();
    _hospitalController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${'blood_emergency'.tr()} Network',
          style: AppTextStyles.titleLarge(),
        ),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildInfoBanner(user?.bloodGroup, user?.isBloodDonor ?? false),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('blood_requests')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('no_active_blood_requests'.tr()));
                }

                final reqs = snapshot.data!.docs;
                return ListView.builder(
                  padding: AppSpacing.pagePaddingWide,
                  itemCount: reqs.length,
                  itemBuilder: (ctx, i) {
                    final data = reqs[i].data() as Map<String, dynamic>;
                    final isMatch =
                        user?.bloodGroup == data['bloodGroup'] &&
                        (user?.isBloodDonor ?? false);
                    final isMine = user?.uid == data['requesterId'];
                    return _buildRequestCard(
                      reqs[i].id,
                      data,
                      isMatch,
                      isDark,
                      isMine,
                    );
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
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: Text(
          'need_blood'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
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
              Text(
                '${'your_group'.tr()} ${myGroup ?? 'unknown'.tr()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (isDonor) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Registered Donor',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
          if (!isDonor)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'update_blood_profile'.tr(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    String docId,
    Map<String, dynamic> data,
    bool isMatch,
    bool isDark,
    bool isMine,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isMatch ? AppColors.error : Colors.transparent,
          width: 2,
        ),
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
                      child: Text(
                        data['bloodGroup'],
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient: ${data['patientName']}',
                          style: AppTextStyles.titleMedium(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Units Needed: ${data['units']}',
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.error,
                          ),
                        ),
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
                const Icon(
                  Icons.local_hospital,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  data['hospital'],
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
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
                if (isMine) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Request'),
                          content: const Text(
                            'Are you sure you want to delete this blood request?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection('blood_requests')
                            .doc(docId)
                            .delete();
                      }
                    },
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    tooltip: 'Delete Request',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDialog(BuildContext context) {
    _bloodReqController.clear();
    _hospitalController.clear();
    _contactController.clear();
    _selectedType = 'A+';

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
                    TextField(
                      controller: _bloodReqController,
                      decoration: const InputDecoration(
                        labelText: 'Patient Name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      items: _bloodGroups
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => _selectedType = v!),
                      decoration: const InputDecoration(
                        labelText: 'Blood Group Needed',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _hospitalController,
                      decoration: const InputDecoration(
                        labelText: 'Hospital Name & City',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone Number',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_bloodReqController.text.isEmpty ||
                        _hospitalController.text.isEmpty ||
                        _contactController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    final user = context.read<AuthProvider>().user;
                    try {
                      await FirebaseFirestore.instance
                          .collection('blood_requests')
                          .add({
                            'patientName': _bloodReqController.text,
                            'bloodGroup': _selectedType,
                            'hospital': _hospitalController.text,
                            'contactPhone': _contactController.text,
                            'units': 1,
                            'requesterId': user?.uid,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                      if (mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                'An unexpected error occurred. Please try again.',
                              ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

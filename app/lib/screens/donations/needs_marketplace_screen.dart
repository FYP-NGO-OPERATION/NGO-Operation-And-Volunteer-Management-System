import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class NeedsMarketplaceScreen extends StatefulWidget {
  const NeedsMarketplaceScreen({super.key});

  @override
  State<NeedsMarketplaceScreen> createState() => _NeedsMarketplaceScreenState();
}

class _NeedsMarketplaceScreenState extends State<NeedsMarketplaceScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text('Needs Marketplace', style: AppTextStyles.titleLarge()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('public_needs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No needs reported yet.'));
          }

          final needs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: needs.length,
            itemBuilder: (ctx, i) {
              final data = needs[i].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: status == 'adopted' ? AppColors.success : Colors.transparent),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(data['title'] ?? '', style: AppTextStyles.titleMedium()),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: status == 'adopted' ? AppColors.success.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: status == 'adopted' ? AppColors.success : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(data['description'] ?? '', style: AppTextStyles.bodyMedium()),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(child: Text(data['location'] ?? '', style: AppTextStyles.bodySmall())),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (isAdmin && status == 'pending')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _adoptNeed(needs[i].id),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                            child: const Text('Adopt & Create Campaign'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: !isAdmin ? FloatingActionButton.extended(
        onPressed: () => _showPostNeedDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Report Need', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ) : null,
    );
  }

  void _adoptNeed(String id) async {
    await FirebaseFirestore.instance.collection('public_needs').doc(id).update({
      'status': 'adopted',
      'adoptedAt': FieldValue.serverTimestamp(),
      'adoptedBy': context.read<AuthProvider>().user?.uid,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Need adopted! Create a campaign for it.')));
    }
  }

  void _showPostNeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Report a Need'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title (e.g., Tents needed in XYZ)')),
                const SizedBox(height: 12),
                TextField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 12),
                TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty) return;
                final user = context.read<AuthProvider>().user;
                
                await FirebaseFirestore.instance.collection('public_needs').add({
                  'title': _titleController.text,
                  'description': _descController.text,
                  'location': _locationController.text,
                  'status': 'pending',
                  'reporterId': user?.uid,
                  'reporterName': user?.name,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                
                _titleController.clear();
                _descController.clear();
                _locationController.clear();
                
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Submit'),
            )
          ],
        );
      },
    );
  }
}

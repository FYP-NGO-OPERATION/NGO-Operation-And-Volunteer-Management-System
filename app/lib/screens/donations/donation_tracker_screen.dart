import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DonationTrackerScreen extends StatefulWidget {
  final String donationId;
  final double amount;

  const DonationTrackerScreen({
    super.key,
    required this.donationId,
    required this.amount,
  });

  @override
  State<DonationTrackerScreen> createState() => _DonationTrackerScreenState();
}

class _DonationTrackerScreenState extends State<DonationTrackerScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  Future<void> _addEvent() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('donation_tracking_events')
          .add({
            'donationId': widget.donationId,
            'title': _titleController.text.trim(),
            'description': _descController.text.trim(),
            'timestamp': FieldValue.serverTimestamp(),
            'isCompleted': true,
          });
      if (mounted) {
        Navigator.pop(context);
        _titleController.clear();
        _descController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tracking Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title (e.g. Material Purchased)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description (e.g. Vendor Invoice #123)',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSaving ? null : _addEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Add Event'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transparent Tracker'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donation_tracking_events')
            .where('donationId', isEqualTo: widget.donationId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data?.docs.toList() ?? [];

          // Sort locally to avoid Firestore Composite Index requirements
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aTime =
                (aData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            final bTime =
                (bData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            return aTime.compareTo(bTime);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Blockchain Mock Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.security, color: Colors.green, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Supply Chain Verified',
                        style: AppTextStyles.titleMedium(color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Amount Tracked: Rs.${widget.amount.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (docs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: Center(
                      child: Text(
                        'No tracking events found yet.\nAdmin will update this soon.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                // Dynamic Timeline
                for (var i = 0; i < docs.length; i++) ...[
                  Builder(
                    builder: (context) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'Event';
                      final desc = data['description'] ?? '';
                      final isCompleted = data['isCompleted'] ?? true;
                      final date =
                          (data['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now();

                      return _buildTimelineNode(
                        title: title,
                        description: desc,
                        date: DateFormat('MMM dd, hh:mm a').format(date),
                        isCompleted: isCompleted,
                        isFirst: i == 0,
                        isLast: i == docs.length - 1,
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
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
                    color: isFirst
                        ? Colors.transparent
                        : (isCompleted ? Colors.green : Colors.grey),
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
                    color: isLast
                        ? Colors.transparent
                        : (isCompleted ? Colors.green : Colors.grey),
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
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium(color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

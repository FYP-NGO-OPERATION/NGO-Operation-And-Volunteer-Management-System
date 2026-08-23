import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/tracking_event_model.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/snackbar_helper.dart';

class ManageTrackingEventsScreen extends StatelessWidget {
  const ManageTrackingEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tracking Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donation_tracking_events')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No tracking events found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final event = TrackingEventModel.fromMap(data, docs[index].id);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: AppTextStyles.titleMedium(color: Colors.green),
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, hh:mm a').format(event.timestamp),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(event.description, style: AppTextStyles.bodyMedium()),
                      const SizedBox(height: 8),
                      Text('Donation ID: ${event.donationId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _showEditDialog(context, event),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: () => _deleteEvent(context, event.id),
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            label: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, TrackingEventModel event) {
    final titleCtrl = TextEditingController(text: event.title);
    final descCtrl = TextEditingController(text: event.description);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Tracking Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('donation_tracking_events')
                    .doc(event.id)
                    .update({
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                });
                Navigator.pop(ctx);
                SnackbarHelper.showSuccess(context, 'Event updated successfully');
              } catch (e) {
                SnackbarHelper.showError(context, 'Failed to update: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteEvent(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('This will permanently remove the tracking event from the donor\'s timeline. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('donation_tracking_events')
                    .doc(eventId)
                    .delete();
                Navigator.pop(ctx);
                SnackbarHelper.showSuccess(context, 'Event deleted successfully');
              } catch (e) {
                SnackbarHelper.showError(context, 'Failed to delete: $e');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

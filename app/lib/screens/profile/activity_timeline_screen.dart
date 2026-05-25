import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_colors.dart';
import '../../models/campaign_model.dart';
import '../campaigns/campaign_detail_screen.dart';

/// Volunteer Activity Timeline — Shows all campaigns a volunteer has participated in
class ActivityTimelineScreen extends StatelessWidget {
  const ActivityTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      appBar: AppBar(
        title: Text('activity_timeline'.tr()),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('campaigns')
            .where('ngoId', isEqualTo: user.currentNgoId ?? 'HRAS_DEFAULT_ID')
            .orderBy('startDate', descending: true)
            .snapshots(),
        builder: (context, campaignSnapshot) {
          if (campaignSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allCampaigns = campaignSnapshot.data?.docs ?? [];

          return FutureBuilder<List<_TimelineEntry>>(
            future: _buildTimeline(user.uid, allCampaigns),
            builder: (context, timelineSnapshot) {
              if (timelineSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final entries = timelineSnapshot.data ?? [];
              if (entries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timeline, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No activity yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join campaigns to build your timeline!',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final isFirst = index == 0;
                  final isLast = index == entries.length - 1;

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Line + Dot
                        SizedBox(
                          width: 40,
                          child: Column(
                            children: [
                              if (!isFirst)
                                Expanded(
                                  flex: 1,
                                  child: Container(width: 2, color: entry.color.withOpacity(0.3)),
                                ),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: entry.color,
                                  boxShadow: [
                                    BoxShadow(color: entry.color.withOpacity(0.4), blurRadius: 6, spreadRadius: 1),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  flex: 3,
                                  child: Container(width: 2, color: entry.color.withOpacity(0.3)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Card
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: entry.campaign)),
                              );
                            },
                            child: Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(entry.icon, color: entry.color, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            entry.campaign.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                                        const SizedBox(width: 6),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(entry.campaign.startDate),
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: entry.color.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            entry.statusLabel,
                                            style: TextStyle(fontSize: 11, color: entry.color, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${entry.campaign.type.icon} ${entry.campaign.type.label} • ${entry.campaign.location}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<_TimelineEntry>> _buildTimeline(String userId, List<QueryDocumentSnapshot> campaignDocs) async {
    List<_TimelineEntry> entries = [];

    for (final doc in campaignDocs) {
      final campaign = CampaignModel.fromMap(doc.data() as Map<String, dynamic>);
      // Check if user is a volunteer in this campaign
      final volSnap = await FirebaseFirestore.instance
          .collection('campaigns')
          .doc(campaign.id)
          .collection('volunteers')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (volSnap.docs.isNotEmpty) {
        final volData = volSnap.docs.first.data();
        final status = volData['status'] ?? 'registered';

        Color color;
        IconData icon;
        String label;

        switch (status) {
          case 'attended':
            color = AppColors.success;
            icon = Icons.check_circle;
            label = '✅ Attended';
            break;
          case 'confirmed':
            color = AppColors.info;
            icon = Icons.verified;
            label = '🔵 Confirmed';
            break;
          case 'registered':
            color = AppColors.primary;
            icon = Icons.how_to_reg;
            label = '📝 Registered';
            break;
          case 'pending':
            color = AppColors.warning;
            icon = Icons.pending;
            label = '⏳ Pending';
            break;
          default:
            color = Colors.grey;
            icon = Icons.circle;
            label = status;
        }

        entries.add(_TimelineEntry(
          campaign: campaign,
          color: color,
          icon: icon,
          statusLabel: label,
        ));
      }
    }

    return entries;
  }
}

class _TimelineEntry {
  final CampaignModel campaign;
  final Color color;
  final IconData icon;
  final String statusLabel;

  _TimelineEntry({
    required this.campaign,
    required this.color,
    required this.icon,
    required this.statusLabel,
  });
}

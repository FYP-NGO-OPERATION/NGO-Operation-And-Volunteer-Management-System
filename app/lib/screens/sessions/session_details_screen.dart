import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/virtual_session_model.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SessionDetailsScreen extends StatelessWidget {
  final VirtualSessionModel session;

  const SessionDetailsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Session Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "RSVP'd Volunteers"),
              Tab(text: 'Attended (Participants)'),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (session.imageUrl != null)
              CachedNetworkImage(
                imageUrl: session.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.title, style: AppTextStyles.headlineSmall().copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (session.secretCode != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock, color: AppColors.warning),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Verification Code: ${session.secretCode}',
                                  style: AppTextStyles.titleSmall().copyWith(color: AppColors.warning),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.event, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy • hh:mm a').format(session.sessionDate),
                        style: AppTextStyles.bodyLarge(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildUserList(session.rsvpUsers, 'No RSVPs yet.'),
                  _buildUserList(session.attendedUsers, 'No participants yet.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(Map<String, String> users, String emptyMessage) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage, style: AppTextStyles.bodyLarge(color: Colors.grey)),
          ],
        ),
      );
    }

    final entries = users.entries.toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final userId = entries[index].key;
        final userName = entries[index].value;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary)),
          ),
          title: Text(userName, style: AppTextStyles.titleMedium()),
          subtitle: Text('ID: $userId', style: AppTextStyles.caption(color: Colors.grey)),
        );
      },
    );
  }
}

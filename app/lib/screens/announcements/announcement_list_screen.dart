import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/announcement_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/announcement_service.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'create_announcement_screen.dart';

class AnnouncementListScreen extends StatelessWidget {
  const AnnouncementListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.read<AuthProvider>().user?.isAdmin ?? false;
    final announcementService = AnnouncementService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Announcements'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<List<AnnouncementModel>>(
        stream: announcementService.getAnnouncementsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final announcements = snapshot.data ?? [];

          if (announcements.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.campaign_outlined,
              title: 'No Announcements Yet',
              subtitle: isAdmin 
                  ? 'Tap the + button to post your first update.'
                  : 'There are no official updates from the NGO yet.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return _AnnouncementCard(
                announcement: announcement,
                isAdmin: isAdmin,
                onDelete: () => announcementService.deleteAnnouncement(announcement.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final bool isAdmin;
  final VoidCallback onDelete;

  const _AnnouncementCard({
    required this.announcement,
    required this.isAdmin,
    required this.onDelete,
  });

  void _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withOpacity(0.15), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              AppColors.primary.withOpacity(0.03),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        announcement.authorName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.authorName,
                          style: AppTextStyles.titleMedium().copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a').format(announcement.createdAt),
                          style: AppTextStyles.labelSmall(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.campaign, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text('Update', style: AppTextStyles.labelSmall(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: AppColors.textHint),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                      onSelected: (val) {
                        if (val == 'delete') _confirmDelete(context);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                announcement.title, 
                style: AppTextStyles.headlineSmall().copyWith(
                  fontWeight: FontWeight.w900, 
                )
              ),
              const SizedBox(height: 12),
              Text(
                announcement.message,
                style: const TextStyle(height: 1.6, fontSize: 15),
              ),
              const SizedBox(height: 16),
              if (announcement.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: announcement.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: AppColors.neutral200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: AppColors.neutral200,
                      child: const Center(child: Icon(Icons.error, color: AppColors.error)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (announcement.videoUrl != null) ...[
                OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(announcement.videoUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.play_circle_fill, color: Colors.red),
                  label: const Text('Watch Reference Video', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/virtual_session_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SessionListScreen extends StatelessWidget {
  const SessionListScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the meeting link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final isAdmin = user?.isAdmin == true;

    return Consumer<VirtualSessionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.sessions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No virtual sessions scheduled.',
                    style: AppTextStyles.bodyLarge(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.sessions.length,
          itemBuilder: (context, index) {
            final session = provider.sessions[index];
            final isUpcoming = session.isUpcoming;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: isDark ? AppColors.darkCardBg : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isUpcoming ? AppColors.success.withValues(alpha: 0.1) : AppColors.textSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isUpcoming ? 'Upcoming' : 'Past',
                            style: AppTextStyles.caption(
                              color: isUpcoming ? AppColors.success : AppColors.textSecondary,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isAdmin)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Session'),
                                  content: const Text('Are you sure you want to delete this session?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () {
                                        provider.deleteSession(session.id);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(session.title, style: AppTextStyles.titleMedium()),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy • hh:mm a').format(session.sessionDate),
                      style: AppTextStyles.bodyMedium(color: AppColors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(session.description, style: AppTextStyles.bodyMedium()),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isUpcoming || isAdmin ? () => _launchUrl(context, session.meetingLink) : null,
                        icon: const Icon(Icons.videocam, color: Colors.white),
                        label: const Text('Join Meeting', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUpcoming ? AppColors.primary : Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

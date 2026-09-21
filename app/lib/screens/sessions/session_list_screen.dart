import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/virtual_session_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'session_details_screen.dart';

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

  void _showVerificationDialog(
    BuildContext context,
    dynamic session,
    String uid,
    String name,
    VirtualSessionProvider provider,
  ) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 4-digit code provided during the meeting.'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '0000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim() == session.secretCode) {
                await provider.markAttendance(session.id, uid, name);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Attendance Verified!')),
                  );
                }
              } else {
                ScaffoldMessenger.of(
                  ctx,
                ).showSnackBar(const SnackBar(content: Text('Invalid code')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Verify', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
          return EmptyStateWidget(
            icon: Icons.videocam_off,
            title: 'No Virtual Sessions',
            subtitle: 'There are no virtual sessions scheduled at the moment.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.sessions.length,
          itemBuilder: (context, index) {
            final session = provider.sessions[index];
            final isUpcoming = session.isUpcoming;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final hasRsvpd = session.rsvpUsers.containsKey(user!.uid);

            return Card(
              margin: const EdgeInsets.only(bottom: 24),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              color: isDark ? AppColors.darkCardBg : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (session.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: session.imageUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Center(
                        child: Icon(
                          Icons.videocam,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isUpcoming
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.1,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isUpcoming ? 'Upcoming' : 'Past',
                                style: AppTextStyles.caption(
                                  color: isUpcoming
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isAdmin)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Session'),
                                      content: const Text(
                                        'Are you sure you want to delete this session?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            provider.deleteSession(session.id);
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          session.title,
                          style: AppTextStyles.titleMedium().copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat(
                                'EEEE, MMM d, yyyy • hh:mm a',
                              ).format(session.sessionDate),
                              style: AppTextStyles.bodyMedium(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          session.description,
                          style: AppTextStyles.bodyMedium(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${session.rsvpUsers.length} Volunteers RSVP'd",
                          style: AppTextStyles.caption(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Admin Actions
                        if (isAdmin)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SessionDetailsScreen(session: session),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.analytics,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'View Details & Participants',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          )
                        // Volunteer Actions
                        else ...[
                          if (!hasRsvpd)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: isUpcoming
                                    ? () async {
                                        await provider.toggleRSVP(
                                          session.id,
                                          user.uid,
                                          user.name,
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.event_available),
                                label: const Text('RSVP Now'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  foregroundColor: AppColors.primary,
                                ),
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton(
                                    onPressed: isUpcoming
                                        ? () async {
                                            await provider.toggleRSVP(
                                              session.id,
                                              user.uid,
                                              user.name,
                                            );
                                          }
                                        : null,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: const BorderSide(
                                        color: AppColors.error,
                                      ),
                                      foregroundColor: AppColors.error,
                                    ),
                                    child: const Text('Cancel RSVP'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: session.secretCode != null
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: isUpcoming
                                                  ? () {
                                                      _launchUrl(
                                                        context,
                                                        session.meetingLink,
                                                      );
                                                    }
                                                  : null,
                                              icon: const Icon(
                                                Icons.videocam,
                                                color: Colors.white,
                                              ),
                                              label: const Text(
                                                'Join Meeting',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            if (!session.attendedUsers
                                                .containsKey(user.uid))
                                              OutlinedButton.icon(
                                                onPressed: () {
                                                  _showVerificationDialog(
                                                    context,
                                                    session,
                                                    user.uid,
                                                    user.name,
                                                    provider,
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.verified,
                                                ),
                                                label: const Text(
                                                  'Verify Attendance',
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.success,
                                                  side: const BorderSide(
                                                    color: AppColors.success,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                              )
                                            else
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.success
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: AppColors.success,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Verified',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.success,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        )
                                      : ElevatedButton.icon(
                                          onPressed: isUpcoming
                                              ? () async {
                                                  // Smart Join: Mark attendance, then launch meeting
                                                  await provider.markAttendance(
                                                    session.id,
                                                    user.uid,
                                                    user.name,
                                                  );
                                                  if (context.mounted)
                                                    _launchUrl(
                                                      context,
                                                      session.meetingLink,
                                                    );
                                                }
                                              : null,
                                          icon: const Icon(
                                            Icons.videocam,
                                            color: Colors.white,
                                          ),
                                          label: const Text(
                                            'Join Meeting',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

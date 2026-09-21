import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../models/announcement_model.dart';
import '../../../../services/announcement_service.dart';
import '../../announcements/announcement_list_screen.dart';

class HomeLatestAnnouncements extends StatelessWidget {
  const HomeLatestAnnouncements({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('latest_updates'.tr(), style: AppTextStyles.titleLarge()),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnnouncementListScreen(),
                  ),
                );
              },
              child: Text('see_all'.tr()),
            ),
          ],
        ),
        AppSpacing.vGapSm,
        StreamBuilder<List<AnnouncementModel>>(
          stream: AnnouncementService().getLatestAnnouncements(2),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final announcements = snapshot.data ?? [];
            if (announcements.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              children: announcements.map((a) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: AppColors.warning.withValues(alpha: 0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.campaign,
                      color: AppColors.warning,
                    ),
                    title: Text(
                      a.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      a.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      DateFormat('MMM dd').format(a.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnnouncementListScreen(),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../announcements/announcement_list_screen.dart';
import 'session_list_screen.dart';
import '../../config/app_colors.dart';

class EngagementTabScreen extends StatelessWidget {
  const EngagementTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(icon: const Icon(Icons.announcement), text: 'announcements'.tr()),
                Tab(icon: const Icon(Icons.videocam), text: 'virtual_sessions'.tr()),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                AnnouncementListScreen(),
                SessionListScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

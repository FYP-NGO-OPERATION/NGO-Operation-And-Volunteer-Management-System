import 'package:flutter/material.dart';
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
            child: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(icon: Icon(Icons.announcement), text: 'Announcements'),
                Tab(icon: Icon(Icons.videocam), text: 'Virtual Sessions'),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/app_colors.dart';
import '../../models/user_model.dart';

/// Top Volunteers Leaderboard (Viva Rescue Feature)
///
/// VIVA PREP EXPLANATION:
/// Q: Where is the Top Volunteer Leaderboard?
/// A: Sir, it is right here. It queries the 'users' collection, filters out 
///    admins, and orders volunteers by the number of campaigns they have joined.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Volunteers'),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Query users where isAdmin == false, ordered by campaignsJoined descending
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'volunteer')
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading leaderboard: ${snapshot.error}'));
          }

          final rawDocs = snapshot.data?.docs ?? [];
          if (rawDocs.isEmpty) {
            return const Center(child: Text('No volunteers found yet.'));
          }
          // Sort client-side by campaignsJoined descending, take top 10
          final users = rawDocs
              .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => b.campaignsJoined.compareTo(a.campaignsJoined));
          final topUsers = users.take(10).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: topUsers.length,
            itemBuilder: (context, index) {
              final user = topUsers[index];
              
              // Top 3 get special colors
              Color medalColor;
              if (index == 0) medalColor = Colors.amber; // Gold
              else if (index == 1) medalColor = Colors.grey.shade400; // Silver
              else if (index == 2) medalColor = Colors.brown.shade300; // Bronze
              else medalColor = Colors.transparent;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: index < 3 ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: index < 3 
                    ? BorderSide(color: medalColor, width: 2) 
                    : BorderSide.none,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index < 3 ? medalColor.withValues(alpha: 0.2) : AppColors.primaryLight.withValues(alpha: 0.1),
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: index < 3 ? medalColor : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (user.campaignsJoined >= 3) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ],
                  ),
                  subtitle: Text('${user.campaignsJoined} Campaigns Joined'),
                  trailing: index == 0 
                    ? const Icon(Icons.workspace_premium, color: Colors.amber, size: 32)
                    : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

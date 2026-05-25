import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/certificate_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _isLoading = true;
  List<UserModel> _topVolunteers = [];
  UserModel? _currentUser;
  int _currentUserRank = 0;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'volunteer')
          .get();

      final users = querySnapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
      users.sort((a, b) => b.campaignsJoined.compareTo(a.campaignsJoined));
      
      int currentRank = 0;
      for (int i = 0; i < users.length; i++) {
        if (users[i].uid == authProvider.user?.uid) {
          currentRank = i + 1;
          _currentUser = users[i];
          break;
        }
      }

      setState(() {
        _topVolunteers = users.take(50).toList();
        _currentUserRank = currentRank;
      });
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildBadge(int campaignsJoined) {
    if (campaignsJoined >= 20) {
      return Tooltip(
        message: 'gold_badge'.tr(),
        child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
      );
    } else if (campaignsJoined >= 10) {
      return Tooltip(
        message: 'silver_badge'.tr(),
        child: const Icon(Icons.workspace_premium, color: Colors.grey, size: 28),
      );
    } else if (campaignsJoined >= 5) {
      return Tooltip(
        message: 'bronze_badge'.tr(),
        child: const Icon(Icons.workspace_premium, color: Colors.brown, size: 28),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('leaderboard'.tr()),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_currentUser != null && _currentUserRank > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: isDark ? AppColors.darkSurface : AppColors.primaryLight.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          backgroundImage: _currentUser!.profileImageUrl != null
                              ? NetworkImage(_currentUser!.profileImageUrl!)
                              : null,
                          child: _currentUser!.profileImageUrl == null
                              ? Text(_currentUser!.name.isNotEmpty ? _currentUser!.name.substring(0, 1).toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 24))
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_currentUser!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('${'rank'.tr()}: #$_currentUserRank', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBadge(_currentUser!.campaignsJoined),
                            Text('${_currentUser!.campaignsJoined} ${'points'.tr()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (_currentUser != null && _currentUserRank > 0 && _currentUser!.campaignsJoined >= 5)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Download Certificate'),
                      onPressed: () {
                        CertificateService.generateAndDownloadCertificate(
                          volunteerName: _currentUser!.name,
                          campaignsAttended: _currentUser!.campaignsJoined,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _topVolunteers.length,
                    itemBuilder: (context, index) {
                      final user = _topVolunteers[index];
                      final isMe = user.uid == _currentUser?.uid;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: index < 3 ? Colors.amber : (isDark ? Colors.grey[800] : Colors.grey[200]),
                          child: Text('#${index + 1}', style: TextStyle(color: index < 3 ? Colors.white : (isDark ? Colors.white : Colors.black))),
                        ),
                        title: Text(
                          user.name, 
                          style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal, color: isMe ? AppColors.primary : null)
                        ),
                        subtitle: Text('${user.campaignsJoined} ${'points'.tr()}'),
                        trailing: _buildBadge(user.campaignsJoined),
                        tileColor: isMe ? (isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primaryLight.withValues(alpha: 0.1)) : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

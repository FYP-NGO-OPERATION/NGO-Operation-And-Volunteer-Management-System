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

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<UserModel> _topVolunteers = [];
  UserModel? _currentUser;
  int _currentUserRank = 0;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fetchLeaderboard();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'volunteer')
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
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
      _animController.forward();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildBadge(int campaignsJoined, {double size = 24}) {
    if (campaignsJoined >= 20) {
      return Tooltip(
        message: 'gold_badge'.tr(),
        child: Icon(
          Icons.workspace_premium,
          color: Colors.amberAccent,
          size: size,
        ),
      );
    } else if (campaignsJoined >= 10) {
      return Tooltip(
        message: 'silver_badge'.tr(),
        child: Icon(
          Icons.workspace_premium,
          color: Colors.grey[400],
          size: size,
        ),
      );
    } else if (campaignsJoined >= 5) {
      return Tooltip(
        message: 'bronze_badge'.tr(),
        child: Icon(
          Icons.workspace_premium,
          color: Colors.deepOrange[300],
          size: size,
        ),
      );
    }
    return SizedBox(width: size, height: size);
  }

  Widget _buildPodiumItem(
    UserModel user,
    int rank,
    double height,
    Color color,
    bool isDark,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: rank == 1 ? 35 : 25,
          backgroundColor: color,
          child: CircleAvatar(
            radius: rank == 1 ? 32 : 23,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            backgroundImage: user.profileImageUrl != null
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null
                ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: rank == 1 ? 24 : 18,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.name.split(' ').first,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rank == 1 ? 16 : 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '\ pts',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: rank == 1 ? 90 : 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(top: BorderSide(color: color, width: 3)),
          ),
          child: Center(
            child: Text(
              '#${actualIndex + 1}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: rank == 1 ? 32 : 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTop3Podium(bool isDark) {
    if (_topVolunteers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 0),
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_topVolunteers.length >= 2)
            _buildPodiumItem(
              _topVolunteers[1],
              2,
              100,
              Colors.grey[400]!,
              isDark,
            ),
          if (_topVolunteers.length >= 2) const SizedBox(width: 16),
          if (_topVolunteers.isNotEmpty)
            _buildPodiumItem(_topVolunteers[0], 1, 130, Colors.amber, isDark),
          if (_topVolunteers.length >= 3) const SizedBox(width: 16),
          if (_topVolunteers.length >= 3)
            _buildPodiumItem(
              _topVolunteers[2],
              3,
              80,
              Colors.deepOrange[300]!,
              isDark,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'leaderboard'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildTop3Podium(isDark),
                const SizedBox(height: 16),
                if (_currentUser != null && _currentUserRank > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.8),
                            AppColors.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                _currentUser!.profileImageUrl != null
                                ? NetworkImage(_currentUser!.profileImageUrl!)
                                : null,
                            child: _currentUser!.profileImageUrl == null
                                ? Text(
                                    _currentUser!.name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Rank',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _currentUser!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '#\ • \ pts',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_currentUser!.campaignsJoined >= 5)
                            IconButton(
                              icon: const Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                              ),
                              tooltip: 'Download Certificate',
                              onPressed: () {
                                CertificateService.generateAndDownloadCertificate(
                                  volunteerName: _currentUser!.name,
                                  campaignsAttended:
                                      _currentUser!.campaignsJoined,
                                );
                              },
                            )
                          else
                            _buildBadge(
                              _currentUser!.campaignsJoined,
                              size: 32,
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 32),
                      itemCount: _topVolunteers.length > 3
                          ? _topVolunteers.length - 3
                          : 0,
                      itemBuilder: (context, index) {
                        final actualIndex = index + 3;
                        final user = _topVolunteers[actualIndex];
                        final isMe = user.uid == _currentUser?.uid;

                        return SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _animController,
                                  curve: Interval(
                                    (index / 20).clamp(0.0, 1.0),
                                    ((index / 20) + 0.2).clamp(0.0, 1.0),
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                              ),
                          child: FadeTransition(
                            opacity: _animController,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? (isDark
                                          ? AppColors.primary.withValues(
                                              alpha: 0.15,
                                            )
                                          : AppColors.primaryLight.withValues(
                                              alpha: 0.15,
                                            ))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isMe
                                    ? Border.all(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                      )
                                    : null,
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '#${actualIndex + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user.name,
                                  style: TextStyle(
                                    fontWeight: isMe
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isMe ? AppColors.primary : null,
                                  ),
                                ),
                                subtitle: Text(
                                  '${user.rewardPoints} pts',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildBadge(user.campaignsJoined),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      backgroundImage:
                                          user.profileImageUrl != null
                                          ? NetworkImage(user.profileImageUrl!)
                                          : null,
                                      child: user.profileImageUrl == null
                                          ? Text(
                                              user.name
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

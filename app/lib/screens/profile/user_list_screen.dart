import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../utils/responsive.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/web/premium_data_table.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();
  String _searchQuery = '';

  void _showRoleDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Role for ${user.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Admin'),
                leading: Icon(
                  user.role == 'admin' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                onTap: () {
                  _userService.changeUserRole(user.uid, 'admin');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Volunteer'),
                leading: Icon(
                  user.role == 'volunteer' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                onTap: () {
                  _userService.changeUserRole(user.uid, 'volunteer');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }

  void _toggleUserActive(UserModel user) async {
    final action = user.isActive ? 'Deactivate' : 'Activate';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action User'),
        content: Text('Are you sure you want to ${action.toLowerCase()} ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? AppColors.error : AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userService.setUserActive(user.uid, !user.isActive);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      // Only show AppBar on mobile (desktop has WebShell top bar)
      appBar: Responsive.isMobile(context)
          ? AppBar(
              title: const Text('User Management'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  ),
                ),
              ),
            )
          : null,
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getAllUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }

          var users = snapshot.data ?? [];
          // Mobile filter (desktop uses PremiumDataTable built-in search)
          if (!isDesktop && _searchQuery.isNotEmpty) {
            users = users.where((u) => u.name.toLowerCase().contains(_searchQuery)).toList();
          }

          if (users.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.person_off,
              title: 'No Users Found',
              subtitle: 'Try a different search query or there are no registered users.',
            );
          }

          // ─── DESKTOP: Premium Data Table ───
          if (isDesktop) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: PremiumDataTable<UserModel>(
                data: users,
                title: 'User Management',
                searchHint: 'Search users...',
                searchFilter: (user, query) =>
                    user.name.toLowerCase().contains(query.toLowerCase()) ||
                    user.email.toLowerCase().contains(query.toLowerCase()),
                columns: [
                  PremiumColumn<UserModel>(
                    header: 'USER',
                    flex: 3,
                    builder: (user) => Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: user.isAdmin ? AppColors.primarySurface : AppColors.info.withValues(alpha: 0.1),
                          child: Text(user.name[0].toUpperCase(),
                            style: AppTextStyles.labelSmall(color: user.isAdmin ? AppColors.primary : AppColors.info)),
                        ),
                        AppSpacing.hGapMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(user.name, style: AppTextStyles.bodyMedium()),
                              Text(user.email, style: AppTextStyles.caption(
                                color: AppColors.lightTextSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PremiumColumn<UserModel>(
                    header: 'ROLE',
                    flex: 1,
                    builder: (user) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.isAdmin ? AppColors.primary.withValues(alpha: 0.1) : AppColors.info.withValues(alpha: 0.1),
                        borderRadius: AppTokens.borderRadiusPill,
                      ),
                      child: Text(user.isAdmin ? '👑 Admin' : '🤝 Volunteer',
                        style: AppTextStyles.labelSmall(color: user.isAdmin ? AppColors.primary : AppColors.info)),
                    ),
                  ),
                  PremiumColumn<UserModel>(
                    header: 'STATUS',
                    flex: 1,
                    builder: (user) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: user.isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: AppTokens.borderRadiusPill,
                      ),
                      child: Text(user.isActive ? 'Active' : 'Inactive',
                        style: AppTextStyles.labelSmall(color: user.isActive ? AppColors.success : AppColors.error)),
                    ),
                  ),
                  PremiumColumn<UserModel>(
                    header: 'ACTIONS',
                    flex: 1,
                    builder: (user) => Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.manage_accounts, size: 18),
                          tooltip: 'Change Role',
                          onPressed: () => _showRoleDialog(user),
                          iconSize: 18,
                        ),
                        IconButton(
                          icon: Icon(user.isActive ? Icons.block : Icons.check_circle, size: 18,
                            color: user.isActive ? AppColors.error : AppColors.success),
                          tooltip: user.isActive ? 'Deactivate' : 'Activate',
                          onPressed: () => _toggleUserActive(user),
                          iconSize: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // ─── MOBILE: Original list view ───
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isAdmin ? AppColors.primarySurface : AppColors.info.withValues(alpha: 0.1),
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: TextStyle(
                        color: user.isAdmin ? AppColors.primary : AppColors.info,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (!user.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('INACTIVE', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    '\${user.email}\nRole: \${user.isAdmin ? "Admin 👑" : "Volunteer 🤝"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'role') {
                        _showRoleDialog(user);
                      } else if (val == 'status') {
                        _toggleUserActive(user);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'role',
                        child: Row(
                          children: [
                            Icon(Icons.manage_accounts, size: 20),
                            SizedBox(width: 8),
                            Text('Change Role'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'status',
                        child: Row(
                          children: [
                            Icon(
                              user.isActive ? Icons.block : Icons.check_circle,
                              size: 20,
                              color: user.isActive ? AppColors.error : AppColors.success,
                            ),
                            SizedBox(width: 8),
                            Text(user.isActive ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

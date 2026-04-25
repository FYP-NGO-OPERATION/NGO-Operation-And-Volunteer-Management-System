import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../models/volunteer_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/volunteer_service.dart';
import '../../enums/app_enums.dart';
import '../../utils/snackbar_helper.dart';

/// Volunteer list for a specific campaign — shows all registered volunteers.
/// Admin can mark attendance from here.
class VolunteerListScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const VolunteerListScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  State<VolunteerListScreen> createState() => _VolunteerListScreenState();
}

class _VolunteerListScreenState extends State<VolunteerListScreen> {
  final VolunteerService _volunteerService = VolunteerService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isAdmin = user?.isAdmin == true;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteers — ${widget.campaignTitle}'),
      ),
      body: StreamBuilder<List<VolunteerModel>>(
        stream: _volunteerService.getVolunteersStream(widget.campaignId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allVolunteers = snapshot.data ?? [];

          // Apply search filter
          final volunteers = _searchQuery.isEmpty
              ? allVolunteers
              : allVolunteers
                  .where((v) =>
                      v.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      v.userEmail.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          return Column(
            children: [
              // ─── Attendance Stats Bar ───
              _buildStatsBar(allVolunteers, theme),

              // ─── Search ───
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search volunteers...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),

              // ─── Volunteer List ───
              Expanded(
                child: volunteers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: volunteers.length,
                        itemBuilder: (context, index) {
                          return _buildVolunteerTile(
                            volunteers[index],
                            index + 1,
                            isAdmin,
                            theme,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Stats bar at top — Registered / Confirmed / Attended / Absent
  Widget _buildStatsBar(List<VolunteerModel> volunteers, ThemeData theme) {
    int registered = volunteers.where((v) => v.isRegistered).length;
    int confirmed = volunteers.where((v) => v.isConfirmed).length;
    int attended = volunteers.where((v) => v.hasAttended).length;
    int absent = volunteers.where((v) => v.isAbsent).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppTokens.borderRadiusMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBadge('Total', '${volunteers.length}', AppColors.primary),
          _statBadge('Registered', '$registered', AppColors.info),
          _statBadge('Confirmed', '$confirmed', AppColors.warning),
          _statBadge('Attended', '$attended', AppColors.success),
          _statBadge('Absent', '$absent', AppColors.error),
        ],
      ),
    );
  }

  Widget _statBadge(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: AppTextStyles.titleMedium(color: color)),
        AppSpacing.vGapXs,
        Text(label, style: AppTextStyles.labelSmall(
          color: color.withValues(alpha: 0.8))),
      ],
    );
  }

  /// Individual volunteer card
  Widget _buildVolunteerTile(
      VolunteerModel volunteer, int index, bool isAdmin, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(volunteer.status).withValues(alpha: 0.15),
          child: Text(
            volunteer.userName[0].toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _statusColor(volunteer.status),
            ),
          ),
        ),
        title: Text(
          volunteer.userName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              volunteer.userEmail,
              style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 2),
            Text(
              'Joined: ${DateFormat('MMM dd, yyyy').format(volunteer.registeredAt)}',
              style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
            ),
          ],
        ),
        trailing: isAdmin
            ? _buildAttendanceDropdown(volunteer)
            : _buildStatusChip(volunteer.status),
        isThreeLine: true,
      ),
    );
  }

  /// Status chip for non-admin view
  Widget _buildStatusChip(VolunteerStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor(status).withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _statusColor(status),
        ),
      ),
    );
  }

  /// Admin attendance dropdown — tap to change status
  Widget _buildAttendanceDropdown(VolunteerModel volunteer) {
    return PopupMenuButton<VolunteerStatus>(
      onSelected: (newStatus) async {
        try {
          await _volunteerService.markAttendance(volunteer.id, newStatus);
          if (mounted) {
            SnackbarHelper.showSuccess(
              context,
              '${volunteer.userName} marked as ${newStatus.label}',
            );
          }
        } catch (e) {
          if (mounted) {
            SnackbarHelper.showError(context, 'Failed: $e');
          }
        }
      },
      itemBuilder: (_) => VolunteerStatus.values.map((status) {
        final isSelected = volunteer.status == status;
        return PopupMenuItem(
          value: status,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                size: 18,
                color: _statusColor(status),
              ),
              const SizedBox(width: 8),
              Text(
                status.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: _statusColor(status),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _statusColor(volunteer.status).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _statusColor(volunteer.status).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              volunteer.status.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _statusColor(volunteer.status),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: _statusColor(volunteer.status)),
          ],
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 70, color: AppColors.lightTextHint),
          AppSpacing.vGapMd,
          Text('No Volunteers Yet', style: AppTextStyles.titleLarge()),
          AppSpacing.vGapSm,
          Text('No one has joined this campaign yet.',
            style: AppTextStyles.bodyMedium(color: AppColors.lightTextSecondary)),
        ],
      ),
    );
  }

  /// Status → Color mapping
  Color _statusColor(VolunteerStatus status) {
    switch (status) {
      case VolunteerStatus.registered:
        return AppColors.info;
      case VolunteerStatus.confirmed:
        return AppColors.warning;
      case VolunteerStatus.attended:
        return AppColors.success;
      case VolunteerStatus.absent:
        return AppColors.error;
    }
  }
}

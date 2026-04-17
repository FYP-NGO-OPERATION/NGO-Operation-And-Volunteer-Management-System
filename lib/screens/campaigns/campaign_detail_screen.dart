import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/campaign_model.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../services/campaign_service.dart';
import '../../enums/app_enums.dart';
import '../../utils/responsive.dart';
import '../../utils/snackbar_helper.dart';
import 'create_campaign_screen.dart';

/// Campaign Detail — Tabbed view (Info | Record | Highlights)
/// As per NGO leader: "Click project → Record + Highlights"
class CampaignDetailScreen extends StatefulWidget {
  final CampaignModel campaign;

  const CampaignDetailScreen({super.key, required this.campaign});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CampaignModel _campaign;

  @override
  void initState() {
    super.initState();
    _campaign = widget.campaign;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isAdmin = user?.isAdmin == true;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_campaign.title, overflow: TextOverflow.ellipsis),
        actions: [
          if (isAdmin)
            PopupMenuButton<String>(
              onSelected: (action) => _handleAction(action),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('✏️ Edit Campaign')),
                const PopupMenuItem(value: 'status', child: Text('🔄 Change Status')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('🗑️ Delete', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Info'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Record'),
            Tab(icon: Icon(Icons.photo_library), text: 'Highlights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(theme),
          _buildRecordTab(theme, isAdmin),
          _buildHighlightsTab(theme),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // TAB 1: INFO
  // ═══════════════════════════════════════════
  Widget _buildInfoTab(ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Type badges
              Row(
                children: [
                  _chip('${_campaign.type.icon} ${_campaign.type.label}', AppColors.primary),
                  const SizedBox(width: 8),
                  _statusBadge(),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                _campaign.title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Description
              Text(_campaign.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),

              // Info Grid
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoRow(Icons.calendar_today, 'Start Date', dateFormat.format(_campaign.startDate)),
                      if (_campaign.endDate != null)
                        _infoRow(Icons.event, 'End Date', dateFormat.format(_campaign.endDate!)),
                      _infoRow(Icons.location_on, 'Location', _campaign.location),
                      _infoRow(Icons.flag, 'Target', _campaign.targetGoal),
                      if (_campaign.achievedGoal != null)
                        _infoRow(Icons.check_circle, 'Achieved', _campaign.achievedGoal!),
                      if (_campaign.itemsNeeded != null)
                        _infoRow(Icons.list, 'Items Needed', _campaign.itemsNeeded!),
                      _infoRow(Icons.person, 'Created By', _campaign.createdByName),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress
              if (_campaign.progressPercent > 0) ...[
                Text('Progress', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _campaign.progressPercent / 100,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    color: AppColors.primary,
                    minHeight: 12,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${_campaign.progressPercent}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Stats Cards
              Text('Statistics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  _statCard('Volunteers', '${_campaign.totalVolunteers}', Icons.people, AppColors.info),
                  _statCard('Donations', 'Rs.${_campaign.totalDonationsAmount.toStringAsFixed(0)}', Icons.volunteer_activism, AppColors.warning),
                  _statCard('Expenses', 'Rs.${_campaign.totalExpenses.toStringAsFixed(0)}', Icons.receipt, AppColors.error),
                  _statCard('Remaining', 'Rs.${_campaign.remainingBudget.toStringAsFixed(0)}', Icons.savings, AppColors.success),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // TAB 2: RECORD (Donations + Expenses)
  // ═══════════════════════════════════════════
  Widget _buildRecordTab(ThemeData theme, bool isAdmin) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            child: TabBar(
              labelColor: AppColors.primary,
              tabs: const [
                Tab(text: '💰 Donations'),
                Tab(text: '🧾 Expenses'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDonationsSubTab(theme, isAdmin),
                _buildExpensesSubTab(theme, isAdmin),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsSubTab(ThemeData theme, bool isAdmin) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.volunteer_activism, size: 60, color: AppColors.lightTextHint),
          const SizedBox(height: 12),
          const Text('Donations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Donation tracking coming in Phase 5', style: TextStyle(color: AppColors.lightTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildExpensesSubTab(ThemeData theme, bool isAdmin) {
    return StreamBuilder<List<ExpenseModel>>(
      stream: CampaignService().getExpensesStream(_campaign.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = snapshot.data ?? [];

        if (expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 60, color: AppColors.lightTextHint),
                const SizedBox(height: 12),
                const Text('No Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  isAdmin ? 'Add expenses to track purchases.' : 'No expenses recorded yet.',
                  style: const TextStyle(color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          );
        }

        double total = expenses.fold(0, (sum, e) => sum + e.totalAmount);

        return Column(
          children: [
            // Total banner
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Expenses', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    'Rs. ${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.error),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: expenses.length,
                itemBuilder: (_, i) {
                  final e = expenses[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(e.category.icon, style: const TextStyle(fontSize: 20)),
                      ),
                      title: Text(e.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${e.quantity} × Rs.${e.unitPrice.toStringAsFixed(0)}'),
                      trailing: Text(
                        'Rs.${e.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // TAB 3: HIGHLIGHTS (Photos/Videos)
  // ═══════════════════════════════════════════
  Widget _buildHighlightsTab(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 60, color: AppColors.lightTextHint),
          const SizedBox(height: 12),
          const Text('Highlights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Photos & videos coming in Phase 8', style: TextStyle(color: AppColors.lightTextSecondary)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════
  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusBadge() {
    Color color;
    switch (_campaign.status) {
      case CampaignStatus.active:
        color = AppColors.success;
        break;
      case CampaignStatus.completed:
        color = AppColors.info;
        break;
      case CampaignStatus.upcoming:
        color = AppColors.warning;
        break;
    }
    return _chip('${_campaign.status.icon} ${_campaign.status.label}', color);
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLight),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════
  void _handleAction(String action) async {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateCampaignScreen(campaign: _campaign),
          ),
        );
        break;

      case 'status':
        _showStatusDialog();
        break;

      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CampaignStatus.values.map((status) {
            return RadioListTile<CampaignStatus>(
              title: Text('${status.icon} ${status.label}'),
              value: status,
              groupValue: _campaign.status,
              onChanged: (v) async {
                Navigator.pop(ctx);
                if (v != null) {
                  final provider = Provider.of<CampaignProvider>(context, listen: false);
                  final success = await provider.updateStatus(_campaign.id, v);
                  if (mounted && success) {
                    setState(() {
                      _campaign = _campaign.copyWith(status: v);
                    });
                    SnackbarHelper.showSuccess(context, 'Status updated to ${v.label}');
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: Text('Are you sure you want to delete "${_campaign.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final provider = Provider.of<CampaignProvider>(context, listen: false);
      final success = await provider.deleteCampaign(_campaign.id);
      if (mounted && success) {
        SnackbarHelper.showSuccess(context, 'Campaign deleted.');
        Navigator.pop(context);
      }
    }
  }
}

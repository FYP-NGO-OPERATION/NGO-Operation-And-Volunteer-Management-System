import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/campaign_model.dart';
import '../../models/donation_model.dart';
import '../../models/expense_model.dart';
import '../../models/volunteer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../services/campaign_service.dart';
import '../../services/donation_service.dart';
import '../../services/volunteer_service.dart';
import '../../enums/app_enums.dart';
import '../../utils/responsive.dart';
import '../../utils/snackbar_helper.dart';
import 'photo_gallery_screen.dart';
import '../donations/add_donation_screen.dart';
import '../expenses/add_expense_screen.dart';
import '../volunteers/volunteer_list_screen.dart';
import '../beneficiaries/beneficiary_list_screen.dart';
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
  final VolunteerService _volunteerService = VolunteerService();
  VolunteerModel? _myVolunteerRecord;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _campaign = widget.campaign;
    _tabController = TabController(length: 3, vsync: this);
    _checkJoinStatus();
  }

  /// Check if current user already joined this campaign
  Future<void> _checkJoinStatus() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;
    final record = await _volunteerService.getUserVolunteerRecord(
      _campaign.id,
      user.uid,
    );
    if (mounted) {
      setState(() => _myVolunteerRecord = record);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _hasJoined => _myVolunteerRecord != null;

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
      // Join / Leave Campaign button for volunteers
      floatingActionButton: (!isAdmin && !_campaign.isCompleted)
          ? FloatingActionButton.extended(
              onPressed: _isJoining
                  ? null
                  : _hasJoined
                      ? _leaveCampaign
                      : _joinCampaign,
              icon: _isJoining
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(_hasJoined ? Icons.exit_to_app : Icons.how_to_reg),
              label: Text(
                _isJoining
                    ? 'Please wait...'
                    : _hasJoined
                        ? 'Leave Campaign'
                        : _campaign.isFull
                            ? 'Campaign Full'
                            : 'Join Campaign',
              ),
              backgroundColor: _hasJoined
                  ? AppColors.error
                  : _campaign.isFull
                      ? AppColors.lightTextHint
                      : AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
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
                crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: Responsive.isMobile(context) ? 1.5 : 2.0,
                children: [
                  _statCard('Volunteers', '${_campaign.totalVolunteers}', Icons.people, AppColors.info),
                  _statCard('Beneficiaries', '${_campaign.beneficiaryCount}', Icons.family_restroom, AppColors.primary),
                  _statCard('Items Distributed', '${_campaign.distributionCount}', Icons.inventory_2, AppColors.success),
                  _statCard('Donations', 'Rs.${_campaign.totalDonationsAmount.toStringAsFixed(0)}', Icons.volunteer_activism, AppColors.warning),
                  _statCard('Expenses', 'Rs.${_campaign.totalExpenses.toStringAsFixed(0)}', Icons.receipt, AppColors.error),
                  _statCard('Remaining', 'Rs.${_campaign.remainingBudget.toStringAsFixed(0)}', Icons.savings, AppColors.success),
                ],
              ),
              const SizedBox(height: 16),

              // View Volunteers button (always visible)
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.people, color: AppColors.info),
                  ),
                  title: Text(
                    'View Volunteers (${_campaign.totalVolunteers})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('See who joined this campaign'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VolunteerListScreen(
                          campaignId: _campaign.id,
                          campaignTitle: _campaign.title,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // View Beneficiaries button (always visible)
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.handshake, color: AppColors.primary),
                  ),
                  title: const Text(
                    'View Impact & Distribution',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('See beneficiaries and distributed items'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BeneficiaryListScreen(
                          campaignId: _campaign.id,
                          campaignTitle: _campaign.title,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // View Photo Gallery button
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library, color: AppColors.success),
                  ),
                  title: const Text(
                    'Photo Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('View and add campaign photos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoGalleryScreen(campaign: _campaign),
                      ),
                    );
                  },
                ),
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
    return StreamBuilder<List<DonationModel>>(
      stream: DonationService().getDonationsStream(_campaign.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final donations = snapshot.data ?? [];

        if (donations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volunteer_activism, size: 60, color: AppColors.lightTextHint),
                const SizedBox(height: 12),
                const Text('No Donations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  isAdmin ? 'Tap + to record a donation.' : 'No donations recorded yet.',
                  style: const TextStyle(color: AppColors.lightTextSecondary),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddDonation,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Donation'),
                  ),
                ],
              ],
            ),
          );
        }

        // Calculate totals
        double totalCash = donations.fold(0, (s, d) => s + d.amountCash);
        double totalOnline = donations.fold(0, (s, d) => s + d.amountOnline);
        double totalAll = totalCash + totalOnline;

        return Column(
          children: [
            // Summary banner
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Donations', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        'Rs. ${totalAll.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('💵 Cash: Rs.${totalCash.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                      Text('💳 Online: Rs.${totalOnline.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                      Text('📦 Items: ${donations.length}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // Add button for admin
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _navigateToAddDonation,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Donation'),
                  ),
                ),
              ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: donations.length,
                itemBuilder: (_, i) {
                  final d = donations[i];
                  return Dismissible(
                    key: Key(d.id),
                    direction: isAdmin ? DismissDirection.endToStart : DismissDirection.none,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppColors.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Donation'),
                          content: Text('Delete donation from ${d.donorName}?'),
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
                    },
                    onDismissed: (_) async {
                      await DonationService().deleteDonation(d);
                      if (mounted) SnackbarHelper.showInfo(context, 'Donation deleted');
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(d.category.icon, style: const TextStyle(fontSize: 20)),
                        ),
                        title: Text(isAdmin ? d.donorName : 'Anonymous Donor', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${d.category.label} • ${d.quantity}', style: const TextStyle(fontSize: 12)),
                            if (d.isMoney)
                              Text(
                                '${d.paymentMethod.icon} ${d.paymentMethod.label} • Rs.${d.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.success),
                              ),
                          ],
                        ),
                        trailing: d.isMoney
                            ? Text(
                                'Rs.${d.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                              )
                            : Text(d.quantity, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                        isThreeLine: d.isMoney,
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
                  isAdmin ? 'Tap + to record an expense.' : 'No expenses recorded yet.',
                  style: const TextStyle(color: AppColors.lightTextSecondary),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddExpense,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
                ],
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

            // Add button for admin
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _navigateToAddExpense,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
                ),
              ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: expenses.length,
                itemBuilder: (_, i) {
                  final e = expenses[i];
                  return Dismissible(
                    key: Key(e.id),
                    direction: isAdmin ? DismissDirection.endToStart : DismissDirection.none,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppColors.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Expense'),
                          content: Text('Delete expense "${e.itemName}"?'),
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
                    },
                    onDismissed: (_) async {
                      await CampaignService().deleteExpense(e.id, _campaign.id, e.totalAmount);
                      if (mounted) SnackbarHelper.showInfo(context, 'Expense deleted');
                    },
                    child: Card(
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
          const Text('No media uploaded yet', style: TextStyle(color: AppColors.lightTextSecondary)),
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
  // DONATION NAVIGATION
  // ═══════════════════════════════════════════
  void _navigateToAddDonation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDonationScreen(
          campaignId: _campaign.id,
          campaignTitle: _campaign.title,
        ),
      ),
    );
  }

  void _navigateToAddExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          campaignId: _campaign.id,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // VOLUNTEER JOIN / LEAVE
  // ═══════════════════════════════════════════

  Future<void> _joinCampaign() async {
    if (_campaign.isFull) {
      SnackbarHelper.showWarning(context, 'This campaign is full.');
      return;
    }
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _isJoining = true);
    try {
      final record = await _volunteerService.joinCampaign(
        campaignId: _campaign.id,
        campaignTitle: _campaign.title,
        userId: user.uid,
        userName: user.name,
        userEmail: user.email,
        userPhone: user.phone,
      );
      if (mounted) {
        setState(() {
          _myVolunteerRecord = record;
          _isJoining = false;
        });
        SnackbarHelper.showSuccess(context, 'You joined ${_campaign.title}! 🎉');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        SnackbarHelper.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _leaveCampaign() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Campaign'),
        content: Text('Are you sure you want to leave "${_campaign.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null || _myVolunteerRecord == null) return;

    setState(() => _isJoining = true);
    try {
      await _volunteerService.leaveCampaign(
        volunteerId: _myVolunteerRecord!.id,
        campaignId: _campaign.id,
        userId: user.uid,
      );
      if (mounted) {
        setState(() {
          _myVolunteerRecord = null;
          _isJoining = false;
        });
        SnackbarHelper.showInfo(context, 'You left the campaign.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        SnackbarHelper.showError(context, 'Failed: $e');
      }
    }
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
            final isSelected = _campaign.status == status;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: AppColors.primary,
              ),
              title: Text('${status.icon} ${status.label}'),
              onTap: () async {
                Navigator.pop(ctx);
                final provider = Provider.of<CampaignProvider>(context, listen: false);
                final success = await provider.updateStatus(_campaign.id, status);
                if (mounted && success) {
                  setState(() {
                    _campaign = _campaign.copyWith(status: status);
                  });
                  SnackbarHelper.showSuccess(context, 'Status updated to ${status.label}');
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

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/app_colors.dart';
import '../../../../models/campaign_model.dart';
import '../../../../models/donation_model.dart';
import '../../../../models/expense_model.dart';
import '../../../../enums/app_enums.dart';
import '../../../../services/campaign_service.dart';
import '../../../../services/donation_service.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../donations/add_donation_screen.dart';
import '../../expenses/add_expense_screen.dart';

class CampaignRecordTab extends StatelessWidget {
  final CampaignModel campaign;
  final bool isAdmin;

  const CampaignRecordTab({
    super.key,
    required this.campaign,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            child: TabBar(
              labelColor: AppColors.primary,
              tabs: [
                Tab(text: '💰 ${'donations'.tr()}'),
                Tab(text: '🧾 ${'expenses'.tr()}'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDonationsSubTab(context, theme),
                _buildExpensesSubTab(context, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsSubTab(BuildContext context, ThemeData theme) {
    return StreamBuilder<List<DonationModel>>(
      stream: DonationService().getDonationsStream(campaign.id),
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
                Icon(
                  Icons.volunteer_activism,
                  size: 60,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkTextHint
                      : AppColors.lightTextHint,
                ),
                const SizedBox(height: 12),
                Text(
                  'no_donations'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'no_donations_desc'.tr(),
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _navigateToAddDonation(context),
                  icon: const Icon(Icons.add),
                  label: Text(
                    isAdmin ? 'add_donation'.tr() : 'donate_now'.tr(),
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate totals (only for approved donations)
        double totalCash = donations
            .where((d) => d.status == DonationStatus.approved)
            .fold(0, (s, d) => s + d.amountCash);
        double totalOnline = donations
            .where((d) => d.status == DonationStatus.approved)
            .fold(0, (s, d) => s + d.amountOnline);
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
                      Text(
                        'total_donations'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Rs. ${totalAll.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '💵 ${'cash'.tr()}: Rs.${totalCash.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '💳 ${'online'.tr()}: Rs.${totalOnline.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '📦 ${'items'.tr()}: ${donations.length}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add button for everyone
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToAddDonation(context),
                  icon: const Icon(Icons.add),
                  label: Text(
                    isAdmin ? 'add_donation'.tr() : 'donate_now'.tr(),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: donations.length,
                itemBuilder: (_, i) {
                  final d = donations[i];
                  return Dismissible(
                    key: Key(d.id),
                    direction: isAdmin
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsetsDirectional.only(end: 20),
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
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) async {
                      final messenger = ScaffoldMessenger.of(context);
                      await DonationService().deleteDonation(d);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Donation deleted')),
                      );
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
                          child: Text(
                            d.category.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                (!isAdmin && d.isAnonymous)
                                    ? 'anonymous_volunteer'.tr()
                                    : (isAdmin && d.isAnonymous)
                                    ? '${d.donorName} (${'anonymous_volunteer'.tr()})'
                                    : d.donorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (d.status == DonationStatus.pending)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'pending'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${d.category.label} • ${d.quantity}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (d.isMoney)
                              Text(
                                '${d.paymentMethod.icon} ${d.paymentMethod.label} • Rs.${d.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                ),
                              ),
                            if (isAdmin && d.status == DonationStatus.pending)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: () async {
                                        await DonationService()
                                            .updateDonationStatus(
                                              d,
                                              DonationStatus.approved,
                                            );
                                        if (context.mounted) {
                                          SnackbarHelper.showSuccess(
                                            context,
                                            'Donation Approved',
                                          );
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.success,
                                        side: const BorderSide(
                                          color: AppColors.success,
                                        ),
                                        minimumSize: const Size(0, 30),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                      ),
                                      child: const Text('Approve'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () async {
                                        await DonationService()
                                            .updateDonationStatus(
                                              d,
                                              DonationStatus.rejected,
                                            );
                                        if (context.mounted) {
                                          SnackbarHelper.showError(
                                            context,
                                            'Donation Rejected',
                                          );
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(
                                          color: AppColors.error,
                                        ),
                                        minimumSize: const Size(0, 30),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        trailing: d.isMoney
                            ? Text(
                                'Rs.${d.totalAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: d.status == DonationStatus.pending
                                      ? AppColors.warning
                                      : AppColors.success,
                                ),
                              )
                            : Text(
                                d.quantity,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                        isThreeLine: true,
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

  Widget _buildExpensesSubTab(BuildContext context, ThemeData theme) {
    return StreamBuilder<List<ExpenseModel>>(
      stream: CampaignService().getExpensesStream(campaign.id),
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
                Icon(
                  Icons.receipt_long,
                  size: 60,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkTextHint
                      : AppColors.lightTextHint,
                ),
                const SizedBox(height: 12),
                Text(
                  'no_expenses'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : null,
                  ),
                ),
                Text(
                  isAdmin
                      ? 'Tap + to record an expense.'
                      : 'Tap + to request a reimbursement.',
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _navigateToAddExpense(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense / Reimbursement'),
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
                  Text(
                    'total_expenses'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Rs. ${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),

            // Budget vs Expense Pie Chart
            if (total > 0)
              Container(
                height: 180,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              color: AppColors.error,
                              value: total,
                              title: 'Exp.',
                              radius: 40,
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: AppColors.success,
                              value:
                                  (double.tryParse(
                                                campaign.targetGoal.replaceAll(
                                                  RegExp(r'[^0-9.]'),
                                                  '',
                                                ),
                                              ) ??
                                              0) -
                                          total >
                                      0
                                  ? (double.tryParse(
                                              campaign.targetGoal.replaceAll(
                                                RegExp(r'[^0-9.]'),
                                                '',
                                              ),
                                            ) ??
                                            0) -
                                        total
                                  : 0,
                              title: 'Rem.',
                              radius: 40,
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'budget_utilization'.tr(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildLegendItem(
                            AppColors.error,
                            'expenses_used'.tr(),
                          ),
                          const SizedBox(height: 4),
                          _buildLegendItem(
                            AppColors.success,
                            'remaining_budget'.tr(),
                          ),
                        ],
                      ),
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
                    onPressed: () => _navigateToAddExpense(context),
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
                    direction: isAdmin
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsetsDirectional.only(end: 20),
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
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) async {
                      final messenger = ScaffoldMessenger.of(context);
                      await CampaignService().deleteExpense(
                        e.id,
                        campaign.id,
                        e.totalAmount,
                      );
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Expense deleted')),
                      );
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
                          child: Text(
                            e.category.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Text(
                          e.itemName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.quantity} × Rs.${e.unitPrice.toStringAsFixed(0)}',
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '• By ${e.addedByName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (e.status == 'pending')
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 8.0,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withOpacity(
                                          0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Pending',
                                        style: TextStyle(
                                          color: AppColors.warning,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Text(
                          'Rs.${e.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
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

  void _navigateToAddDonation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDonationScreen(
          campaignId: campaign.id,
          campaignTitle: campaign.title,
        ),
      ),
    );
  }

  void _navigateToAddExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(campaignId: campaign.id),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}

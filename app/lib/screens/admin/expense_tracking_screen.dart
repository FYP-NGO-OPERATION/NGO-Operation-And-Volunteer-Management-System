import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/campaign_model.dart';
import '../../models/expense_model.dart';
import '../../services/campaign_service.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../expenses/add_expense_screen.dart';

class ExpenseTrackingScreen extends StatelessWidget {
  final CampaignModel campaign;

  const ExpenseTrackingScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final campaignService = CampaignService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expense Tracking'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Approved'),
              Tab(text: 'Pending Approvals'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSummaryCard(),
            Expanded(
              child: StreamBuilder<List<ExpenseModel>>(
                stream: campaignService.getExpensesStream(campaign.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No expenses recorded yet.'),
                    );
                  }

                  final approved = snapshot.data!
                      .where((e) => e.status == 'approved')
                      .toList();
                  final pending = snapshot.data!
                      .where((e) => e.status == 'pending')
                      .toList();

                  return TabBarView(
                    children: [
                      _buildExpenseList(approved, false, campaignService),
                      _buildExpenseList(pending, true, campaignService),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddExpenseScreen(campaignId: campaign.id),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildExpenseList(
    List<ExpenseModel> expenses,
    bool isPending,
    CampaignService service,
  ) {
    if (expenses.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'No pending requests.' : 'No approved expenses.',
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(expense.category.icon),
            ),
            title: Text(
              expense.itemName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${DateFormat('MMM dd, yyyy').format(expense.createdAt)}\nBy: ${expense.addedByName}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPending)
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                    ),
                    onPressed: () {
                      final service =
                          CampaignService(); // In real app, create update method
                      // For FYP, we simulate update by deleting and re-adding, or updating via a new updateExpense method
                      // assuming updateExpense exists, we will call it.
                      FirebaseFirestore.instance
                          .collection('campaigns')
                          .doc(campaign.id)
                          .collection('expenses')
                          .doc(expense.id)
                          .update({'status': 'approved'});
                    },
                  ),
                if (isPending)
                  IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.error),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('campaigns')
                          .doc(campaign.id)
                          .collection('expenses')
                          .doc(expense.id)
                          .update({'status': 'rejected'});
                    },
                  ),
                if (!isPending)
                  Text(
                    'Rs. ${NumberFormat('#,##0').format(expense.totalAmount)}',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: AppColors.primarySurface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem(
                'Total Raised',
                campaign.totalDonationsAmount,
                AppColors.success,
              ),
              _summaryItem(
                'Total Spent',
                campaign.totalExpenses,
                AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: AppTextStyles.labelMedium(color: AppColors.primary)),
        const SizedBox(height: 8),
        Text(
          'Rs. ${NumberFormat('#,##0').format(amount)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

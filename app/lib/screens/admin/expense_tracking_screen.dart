import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracking'),
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<ExpenseModel>>(
              stream: campaignService.getExpensesStream(campaign.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No expenses recorded yet.'));
                }

                final expenses = snapshot.data!;
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
                        title: Text(expense.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${DateFormat('MMM dd, yyyy').format(expense.createdAt)}\nBy: ${expense.addedByName}',
                        ),
                        trailing: Text(
                          'Rs. ${NumberFormat('#,##0').format(expense.totalAmount)}',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
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
              _summaryItem('Total Raised', campaign.totalDonationsAmount, AppColors.success),
              _summaryItem('Total Spent', campaign.totalExpenses, AppColors.error),
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

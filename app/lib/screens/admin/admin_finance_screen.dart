import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'manage_tracking_events_screen.dart';
import '../../services/fund_allocation_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../models/expense_model.dart';
import '../../models/campaign_model.dart';
import '../../enums/app_enums.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/common/infinite_firestore_list.dart';

class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});

  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final campaigns = Provider.of<CampaignProvider>(context).campaigns;

    double totalDonations = 0;
    double totalExpenses = 0;

    for (var c in campaigns) {
      totalDonations += c.totalDonationsAmount;
      totalExpenses += c.totalExpenses;
    }

    final balance = totalDonations - totalExpenses;

    return Scaffold(
      appBar: AppBar(title: const Text('NGO Finance Ledger')),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(totalDonations, totalExpenses, balance),
            AppSpacing.vGapXl,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Expenses', style: AppTextStyles.titleLarge()),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageTrackingEventsScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.settings),
                      label: const Text('Manage Tracker'),
                    ),
                    AppSpacing.hGapSm,
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showAddExpenseDialog(context, campaigns),
                      icon: const Icon(Icons.add),
                      label: const Text('Log Expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AppSpacing.vGapMd,
            _buildExpensesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double donations, double expenses, double balance) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            'Total Incoming',
            _currencyFormat.format(donations),
            Colors.green.shade100,
            Colors.green.shade800,
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: _buildCard(
            'Total Expenses',
            _currencyFormat.format(expenses),
            Colors.red.shade100,
            Colors.red.shade800,
          ),
        ),
        AppSpacing.hGapMd,
        Expanded(
          child: _buildCard(
            'Net Balance',
            _currencyFormat.format(balance),
            Colors.blue.shade100,
            Colors.blue.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    String title,
    String amount,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    return InfiniteFirestoreList<ExpenseModel>(
      query: FirebaseFirestore.instance
          .collection('expenses')
          .orderBy('createdAt', descending: true),
      limit: 20,
      itemBuilder: (doc) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return ExpenseModel.fromMap(data);
      },
      builder: (context, expenses, hasMore, isLoading, fetchNext) {
        if (expenses.isEmpty) {
          return const Text('No expenses logged yet.');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.money_off, color: Colors.white),
                ),
                title: Text(
                  expense.itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Qty: ${expense.quantity} | Campaign ID: ${expense.campaignId.substring(0, 5)}...',
                ),
                trailing: Text(
                  _currencyFormat.format(expense.totalAmount),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddExpenseDialog(
    BuildContext context,
    List<CampaignModel> campaigns,
  ) {
    if (campaigns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a campaign first to log expenses against it.'),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final itemCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();
    String selectedCampaignId = campaigns.first.id;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log New Expense'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCampaignId,
                decoration: const InputDecoration(labelText: 'Select Campaign'),
                items: campaigns
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.title)),
                    )
                    .toList(),
                onChanged: (v) => selectedCampaignId = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: itemCtrl,
                decoration: const InputDecoration(
                  labelText: 'Item Name (e.g. 50 Tents)',
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: qtyCtrl,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: priceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Unit Price',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final qty = int.parse(qtyCtrl.text);
                final price = double.parse(priceCtrl.text);
                final total = qty * price;

                final user = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).user!;

                final docRef = FirebaseFirestore.instance
                    .collection('expenses')
                    .doc();
                final expense = ExpenseModel(
                  id: docRef.id,
                  campaignId: selectedCampaignId,
                  itemName: itemCtrl.text,
                  category: ExpenseCategory.other,
                  quantity: qty,
                  unitPrice: price,
                  totalAmount: total,
                  addedBy: user.uid,
                  addedByName: user.name,
                  createdAt: DateTime.now(),
                );

                await docRef.set(expense.toMap());

                await FirebaseFirestore.instance
                    .collection('campaigns')
                    .doc(selectedCampaignId)
                    .update({'totalExpenses': FieldValue.increment(total)});

                // Allocate funds via UTXO logic
                final allocationService = FundAllocationService();
                await allocationService.allocateExpense(
                  campaignId: selectedCampaignId,
                  expenseTotal: total,
                  expenseName: itemCtrl.text,
                );

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense Logged Successfully!')),
                );
              }
            },
            child: const Text('Save Expense'),
          ),
        ],
      ),
    );
  }
}

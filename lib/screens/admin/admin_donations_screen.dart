import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/donation_model.dart';
import '../../config/app_colors.dart';
import '../../utils/responsive.dart';

class AdminDonationsScreen extends StatefulWidget {
  const AdminDonationsScreen({super.key});

  @override
  State<AdminDonationsScreen> createState() => _AdminDonationsScreenState();
}

class _AdminDonationsScreenState extends State<AdminDonationsScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'en_PK', symbol: 'Rs. ', decimalDigits: 0);
  final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Responsive.isMobile(context)
          ? AppBar(title: const Text('All Donations'))
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!Responsive.isMobile(context)) ...[
              Text(
                'Donation Reports',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
              ),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('donations')
                    .orderBy('receivedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No donations recorded yet.'),
                    );
                  }

                  if (!Responsive.isMobile(context)) {
                    // Web View: Table
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.primary.withOpacity(0.1)),
                            columns: const [
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Donor Name')),
                              DataColumn(label: Text('Campaign')),
                              DataColumn(label: Text('Amount / Qty')),
                              DataColumn(label: Text('Method')),
                              DataColumn(label: Text('Collected By')),
                            ],
                            rows: docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              data['id'] = doc.id;
                              final donation = DonationModel.fromMap(data);
                              return DataRow(cells: [
                                DataCell(Text(_dateFormat.format(donation.receivedAt))),
                                DataCell(Text(donation.donorName)),
                                DataCell(Text(donation.campaignTitle)),
                                DataCell(Text(
                                  donation.isMoney
                                      ? _currencyFormat.format(donation.amount)
                                      : donation.quantity,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataCell(Chip(
                                  label: Text(donation.isMoney ? donation.paymentMethod.name.toUpperCase() : 'IN-KIND'),
                                  backgroundColor: donation.isMoney ? AppColors.accent.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                )),
                                DataCell(Text(donation.receivedByName)),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  }

                  // Mobile View: ListView
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      data['id'] = docs[index].id;
                      final donation = DonationModel.fromMap(data);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: donation.isMoney ? AppColors.accent : Colors.grey,
                          child: Icon(
                            donation.isMoney ? Icons.attach_money : Icons.inventory,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(donation.donorName),
                        subtitle: Text('${donation.campaignTitle}\n${_dateFormat.format(donation.receivedAt)}'),
                        trailing: Text(
                          donation.isMoney ? _currencyFormat.format(donation.amount) : donation.quantity,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        isThreeLine: true,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

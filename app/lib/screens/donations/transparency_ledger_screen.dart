import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../models/donation_model.dart';
import '../../models/expense_model.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class LedgerEntry {
  final String id;
  final String type; // 'DONATION' or 'EXPENSE'
  final double amount;
  final DateTime date;
  final String description;
  final String personName;

  LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.personName,
  });

  String get generatedHash {
    final rawString =
        '$id$type$amount${date.toIso8601String()}$description$personName';
    final bytes = utf8.encode(rawString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

class TransparencyLedgerScreen extends StatelessWidget {
  final String campaignId;

  const TransparencyLedgerScreen({super.key, required this.campaignId});

  Future<List<LedgerEntry>> _fetchLedger() async {
    final db = FirebaseFirestore.instance;
    final List<LedgerEntry> entries = [];

    // Fetch Donations
    final donationDocs = await db
        .collection('campaigns')
        .doc(campaignId)
        .collection('donations')
        .where('status', isEqualTo: 'approved')
        .get();
    for (var doc in donationDocs.docs) {
      final d = DonationModel.fromMap(doc.data());
      if (d.isMoney) {
        entries.add(
          LedgerEntry(
            id: d.id,
            type: 'DONATION',
            amount: d.totalAmount,
            date: d.createdAt,
            description: d.isAnonymous ? 'Anonymous Donation' : 'Donation',
            personName: d.isAnonymous ? 'Anonymous' : d.donorName,
          ),
        );
      }
    }

    // Fetch Expenses
    final expenseDocs = await db
        .collection('campaigns')
        .doc(campaignId)
        .collection('expenses')
        .where('status', isEqualTo: 'approved')
        .get();
    for (var doc in expenseDocs.docs) {
      final e = ExpenseModel.fromMap(doc.data());
      entries.add(
        LedgerEntry(
          id: e.id,
          type: 'EXPENSE',
          amount: e.totalAmount,
          date: e.createdAt,
          description: e.itemName,
          personName: e.addedByName,
        ),
      );
    }

    // Sort descending by date
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D1117)
          : const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.link, color: Colors.blueAccent),
            const SizedBox(width: 8),
            const Text(
              'Blockchain Ledger',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<List<LedgerEntry>>(
        future: _fetchLedger(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No verified blocks found.',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            );
          }

          final entries = snapshot.data!;
          final totalBlocks = entries.length;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isDonation = entry.type == 'DONATION';
              final blockHeight = totalBlocks - index;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B22) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.widgets,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Block #$blockHeight',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDonation
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isDonation ? Colors.green : Colors.red,
                                ),
                              ),
                              child: Text(
                                entry.type,
                                style: TextStyle(
                                  color: isDonation ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '${isDonation ? '+' : '-'} Rs.${NumberFormat('#,##0').format(entry.amount)}',
                              style: TextStyle(
                                color: isDonation ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Signer: ${entry.personName}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0D1117)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hash: ${entry.generatedHash}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(entry.date)}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index != entries.length - 1)
                    Container(
                      height: 20,
                      width: 2,
                      color: Colors.blueAccent.withOpacity(0.5),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

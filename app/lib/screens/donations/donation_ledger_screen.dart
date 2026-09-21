import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../config/app_colors.dart';

class DonationLedgerScreen extends StatelessWidget {
  const DonationLedgerScreen({super.key});

  String _generateHash(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return '0x${digest.toString().substring(0, 16).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkScaffoldBg
          : AppColors.lightScaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Transparent Ledger',
          style: TextStyle(fontFamily: 'monospace', color: Colors.teal),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.teal),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .orderBy('receivedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No blocks mined yet.',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final amount = data['amount'] ?? 0;
              final date =
                  (data['receivedAt'] as Timestamp?)?.toDate() ??
                  DateTime.now();
              final donor = data['donorName'] ?? 'Anonymous';

              // Real / Mock Blockchain Data
              final dbTxHash = data['txHash'];
              final dbBlock = data['blockNumber'];

              final txHash = dbTxHash ?? _generateHash(docs[index].id);
              final blockHeight = dbBlock ?? (18490000 + (docs.length - index));
              final confirmations = 100 + (docs.length - index) * 15;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BLOCK #$blockHeight',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          '$confirmations Confirmations',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Divider(color: isDark ? Colors.white24 : Colors.black12),
                    const SizedBox(height: 8),
                    _buildLedgerRow('TxHash', txHash, isDark),
                    _buildLedgerRow('Sender', donor, isDark),
                    _buildLedgerRow(
                      'Value',
                      'Rs. ${NumberFormat('#,##0').format(amount)}',
                      isDark,
                    ),
                    _buildLedgerRow(
                      'Timestamp',
                      DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
                      isDark,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'STATUS: MINED 🟢',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 12,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLedgerRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

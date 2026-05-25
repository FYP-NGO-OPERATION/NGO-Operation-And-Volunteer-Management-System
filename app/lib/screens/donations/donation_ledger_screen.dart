import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

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
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.blueGrey.shade900,
      appBar: AppBar(
        title: const Text('Transparent Ledger', style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').orderBy('receivedAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No blocks mined yet.', style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final amount = data['amount'] ?? 0;
              final date = (data['receivedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              final donor = data['donorName'] ?? 'Anonymous';
              
              // Mock Blockchain Data
              final txHash = _generateHash(docs[index].id);
              final blockHeight = 18490000 + (docs.length - index);
              final confirmations = 100 + (docs.length - index) * 15;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('BLOCK #$blockHeight', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        Text('$confirmations Confirmations', style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    _buildLedgerRow('TxHash', txHash),
                    _buildLedgerRow('Sender', donor),
                    _buildLedgerRow('Value', 'Rs. ${NumberFormat('#,##0').format(amount)}'),
                    _buildLedgerRow('Timestamp', DateFormat('yyyy-MM-dd HH:mm:ss').format(date)),
                    const SizedBox(height: 12),
                    const Text('STATUS: MINED 🟢', style: TextStyle(color: Colors.green, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLedgerRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace'))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'))),
        ],
      ),
    );
  }
}

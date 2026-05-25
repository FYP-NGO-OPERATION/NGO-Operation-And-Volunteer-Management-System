import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SmartContractScreen extends StatelessWidget {
  final String contractAddress;
  final String amountCrypto;

  const SmartContractScreen({
    super.key,
    this.contractAddress = '0x8f2a...39C1',
    this.amountCrypto = '0.015 ETH',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use a hacker/crypto style terminal vibe
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.blueGrey.shade900,
      appBar: AppBar(
        title: const Text('Web3 Explorer', style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.currency_bitcoin, color: Colors.orangeAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              'DECENTRALIZED DONATION CONTRACT',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, letterSpacing: 2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildInfoRow('Contract Address', contractAddress),
            _buildInfoRow('Network', 'Ethereum Mainnet'),
            _buildInfoRow('Amount Transferred', amountCrypto),
            _buildInfoRow('Gas Fee', '0.00012 ETH (\$0.45)'),
            _buildInfoRow('Block Height', '18493021'),
            _buildInfoRow('Confirmations', '142 Confirmations', color: Colors.greenAccent),
            _buildInfoRow('Timestamp', 'Oct 14, 2023 14:32:00 UTC'),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RAW SMART CONTRACT LOGS', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text(
                    '> Executing transfer()...\n'
                    '> Validating sender signature: [OK]\n'
                    '> Updating NGO escrow balance: [OK]\n'
                    '> Emitting DonationReceived event...\n'
                    '> Transaction mined in block 18493021.\n'
                    '> STATUS: SUCCESS 🟢',
                    style: TextStyle(fontFamily: 'monospace', color: Colors.green, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: TextStyle(fontFamily: 'monospace', color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

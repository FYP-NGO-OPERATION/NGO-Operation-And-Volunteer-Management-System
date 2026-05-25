import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'dart:math';

class InventoryScannerScreen extends StatefulWidget {
  final String campaignId;

  const InventoryScannerScreen({super.key, required this.campaignId});

  @override
  State<InventoryScannerScreen> createState() => _InventoryScannerScreenState();
}

class _InventoryScannerScreenState extends State<InventoryScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate finding a barcode after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        _animationController.stop();
        _showScannedItemDialog();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showScannedItemDialog() {
    final randomItem = ['Water Bottles Pack', 'First Aid Kit', 'Ration Bag', 'Tents (4-person)'][Random().nextInt(4)];
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Barcode Scanned!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 60),
              const SizedBox(height: 16),
              Text('Detected Item:', style: AppTextStyles.bodyMedium()),
              Text(randomItem, style: AppTextStyles.titleMedium(color: AppColors.primary)),
              const SizedBox(height: 16),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                Navigator.pop(context); // go back
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                final qty = int.tryParse(quantityController.text) ?? 1;
                final user = context.read<AuthProvider>().user;
                
                await FirebaseFirestore.instance.collection('campaigns').doc(widget.campaignId).collection('inventory').add({
                  'itemName': randomItem,
                  'quantity': qty,
                  'scannedBy': user?.name ?? 'Volunteer',
                  'timestamp': FieldValue.serverTimestamp(),
                  'barcode': '100${Random().nextInt(99999)}',
                });
                
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$qty x $randomItem added to inventory!')));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add to Inventory'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR/Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Simulated camera view
          Container(
            color: Colors.black87,
            child: Center(
              child: Icon(Icons.camera_alt, color: Colors.white.withOpacity(0.2), size: 100),
            ),
          ),
          
          // Scanner Box
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // Scanning Line
          if (_isScanning)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned(
                  top: 150 + (_animationController.value * 230),
                  child: Container(
                    width: 230,
                    height: 2,
                    color: Colors.redAccent,
                    boxShadow: [
                      BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)
                    ],
                  ),
                );
              },
            ),
            
          // Instructions
          Positioned(
            bottom: 100,
            child: Text(
              _isScanning ? 'Align barcode within the frame' : 'Processing...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

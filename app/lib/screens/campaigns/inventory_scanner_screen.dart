import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class InventoryScannerScreen extends StatefulWidget {
  final String campaignId;

  const InventoryScannerScreen({super.key, required this.campaignId});

  @override
  State<InventoryScannerScreen> createState() => _InventoryScannerScreenState();
}

class _InventoryScannerScreenState extends State<InventoryScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first.rawValue;
      if (barcode != null) {
        setState(() {
          _isScanning = false;
        });
        _scannerController.stop();
        _animationController.stop();
        _showScannedItemDialog(barcode);
      }
    }
  }

  void _showScannedItemDialog(String scannedCode) {
    final quantityController = TextEditingController(text: '1');
    final nameController = TextEditingController(text: 'Item_$scannedCode');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Barcode Scanned!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Scanned Code: $scannedCode',
                style: AppTextStyles.bodyMedium(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
              ),
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
                // Resume scanning
                setState(() => _isScanning = true);
                _scannerController.start();
                _animationController.repeat(reverse: true);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final qty = int.tryParse(quantityController.text) ?? 1;
                final itemName = nameController.text.trim();
                final user = context.read<AuthProvider>().user;

                await FirebaseFirestore.instance
                    .collection('campaigns')
                    .doc(widget.campaignId)
                    .collection('inventory')
                    .add({
                      'itemName': itemName,
                      'quantity': qty,
                      'scannedBy': user?.name ?? 'Volunteer',
                      'timestamp': FieldValue.serverTimestamp(),
                      'barcode': scannedCode,
                    });

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$qty x $itemName added!')),
                  );
                  Navigator.pop(context); // Go back to previous screen
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
          // Real Camera View
          Container(
            color: Colors.black,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
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
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
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
          ),
        ],
      ),
    );
  }
}

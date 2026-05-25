import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/ngo_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ngo_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/virtual_session_provider.dart';
import '../../services/ngo_service.dart';

import '../home/home_screen.dart';
import 'create_ngo_screen.dart';

class NgoSelectionScreen extends StatefulWidget {
  const NgoSelectionScreen({super.key});

  @override
  State<NgoSelectionScreen> createState() => _NgoSelectionScreenState();
}

class _NgoSelectionScreenState extends State<NgoSelectionScreen> {
  final NgoService _ngoService = NgoService();

  Future<void> _selectNgo(NgoModel ngo) async {
    if (ngo.status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This NGO is pending admin approval.')),
      );
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final ngoProvider = Provider.of<NgoProvider>(context, listen: false);
    final success = await ngoProvider.selectNgo(user, ngo);

    if (success && mounted) {
      Provider.of<CampaignProvider>(context, listen: false).init(ngo.id);
      Provider.of<VirtualSessionProvider>(context, listen: false).init(ngo.id);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore NGOs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            tooltip: 'Register New NGO',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateNgoScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NgoModel>>(
        stream: _ngoService.streamAllNgos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = Provider.of<AuthProvider>(context, listen: false).user;
          final allNgos = snapshot.data ?? [];
          
          // Only show approved NGOs OR NGOs created by the current user
          final ngos = allNgos.where((ngo) => 
            ngo.status == 'approved' || 
            (user != null && ngo.adminId == user.uid)
          ).toList();
          
          if (ngos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No NGOs registered yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateNgoScreen()),
                      );
                    },
                    child: const Text('Register the First NGO'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: ngos.length,
            itemBuilder: (context, index) {
              final ngo = ngos[index];
              return _buildNgoCard(ngo);
            },
          );
        },
      ),
    );
  }

  Widget _buildNgoCard(NgoModel ngo) {
    Color primaryColor = _parseColor(ngo.primaryColorHex);

    return InkWell(
      onTap: () => _selectNgo(ngo),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ngo.logoUrl != null && ngo.logoUrl!.isNotEmpty
                  ? ClipOval(
                      child: ngo.logoUrl!.startsWith('data:image')
                          ? Image.memory(
                              base64Decode(ngo.logoUrl!.split(',').last),
                              fit: BoxFit.cover,
                            )
                          : Image.network(ngo.logoUrl!, fit: BoxFit.cover),
                    )
                  : Icon(Icons.business, color: primaryColor, size: 30),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ngo.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: ngo.status == 'pending' ? Colors.grey : primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ngo.status == 'pending' ? 'Pending Approval' : 'Enter', 
                style: const TextStyle(color: Colors.white, fontSize: 12)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.tryParse(hex, radix: 16) ?? 0xFF1A6B3C);
  }
}

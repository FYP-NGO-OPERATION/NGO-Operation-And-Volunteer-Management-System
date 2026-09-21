import 'package:flutter/material.dart';
import '../../models/ngo_model.dart';
import '../../services/ngo_service.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ManageNgosScreen extends StatefulWidget {
  const ManageNgosScreen({super.key});

  @override
  State<ManageNgosScreen> createState() => _ManageNgosScreenState();
}

class _ManageNgosScreenState extends State<ManageNgosScreen> {
  final NgoService _ngoService = NgoService();

  Future<void> _approveNgo(NgoModel ngo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve NGO'),
        content: Text(
          'Are you sure you want to approve "${ngo.name}"? They will gain access to their workspace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _ngoService.updateNgo(ngo.id, {'status': 'approved'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NGO Approved successfully.')),
        );
      }
    }
  }

  Future<void> _rejectNgo(NgoModel ngo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject NGO'),
        content: Text('Are you sure you want to reject "${ngo.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _ngoService.updateNgo(ngo.id, {'status': 'rejected'});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('NGO Rejected.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage NGOs')),
      body: StreamBuilder<List<NgoModel>>(
        stream: _ngoService.streamAllNgos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ngos = snapshot.data ?? [];
          final pendingNgos = ngos.where((n) => n.status == 'pending').toList();
          final approvedNgos = ngos
              .where((n) => n.status == 'approved')
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Pending Approvals (${pendingNgos.length})',
                style: AppTextStyles.titleLarge(),
              ),
              const SizedBox(height: 8),
              if (pendingNgos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No pending NGOs.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ...pendingNgos.map((ngo) => _buildNgoTile(ngo)),

              const SizedBox(height: 32),
              Text(
                'Approved NGOs (${approvedNgos.length})',
                style: AppTextStyles.titleLarge(),
              ),
              const SizedBox(height: 8),
              if (approvedNgos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No approved NGOs yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ...approvedNgos.map((ngo) => _buildNgoTile(ngo)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNgoTile(NgoModel ngo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
          child: const Icon(Icons.business),
        ),
        title: Text(
          ngo.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          ngo.status.toUpperCase(),
          style: TextStyle(
            color: ngo.status == 'pending' ? Colors.orange : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        trailing: ngo.status == 'pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _rejectNgo(ngo),
                    tooltip: 'Reject',
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _approveNgo(ngo),
                    tooltip: 'Approve',
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

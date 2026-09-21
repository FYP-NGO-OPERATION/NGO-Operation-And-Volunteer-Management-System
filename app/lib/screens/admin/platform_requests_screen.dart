import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ngo_provider.dart';
import '../../models/ngo_model.dart';
import '../../utils/snackbar_helper.dart';

class PlatformRequestsScreen extends StatefulWidget {
  const PlatformRequestsScreen({super.key});

  @override
  State<PlatformRequestsScreen> createState() => _PlatformRequestsScreenState();
}

class _PlatformRequestsScreenState extends State<PlatformRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NgoProvider>(context, listen: false).fetchAllNgos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform Requests')),
      body: Consumer<NgoProvider>(
        builder: (context, ngoProvider, _) {
          if (ngoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingNgos = ngoProvider.ngos
              .where((n) => n.status == 'pending')
              .toList();

          if (pendingNgos.isEmpty) {
            return const Center(child: Text('No pending NGO requests.'));
          }

          return ListView.builder(
            itemCount: pendingNgos.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final ngo = pendingNgos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ngo.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ngo.description,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Requested Features:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8,
                        children: ngo.features
                            .map((f) => Chip(label: Text(f)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await ngoProvider.updateNgoStatus(
                                ngo.id,
                                'rejected',
                              );
                              if (context.mounted)
                                SnackbarHelper.showError(
                                  context,
                                  'Request Rejected',
                                );
                            },
                            child: const Text(
                              'Reject',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              await ngoProvider.updateNgoStatus(
                                ngo.id,
                                'approved',
                              );
                              if (context.mounted)
                                SnackbarHelper.showSuccess(
                                  context,
                                  'NGO Approved!',
                                );
                            },
                            child: const Text('Approve'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

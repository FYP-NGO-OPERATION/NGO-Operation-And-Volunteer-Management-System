import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/beneficiary_model.dart';
import '../../models/distribution_model.dart';
import '../../services/distribution_service.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_colors.dart';
import '../../utils/snackbar_helper.dart';
import 'add_beneficiary_screen.dart';
import 'add_distribution_screen.dart';

class BeneficiaryListScreen extends StatefulWidget {
  final String campaignId;
  final String campaignTitle;

  const BeneficiaryListScreen({
    super.key,
    required this.campaignId,
    required this.campaignTitle,
  });

  @override
  State<BeneficiaryListScreen> createState() => _BeneficiaryListScreenState();
}

class _BeneficiaryListScreenState extends State<BeneficiaryListScreen> {
  final _distributionService = DistributionService();

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Impact & Reach'),
              Text(widget.campaignTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Distribution'),
              Tab(text: 'Beneficiaries'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDistributionTab(isAdmin),
            _buildBeneficiaryTab(isAdmin),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionTab(bool isAdmin) {
    return StreamBuilder<List<DistributionModel>>(
      stream: _distributionService.getDistributionsStream(widget.campaignId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final distributions = snapshot.data ?? [];

        return Column(
          children: [
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddDistributionScreen(campaignId: widget.campaignId)),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Distribution'),
                  ),
                ),
              ),

            if (distributions.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No distributions recorded yet.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: distributions.length,
                  itemBuilder: (_, i) {
                    final d = distributions[i];
                    return Dismissible(
                      key: Key(d.id),
                      direction: isAdmin ? DismissDirection.endToStart : DismissDirection.none,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: AppColors.error,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Record'),
                            content: const Text('Are you sure you want to delete this distribution record?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        await _distributionService.deleteDistribution(d.id, widget.campaignId, d.quantity);
                        if (mounted) SnackbarHelper.showInfo(context, 'Record deleted');
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.success.withValues(alpha: 0.1),
                            child: const Icon(Icons.inventory_2, color: AppColors.success),
                          ),
                          title: Text('${d.quantity} ${d.unit} of ${d.itemType.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Location: ${d.location}\nDate: ${DateFormat('dd MMM, yyyy').format(d.distributedAt)}'),
                          trailing: Text('${d.distributedTo} People', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.info)),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBeneficiaryTab(bool isAdmin) {
    return StreamBuilder<List<BeneficiaryModel>>(
      stream: _distributionService.getBeneficiariesStream(widget.campaignId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final beneficiaries = snapshot.data ?? [];

        return Column(
          children: [
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddBeneficiaryScreen(campaignId: widget.campaignId)),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Beneficiary'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, foregroundColor: Colors.white),
                  ),
                ),
              ),

            if (beneficiaries.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No beneficiaries recorded yet.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: beneficiaries.length,
                  itemBuilder: (_, i) {
                    final b = beneficiaries[i];
                    return Dismissible(
                      key: Key(b.id),
                      direction: isAdmin ? DismissDirection.endToStart : DismissDirection.none,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: AppColors.error,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Beneficiary'),
                            content: Text('Remove ${b.name}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        await _distributionService.deleteBeneficiary(b.id, widget.campaignId, b.familySize);
                        if (mounted) SnackbarHelper.showInfo(context, 'Beneficiary deleted');
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.info.withValues(alpha: 0.1),
                            child: const Icon(Icons.person, color: AppColors.info),
                          ),
                          title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Family Size: ${b.familySize}\nItems: ${b.itemsReceived}'),
                          trailing: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

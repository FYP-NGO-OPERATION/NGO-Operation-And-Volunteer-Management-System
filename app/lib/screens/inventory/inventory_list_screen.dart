import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../models/inventory_item_model.dart';
import '../../services/inventory_service.dart';
import '../../providers/ngo_provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'add_edit_inventory_screen.dart';

class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ngoProvider = Provider.of<NgoProvider>(context);
    final currentNgo = ngoProvider.currentNgo;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentNgo == null) {
      return Scaffold(
        appBar: AppBar(title: Text('inventory'.tr())),
        body: const Center(child: Text('Please select an NGO workspace first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('inventory'.tr()),
        centerTitle: true,
      ),
      body: StreamBuilder<List<InventoryItemModel>>(
        stream: InventoryService().getInventoryStream(currentNgo.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final items = snapshot.data ?? [];
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.neutral500),
                  const SizedBox(height: 16),
                  Text('no_inventory'.tr(), style: AppTextStyles.titleMedium(color: AppColors.neutral500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.inventory, color: AppColors.primary),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.description ?? ''),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.quantity}',
                        style: AppTextStyles.titleMedium(color: item.quantity > 0 ? AppColors.success : AppColors.error),
                      ),
                      Text(item.unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditInventoryScreen(item: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditInventoryScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text('add_item'.tr()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

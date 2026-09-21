import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../config/app_colors.dart';
import '../../utils/snackbar_helper.dart';

class AdminManageStoreScreen extends StatefulWidget {
  const AdminManageStoreScreen({super.key});

  @override
  State<AdminManageStoreScreen> createState() => _AdminManageStoreScreenState();
}

class _AdminManageStoreScreenState extends State<AdminManageStoreScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showProductDialog([ProductModel? product]) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name);
    final descController = TextEditingController(text: product?.description);
    final priceController = TextEditingController(
      text: product?.price.toString(),
    );
    final stockController = TextEditingController(
      text: product?.stock.toString(),
    );
    final imageController = TextEditingController(text: product?.imageUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price (\$)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final data = {
                  'name': nameController.text.trim(),
                  'description': descController.text.trim(),
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'stock': int.tryParse(stockController.text) ?? 0,
                  'imageUrl': imageController.text.trim(),
                };

                if (isEditing) {
                  await _firestore
                      .collection('products')
                      .doc(product.id)
                      .update(data);
                } else {
                  await _firestore.collection('products').add(data);
                }

                // Notify users of new product if we added a new one
                if (!isEditing) {
                  await _firestore.collection('announcements').add({
                    'title': 'New Item in Store!',
                    'description': ' is now available.',
                    'timestamp': FieldValue.serverTimestamp(),
                    'sendNotification': true, // Our trigger will catch this
                  });
                }

                if (mounted) {
                  Navigator.pop(context);
                  SnackbarHelper.showSuccess(
                    context,
                    isEditing ? 'Product updated' : 'Product added',
                  );
                }
              } catch (e) {
                SnackbarHelper.showError(context, 'Error: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('products').doc(id).delete();
      if (mounted) SnackbarHelper.showSuccess(context, 'Product deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage E-Store')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty)
            return const Center(child: Text('No products available.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final product = ProductModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: product.imageUrl.isNotEmpty
                      ? NetworkImage(product.imageUrl)
                      : null,
                  child: product.imageUrl.isEmpty
                      ? const Icon(Icons.image)
                      : null,
                ),
                title: Text(product.name),
                subtitle: Text(
                  'Stock: ${product.stock} | Price: \$${product.price}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showProductDialog(product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(product.id),
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
}

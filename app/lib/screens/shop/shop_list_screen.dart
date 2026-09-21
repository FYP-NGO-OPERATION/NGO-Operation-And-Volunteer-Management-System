import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../utils/snackbar_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../services/shop_service.dart';
// used as generic trigger, or I'll implement proper logic

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  int _cartCount = 0;
  double _cartTotal = 0.0;
  final List<ProductModel> _cartItems = [];

  void _addToCart(ProductModel product) {
    if (product.stock <= 0) {
      SnackbarHelper.showError(context, 'Out of stock!');
      return;
    }
    setState(() {
      _cartCount++;
      _cartTotal += product.price;
      _cartItems.add(product);
    });
    SnackbarHelper.showSuccess(context, ' added to cart!');
  }

  void _checkout() async {
    if (_cartCount == 0) {
      SnackbarHelper.showError(context, 'Your cart is empty.');
      return;
    }
    
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final shopService = ShopService();
      await shopService.checkout(
        user.uid,
        user.name,
        _cartItems,
        _cartTotal,
      );
      
      if (mounted) {
        Navigator.pop(context); // pop loading
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Checkout Successful'),
            content: Text('Thank you for your purchase! You bought  items for \$. Proceeds will go to the NGO.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _cartCount = 0;
                    _cartTotal = 0.0;
                    _cartItems.clear();
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading
        SnackbarHelper.showError(context, 'Checkout failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charity E-Store'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _checkout,
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.hGapSm,
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ShopService().getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final products = snapshot.data?.docs.map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList() ?? [];
          
          if (products.isEmpty) {
            return const Center(child: Text('Store is empty. Admin needs to add products.'));
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final outOfStock = product.stock <= 0;
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                          if (outOfStock)
                            Container(
                              color: Colors.black.withValues(alpha: 0.5),
                              alignment: Alignment.center,
                              child: const Text('OUT OF STOCK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: AppTextStyles.titleMedium(), maxLines: 1, overflow: TextOverflow.ellipsis),
                          AppSpacing.vGapXs,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('{product.price.toStringAsFixed(2)}', style: AppTextStyles.titleMedium(color: AppColors.primary)),
                              Text(' left', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          AppSpacing.vGapXs,
                          SizedBox(
                            width: double.infinity,
                            child: Semantics(
                              label: 'Add ${product.name} to cart for ${product.price.toStringAsFixed(2)} Rupees',
                              button: true,
                              child: ElevatedButton.icon(
                                onPressed: outOfStock ? null : () => _addToCart(product),
                                icon: const Icon(Icons.add_shopping_cart, size: 16),
                                label: const Text('Add'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

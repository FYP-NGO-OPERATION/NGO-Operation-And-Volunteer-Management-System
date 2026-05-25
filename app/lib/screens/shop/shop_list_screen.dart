import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../utils/snackbar_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShopListScreen extends StatefulWidget {
  const ShopListScreen({super.key});

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  // Mock data for FYP
  final List<ProductModel> _products = [
    ProductModel(
      id: 'p1',
      name: 'NGO Supporter T-Shirt',
      description: '100% cotton T-shirt. All proceeds go to charity.',
      price: 15.0,
      imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500',
      stock: 50,
    ),
    ProductModel(
      id: 'p2',
      name: 'Charity Mug',
      description: 'Ceramic mug with our NGO logo.',
      price: 8.5,
      imageUrl: 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=500',
      stock: 100,
    ),
    ProductModel(
      id: 'p3',
      name: 'Volunteer Cap',
      description: 'Adjustable baseball cap for outdoor campaigns.',
      price: 12.0,
      imageUrl: 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=500',
      stock: 30,
    ),
    ProductModel(
      id: 'p4',
      name: 'Eco-Friendly Tote Bag',
      description: 'Reusable bag for everyday shopping.',
      price: 5.0,
      imageUrl: 'https://images.unsplash.com/photo-1597484662317-9bd7bdda2907?w=500',
      stock: 200,
    ),
  ];

  int _cartCount = 0;

  void _addToCart(ProductModel product) {
    setState(() {
      _cartCount++;
    });
    SnackbarHelper.showSuccess(context, '${product.name} added to cart!');
  }

  void _checkout() {
    if (_cartCount == 0) {
      SnackbarHelper.showError(context, 'Your cart is empty.');
      return;
    }
    // Mock checkout flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout Successful'),
        content: Text('Thank you for your purchase! You bought $_cartCount items. Proceeds will go to the NGO.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _cartCount = 0);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTextStyles.titleMedium(), maxLines: 1, overflow: TextOverflow.ellipsis),
                      AppSpacing.vGapXs,
                      Text('\$${product.price.toStringAsFixed(2)}', style: AppTextStyles.titleMedium(color: AppColors.primary)),
                      AppSpacing.vGapXs,
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _addToCart(product),
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
      ),
    );
  }
}

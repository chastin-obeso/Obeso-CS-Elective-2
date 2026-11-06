import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/appbar.dart';

class ProductDetailView extends ConsumerWidget {
  final String productId;
  final CartModel cartModel;

  const ProductDetailView({
    super.key,
    required this.productId,
    required this.cartModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final productsAsync = ref.watch(productQueryProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Product Details',
        showBackButton: true,
        cartModel: cartModel,
      ),
      body: productsAsync.when(
        data: (products) {
          final int idInt = int.tryParse(productId) ?? 0;
          final product = products.firstWhere(
            (p) => p.id == idInt,
            orElse: () => products.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(product.imageUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 24),
                Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('₱${product.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(height: 16),
                const Text('Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(product.description, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      cartModel.addProduct(product.id.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${product.name} to cart!')),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
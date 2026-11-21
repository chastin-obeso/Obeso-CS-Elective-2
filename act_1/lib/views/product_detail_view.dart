import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/appbar.dart';

class ProductDetailView extends ConsumerWidget {
  final String productId;

  const ProductDetailView({
    super.key,
    required this.productId,
  });

  Widget _buildImage(String imageUrl, ColorScheme colorScheme) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: colorScheme.surfaceContainerHighest,
          child: const Center(child: Icon(Icons.broken_image, size: 40)),
        ),
      );
    }

    final safeAsset =
        imageUrl.startsWith('assets/') ? imageUrl : 'assets/photo1.jpg';
    return Image.asset(
      safeAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.image, size: 40)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final int idInt = int.tryParse(productId) ?? 0;
    final productAsync = ref.watch(productByIdProvider(idInt));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Product Details',
        showBackButton: true,
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildImage(product.imageUrl, colorScheme),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₱${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.isOutOfStock
                      ? 'Out of stock'
                      : 'Available stock: ${product.stock}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: product.isOutOfStock
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                if (!isAdmin) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: product.isOutOfStock
                          ? null
                          : () {
                              final res = ref
                                  .read(cartProvider)
                                  .addProduct(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    res.success
                                        ? 'Added ${product.name} to cart!'
                                        : (res.message ?? 'Unable to add'),
                                  ),
                                  backgroundColor:
                                      res.success ? null : colorScheme.error,
                                ),
                              );
                            },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        product.isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
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
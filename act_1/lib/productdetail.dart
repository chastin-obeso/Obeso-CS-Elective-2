import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/herobanner.dart';
import '/productlist.dart';
import '/appbar.dart';
import 'cartstate.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final CartModel cartModel;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.cartModel,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Fetch product details specifically for this productId
    final product = Product.getById(widget.productId);

    // Dynamic horizontal padding matching ProductList styling
    final double horizontalPadding = screenWidth < 600
        ? (screenWidth * 0.03).clamp(8.0, 16.0)
        : (screenWidth * 0.18).clamp(32.0, 300.0);

    return Scaffold(
      appBar: CustomAppBar(
        title: product.name,
        showBackButton: true,
        cartModel: widget.cartModel, // Pass cartModel to AppBar here
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 50.0,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildGallery(colorScheme, product),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 6,
                    child: _buildProductDetails(context, colorScheme, product),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGallery(colorScheme, product),
                const SizedBox(height: 24),
                _buildProductDetails(context, colorScheme, product),
              ],
            );
          },
        ),
      ),
    );
  }

  // Gallery displaying images specific to this item
  Widget _buildGallery(ColorScheme colorScheme, Product product) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.1,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Center(
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // Specific Product Metadata & Actions
  Widget _buildProductDetails(
    BuildContext context,
    ColorScheme colorScheme,
    Product product,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          product.name,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'P${product.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          product.description,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        // Add to Cart / Save Actions
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    // Use widget.cartModel to access the state property
                    widget.cartModel.addProduct(product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added ${product.name} to cart!')),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              width: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Wishlist toggle logic
                },
                child: const Icon(Icons.favorite_border, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
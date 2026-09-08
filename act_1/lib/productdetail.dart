import 'package:flutter/material.dart';
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

    final product = Product.getById(widget.productId);

    final double horizontalPadding = screenWidth < 600
        ? (screenWidth * 0.03).clamp(8.0, 16.0)
        : (screenWidth * 0.18).clamp(32.0, 300.0);

    return Scaffold(
      appBar: CustomAppBar(
        title: product.name,
        showBackButton: true,
        cartModel: widget.cartModel, 
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
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ListenableBuilder(
                  listenable: widget.cartModel,
                  builder: (context, child) {
                    final quantity = widget.cartModel.items[product.id] ?? 0;

                    if (quantity == 0) {
                      return FilledButton.icon(
                        onPressed: () {
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
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            color: colorScheme.primary,
                            onPressed: () {
                              widget.cartModel.decrementProduct(product.id);
                            },
                          ),
                          Text(
                            '$quantity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            color: colorScheme.primary,
                            onPressed: () {
                              widget.cartModel.incrementProduct(product.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
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
                onPressed: () {},
                child: const Icon(Icons.favorite_border, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
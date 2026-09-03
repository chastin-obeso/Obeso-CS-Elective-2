import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class Product {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });
}

class ProductList extends StatelessWidget {
  const ProductList({super.key});

 
  final List<Product> products = const [
    Product(id: '1', name: 'Sypik Triton 5', price: 10490.00),
    Product(id: '2', name: 'Pro Tour Pickleball Bag', price: 4500.00),
    Product(id: '3', name: 'Indoor Match Balls (3-Pack)', price: 500.00),
    Product(id: '4', name: 'Overgrip', price: 50.00),
    Product(id: '5', name: 'Joola Perseus Pro V', price: 12500.00),
    Product(id: '6', name: 'Edge Tape', price: 450.00),
    Product(id: '7', name: 'Buy 1 Take 1 Paddle with Ballz', price: 1200.00),
    Product(id: '8', name: 'Sigma Asics', price: 9500.00),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final crossAxisCount = isTablet ? 3 : 2;

    final double horizontalPadding = screenWidth < 600
        ? (screenWidth * 0.03).clamp(8.0, 16.0)
        : (screenWidth * 0.18).clamp(32.0, 300.0);

    final dynamicSpacing = (screenWidth * 0.03).clamp(10.0, 24.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12.0,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: products.length, 
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: dynamicSpacing,
          mainAxisSpacing: dynamicSpacing,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final product = products[index]; 
          return _buildProductCard(context, colorScheme, product);
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ColorScheme colorScheme,
    Product product, 
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          context.goNamed(
            'productDetail',
            pathParameters: {'id': product.id}, 
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12.0),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // Details Container
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name, 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\P${product.price.toStringAsFixed(2)}', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
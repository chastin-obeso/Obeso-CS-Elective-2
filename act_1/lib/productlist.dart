import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  static final List<Product> products = const [
    Product(id: '1', name: 'Sypik Triton 5', price: 10490.00, imageUrl: 'assets/triton.png', description: 'The Sypik Triton 5 is a high-performance pickleball paddle designed for players seeking power and control. With its advanced composite face and polymer core, it offers a perfect balance of speed and spin. The ergonomic handle ensures comfort during extended play, making it ideal for both competitive and recreational players. Elevate your game with the Sypik Triton 5 and experience unmatched precision on the court.'),
    Product(id: '2', name: 'Pro Tour Pickleball Bag', price: 4500.00, imageUrl: 'assets/bag.jpg', description: 'The Pro Tour Pickleball Bag is the ultimate companion for players on the go. With its spacious compartments, it easily accommodates multiple paddles, balls, and personal items. The durable construction ensures long-lasting use, while the padded straps provide comfort during transport. Stay organized and stylish with the Pro Tour Pickleball Bag, designed to meet the needs of both casual and competitive players alike.'),
    Product(id: '3', name: 'Indoor Match Balls (3-Pack)', price: 500.00, imageUrl: 'assets/balls.jpg', description: 'The Indoor Match Balls (3-Pack) are specifically designed for indoor pickleball play. Crafted with precision, these balls offer consistent bounce and flight characteristics, ensuring a fair and competitive game. The durable construction withstands repeated use, making them perfect for both practice sessions and official matches. Elevate your indoor pickleball experience with these high-quality match balls, providing players with the performance they need to excel on the court.'),
    Product(id: '4', name: 'Overgrip', price: 50.00, imageUrl: 'assets/overgrip.jpg', description: 'The Overgrip is an essential accessory for any pickleball player looking to enhance their grip and control. Made from high-quality materials, it provides a comfortable and secure hold on the paddle, reducing slippage during intense rallies. The overgrip is easy to apply and can be replaced as needed, ensuring optimal performance throughout your game. Improve your paddle handling and enjoy a better playing experience with this reliable overgrip.'),
    Product(id: '5', name: 'Joola Perseus Pro V', price: 12500.00, imageUrl: 'assets/perseus.jpg', description: 'The Joola Perseus Pro V is a premium pickleball paddle that offers exceptional performance and durability. With its advanced materials and innovative design, it provides players with the control and power needed to dominate the court. Whether you are a beginner or an experienced player, the Joola Perseus Pro V is the perfect choice for those who demand the best in their pickleball equipment.'),
    Product(id: '6', name: 'Edge Tape', price: 450.00, imageUrl: 'assets/edge_tape.jpg', description: 'The Edge Tape is a must-have accessory for any pickleball player looking to protect their paddle from wear and tear. Made from high-quality materials, it provides a durable and reliable solution for maintaining the integrity of your paddle. The easy-to-apply design ensures that you can quickly and easily add this protective layer to your paddle, extending its lifespan and keeping it in top condition.'),
    Product(id: '7', name: 'Buy 1 Take 1 Paddle with Ballz', price: 1200.00, imageUrl: 'assets/b1t1.jpg', description: 'Take advantage of this special offer and get a new pickleball paddle with a pack of balls included. This deal is perfect for players who want to upgrade their equipment or for those who are just starting out in the sport. With the added benefit of having a full set of balls, you can practice your skills and improve your game without having to purchase additional items separately.'),
    Product(id: '8', name: 'Sigma Asics', price: 9500.00, imageUrl: 'assets/asics.jpg', description: 'The Sigma Asics is a high-performance pickleball paddle that combines cutting-edge technology with traditional craftsmanship. Designed for serious players who demand excellence in every aspect of their game, this paddle offers superior control and power. The innovative design ensures that you can consistently hit powerful shots while maintaining complete control over your swings.'),
  ];

static Product getById(String id) {
    return products.firstWhere(
      (product) => product.id == id,
      orElse: () => Product(
        id: id,
        name: 'Item $id',
        price: 0.00,
        imageUrl: 'assets/default.jpg',
        description: 'This is a default description for the item.',
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  const ProductList({super.key});

  

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final int crossAxisCount;
    if (screenWidth >= 1024) {
      crossAxisCount = 4; // Desktop
    } else if (screenWidth >= 600) {
      crossAxisCount = 3; // Tablet
    } else {
      crossAxisCount = 2; // Phone
    }

    final double horizontalPadding = screenWidth < 600
        ? (screenWidth * 0.03).clamp(8.0, 16.0)
        : screenWidth >= 1024
            ? (screenWidth * 0.10).clamp(24.0, 150.0)
            : (screenWidth * 0.18).clamp(32.0, 300.0);

    final dynamicSpacing = (screenWidth * 0.03).clamp(10.0, 24.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 12.0,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: Product.products.length, 
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: dynamicSpacing,
          mainAxisSpacing: dynamicSpacing,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final product = Product.products[index]; 
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
                  clipBehavior: Clip.antiAlias, // Ensures the image respects the container's border radius
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
                      '₱${product.price.toStringAsFixed(2)}', 
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
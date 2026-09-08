import 'package:flutter/material.dart';
import 'cartstate.dart';
import 'productlist.dart';

class CartView extends StatelessWidget {
  final CartModel cartModel;
  final void Function(String productId)? onRemove;
  final void Function(String productId, int delta)? onQuantityChanged;

  const CartView({
    super.key,
    required this.cartModel,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder listens to changes in CartModel and rebuilds UI in real-time
    return ListenableBuilder(
      listenable: cartModel,
      builder: (context, child) {
        final entries = cartModel.items.entries
            .where((entry) => entry.value > 0)
            .toList();

        if (entries.isEmpty) {
          return const Center(
            child: Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final productId = entry.key;
            final quantity = entry.value;
            final product = Product.getById(productId);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Product Image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image(
                          image: (product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty)
                              ? AssetImage(product.imageUrl!)
                              : const AssetImage('assets/default.jpg'),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Product Title & Subtotal
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${(product.price * quantity).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quantity Controls (+ / -)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (onQuantityChanged != null) {
                              onQuantityChanged!(productId, -1);
                            } else {
                              cartModel.decrementProduct(productId);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          iconSize: 22,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            if (onQuantityChanged != null) {
                              onQuantityChanged!(productId, 1);
                            } else {
                              cartModel.incrementProduct(productId);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),

                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (onRemove != null) {
                          onRemove!(productId);
                        } else {
                          cartModel.removeItemCompletely(productId);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
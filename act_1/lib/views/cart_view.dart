import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import 'package:go_router/go_router.dart';

class CartView extends StatelessWidget {
  final CartModel cartModel;

  const CartView({super.key, required this.cartModel});

  @override
  Widget build(BuildContext context) {
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

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final productId = entry.key;
                  final quantity = entry.value;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('Product ID: $productId'),
                      subtitle: Text('Quantity: $quantity'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => cartModel.removeItemCompletely(productId),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => context.goNamed('checkout'),
                child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }
}
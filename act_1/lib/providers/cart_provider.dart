import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

class CartAddResult {
  final bool success;
  final String? message;

  const CartAddResult._(this.success, this.message);

  const CartAddResult.ok() : this._(true, null);
  const CartAddResult.error(String msg) : this._(false, msg);
}

class CartModel extends ChangeNotifier {
  final Map<int, int> _items = {};

  Map<int, int> get items => Map.unmodifiable(_items);

  int get totalCount =>
      _items.values.fold(0, (sum, qty) => sum + qty);

  double calculateTotal(List<Product> products) {
    final priceMap = {for (final p in products) p.id: p.price};
    double total = 0.0;
    _items.forEach((productId, qty) {
      final price = priceMap[productId] ?? 0.0;
      total += price * qty;
    });
    return total;
  }

  CartAddResult addProduct(Product product, {int quantity = 1}) {
    if (quantity <= 0) {
      return const CartAddResult.error('Quantity must be at least 1.');
    }
    if (product.stock <= 0) {
      return CartAddResult.error('${product.name} is out of stock.');
    }

    final currentQty = _items[product.id] ?? 0;
    final nextQty = currentQty + quantity;
    if (nextQty > product.stock) {
      return CartAddResult.error(
        'Only ${product.stock} in stock for${product.name}.',
      );
    }

    _items[product.id] = nextQty;
    notifyListeners();
    return const CartAddResult.ok();
  }

  CartAddResult updateQuantity(Product product, int newQuantity) {
    if (newQuantity <= 0) {
      removeItemCompletely(product.id);
      return const CartAddResult.ok();
    }
    if (product.stock <= 0) {
      removeItemCompletely(product.id);
      return CartAddResult.error('${product.name} is now out of stock.');
    }
    if (newQuantity > product.stock) {
      return CartAddResult.error(
        'Max available stock for ${product.name} is${product.stock}.',
      );
    }

    _items[product.id] = newQuantity;
    notifyListeners();
    return const CartAddResult.ok();
  }

  void decrementProduct(Product product) {
    final current = _items[product.id] ?? 0;
    if (current <= 1) {
      _items.remove(product.id);
      notifyListeners();
    } else {
      _items[product.id] = current - 1;
      notifyListeners();
    }
  }

  void removeItemCompletely(int productId) {
    if (_items.remove(productId) != null) {
      notifyListeners();
    }
  }

  void clearCart() {
    if (_items.isNotEmpty) {
      _items.clear();
      notifyListeners();
    }
  }

   List<Map<String, dynamic>> toRpcPayload() {
    return _items.entries
        .where((e) => e.value > 0)
        .map((e) => {'product_id': e.key, 'quantity': e.value})
        .toList();
  }
}

final cartProvider = ChangeNotifierProvider<CartModel>((ref) {
  return CartModel();
});
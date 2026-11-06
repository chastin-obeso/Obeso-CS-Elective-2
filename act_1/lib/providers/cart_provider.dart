import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final Map<String, int> _items = {};
  Map<String, int> get items => _items;
  int get totalCount => _items.values.fold(0, (sum, qty) => sum + qty);

  void addProduct(String productId, {int quantity = 1}) {
    _items[productId] = (_items[productId] ?? 0) + quantity;
    notifyListeners();
  }

  void decrementProduct(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]! > 1) {
        _items[productId] = _items[productId]! - 1;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void removeItemCompletely(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
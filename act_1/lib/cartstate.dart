import 'package:flutter/material.dart';

class CartModel extends ChangeNotifier {
  final Map<String, int> _items = {};
  Map<String, int> get items => _items;
  int get totalCount => _items.values.fold(0, (sum, qty) => sum + qty);
  int getQuantity(String productId) => _items[productId] ?? 0;

  void addProduct(String productId, {int quantity = 1}) {
    _items[productId] = (_items[productId] ?? 0) + quantity;
    notifyListeners();
  }

  void removeProduct(String productId, {int quantity = 1}) {
    if (_items.containsKey(productId)) {
      _items[productId] = _items[productId]! - quantity;
      if (_items[productId]! <= 0) {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void incrementProduct(String productId) {
    _items[productId] = (_items[productId] ?? 0) + 1;
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
import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final String price;
  final Color color;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.color,
    this.quantity = 1,
  });
}

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.fold(0.0, (sum, item) {
      final price = double.parse(item.price.replaceAll('₹', ''));
      return sum + (price * item.quantity);
    });
  }

  void addItem(String id, String name, String price, Color color) {
    final existingIndex = _items.indexWhere((item) => item.id == id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        id: id,
        name: name,
        price: price,
        color: color,
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    final existingIndex = _items.indexWhere((item) => item.id == id);
    
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

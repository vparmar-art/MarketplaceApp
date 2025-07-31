import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'quantity': quantity,
    };
  }
}

class CartService with ChangeNotifier {
  final List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get total => _items.fold(0, (sum, item) => sum + item.total);

  bool get isEmpty => _items.isEmpty;

  Future<void> loadCart(List<Product> availableProducts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart');
      
      if (cartData != null && cartData.isNotEmpty) {
        final List<dynamic> decodedData = json.decode(cartData);
        
        _items.clear();
        for (var item in decodedData) {
          final productId = item['product_id'];
          final quantity = item['quantity'];
          
          final product = availableProducts.firstWhere(
            (p) => p.id == productId,
            orElse: () => throw Exception('Product not found'),
          );
          
          _items.add(CartItem(product: product, quantity: quantity));
        }
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        
      }
    }
  }

  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _items.map((item) => item.toJson()).toList();
      await prefs.setString('cart', json.encode(data));
    } catch (e) {
      if (kDebugMode) {
        
      }
    }
  }

  void addItem(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    
    notifyListeners();
    saveCart();
  }

  void updateQuantity(Product product, int quantity) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(existingIndex);
      } else {
        _items[existingIndex].quantity = quantity;
      }
      
      notifyListeners();
      saveCart();
    }
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
    saveCart();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    saveCart();
  }

  bool containsProduct(Product product) {
    return _items.any((item) => item.product.id == product.id);
  }

  CartItem? getItem(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      return _items[index];
    }
    return null;
  }
}
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/medicine_response.dart';

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, required this.quantity});

  Map<String, dynamic> toJson() => {
    'medicine': medicine.toJson(),
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    medicine: Medicine.fromJson(json['medicine']),
    quantity: json['quantity'],
  );
}

class CartService {
  static const _storage = FlutterSecureStorage();
  static const String _cartKey = 'cart_items';

  // Singleton implementation
  CartService._privateConstructor();
  static final CartService _instance = CartService._privateConstructor();
  factory CartService() {
    return _instance;
  }
  // Get all cart items
  Future<List<CartItem>> getCartItems() async {
    try {
      final String? cartData = await _storage.read(key: _cartKey);
      if (cartData == null) return [];

      final List<dynamic> cartJson = json.decode(cartData);
      return cartJson.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      print('Error getting cart items: $e');
      return [];
    }
  }

  // Add item to cart
  Future<void> addToCart(Medicine medicine, {int quantity = 1}) async {
    try {
      List<CartItem> cartItems = await getCartItems();

      // Check if item already exists
      int existingIndex = cartItems.indexWhere(
        (item) => item.medicine.id == medicine.id,
      );

      if (existingIndex != -1) {
        // Update quantity if item exists
        cartItems[existingIndex].quantity += quantity;
      } else {
        // Add new item
        cartItems.add(CartItem(medicine: medicine, quantity: quantity));
      }

      await _saveCartItems(cartItems);
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String medicineId) async {
    try {
      List<CartItem> cartItems = await getCartItems();
      cartItems.removeWhere((item) => item.medicine.id == medicineId);
      await _saveCartItems(cartItems);
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String medicineId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(medicineId);
        return;
      }

      List<CartItem> cartItems = await getCartItems();
      int index = cartItems.indexWhere(
        (item) => item.medicine.id == medicineId,
      );

      if (index != -1) {
        cartItems[index].quantity = newQuantity;
        await _saveCartItems(cartItems);
      }
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    try {
      await _storage.delete(key: _cartKey);
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // Get cart item count
  Future<int> getCartItemCount() async {
    try {
      List<CartItem> cartItems = await getCartItems();
      return cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      print('Error getting cart count: $e');
      return 0;
    }
  }

  // Get total cart value
  Future<double> getCartTotal() async {
    try {
      List<CartItem> cartItems = await getCartItems();
      return cartItems.fold<double>(
        0.0,
        (double sum, CartItem item) =>
            sum + (item.medicine.pricing.sellingPrice * item.quantity),
      );
    } catch (e) {
      print('Error calculating cart total: $e');
      return 0.0;
    }
  }

  // Check if medicine is in cart
  Future<bool> isInCart(String medicineId) async {
    try {
      List<CartItem> cartItems = await getCartItems();
      return cartItems.any((item) => item.medicine.id == medicineId);
    } catch (e) {
      print('Error checking if in cart: $e');
      return false;
    }
  }

  // Get quantity of specific medicine in cart
  Future<int> getMedicineQuantity(String medicineId) async {
    try {
      List<CartItem> cartItems = await getCartItems();
      try {
        CartItem item = cartItems.firstWhere(
          (item) => item.medicine.id == medicineId,
        );
        return item.quantity;
      } catch (e) {
        // Item not found in cart
        return 0;
      }
    } catch (e) {
      print('Error getting medicine quantity: $e');
      return 0;
    }
  }

  // Private method to save cart items
  Future<void> _saveCartItems(List<CartItem> cartItems) async {
    try {
      final String cartJson = json.encode(
        cartItems.map((item) => item.toJson()).toList(),
      );
      await _storage.write(key: _cartKey, value: cartJson);
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }
}

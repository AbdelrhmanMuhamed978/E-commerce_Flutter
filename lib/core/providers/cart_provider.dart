import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService;

  Map<String, dynamic> _cart = {};
  bool _isLoading = false;
  String? _error;

  CartProvider(this._apiService);

  Map<String, dynamic> get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get cartItemCount {
    if (_cart['items'] == null) return 0;
    return (_cart['items'] as List).length;
  }

  double get cartTotal {
    if (_cart['items'] == null) return 0.0;

    final items = _cart['items'] as List;
    double total = 0.0;
    for (var item in items) {
      final price = (item['price'] ?? 0).toDouble();
      final quantity = item['quantity'] ?? 1;
      total += price * quantity;
    }
    return total;
  }

  Future<void> getCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getCart();

      // Parse the nested response structure: {"status":"success","data":{"data":[...]}}
      List<dynamic> cartItems = [];
      if (response.containsKey('status') &&
          response['status'] == 'success' &&
          response.containsKey('data') &&
          response['data'] is Map &&
          response['data'].containsKey('data') &&
          response['data']['data'] is List) {
        cartItems = response['data']['data'] as List;
      }

      _cart = {
        'items': cartItems,
      };

      _isLoading = false;
      _error = null; // Clear any previous errors
      notifyListeners();
    } catch (e) {
      // Only set error if it's not a "cart not found" error
      if (!e.toString().contains('Cart not found') &&
          !e.toString().contains('404')) {
        _error = e.toString();
      } else {
        // If cart not found, just set empty cart
        _cart = {
          'items': [],
        };
        _error = null;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.addToCart(productId, quantity);

      // Parse the nested response structure: {"status":"success","data":{"data":[...]}}
      List<dynamic> cartItems = [];
      if (response.containsKey('status') &&
          response['status'] == 'success' &&
          response.containsKey('data') &&
          response['data'] is Map &&
          response['data'].containsKey('data') &&
          response['data']['data'] is List) {
        cartItems = response['data']['data'] as List;
      }

      _cart = {
        'items': cartItems,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItem(String productId, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateCartItem(productId, quantity);

      // Parse the nested response structure: {"status":"success","data":{"data":[...]}}
      List<dynamic> cartItems = [];
      if (response.containsKey('status') &&
          response['status'] == 'success' &&
          response.containsKey('data') &&
          response['data'] is Map &&
          response['data'].containsKey('data') &&
          response['data']['data'] is List) {
        cartItems = response['data']['data'] as List;
      }

      _cart = {
        'items': cartItems,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.removeFromCart(productId);

      // Parse the nested response structure: {"status":"success","data":{"data":[...]}}
      List<dynamic> cartItems = [];
      if (response.containsKey('status') &&
          response['status'] == 'success' &&
          response.containsKey('data') &&
          response['data'] is Map &&
          response['data'].containsKey('data') &&
          response['data']['data'] is List) {
        cartItems = response['data']['data'] as List;
      }

      _cart = {
        'items': cartItems,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.clearCart();
    } catch (e) {
      // If API fails (e.g., cart already cleared), that's okay
      // We'll still clear locally below
      print('Clear cart API failed (expected if cart already empty): $e');
    }

    // Always clear cart locally regardless of API result
    _cart = {
      'items': [],
    };

    _isLoading = false;
    notifyListeners();
  }

  // Clear cart locally without API call (useful for post-checkout cleanup)
  void clearCartLocally() {
    _cart = {
      'items': [],
    };
    _error = null;
    notifyListeners();
  }

  // Special method for post-checkout cleanup
  Future<void> postCheckoutCleanup() async {
    // Immediately clear local cart
    clearCartLocally();

    // Then refresh from backend to ensure sync
    await getCart();
  }

  // Helper method to safely extract product ID from cart item
  String? _getProductIdFromItem(Map<String, dynamic> item) {
    if (item['id'] != null) {
      return item['id'].toString();
    } else if (item['productId'] != null) {
      return item['productId'].toString();
    } else if (item['product'] != null &&
        item['product'] is Map &&
        item['product']['_id'] != null) {
      return item['product']['_id'].toString();
    }
    return null;
  }

  // Convenience method to increment quantity by 1
  Future<void> incrementQuantity(String productId) async {
    // Find current quantity
    int currentQuantity = 1;
    if (_cart['items'] != null) {
      final items = _cart['items'] as List;

      for (var item in items) {
        final itemId = _getProductIdFromItem(item);

        if (itemId == productId) {
          currentQuantity = item['quantity'] ?? 1;
          break;
        }
      }
    }

    final newQuantity = currentQuantity + 1;
    await updateCartItem(productId, newQuantity);
  }

  // Convenience method to decrement quantity by 1
  Future<void> decrementQuantity(String productId) async {
    // Find current quantity
    int currentQuantity = 1;
    if (_cart['items'] != null) {
      final items = _cart['items'] as List;

      for (var item in items) {
        final itemId = _getProductIdFromItem(item);

        if (itemId == productId) {
          currentQuantity = item['quantity'] ?? 1;
          break;
        }
      }
    }

    final newQuantity = currentQuantity - 1;

    // If quantity becomes 0 or less, remove the item instead
    if (newQuantity <= 0) {
      await removeFromCart(productId);
    } else {
      await updateCartItem(productId, newQuantity);
    }
  }

  // Checkout method to create order from cart items
  Future<bool> checkout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_cart['items'] == null || (_cart['items'] as List).isEmpty) {
        throw Exception('Cart is empty');
      }

      // Format cart items for order API
      final List<Map<String, dynamic>> orderItems = [];
      final items = _cart['items'] as List;

      for (var item in items) {
        final productId = _getProductIdFromItem(item);
        if (productId != null) {
          // Convert productId to integer and add to order items
          final int productIdInt = int.parse(productId);
          orderItems.add({
            'productId': productIdInt,
            'quantity': item['quantity'] ?? 1,
          });
        }
      }

      // Create order using API service
      await _apiService.createOrder(orderItems);

      // Clear cart after successful order
      await clearCart();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Method to get user orders
  Future<List<dynamic>> getUserOrders() async {
    return await _apiService.getUserOrders();
  }
}

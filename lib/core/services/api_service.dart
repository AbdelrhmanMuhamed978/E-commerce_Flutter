import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/product_model.dart';

class ApiService {
  final String baseUrl =
      'https://e-commerce-mean-production.up.railway.app/api/v1';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get headers {
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Login failed');
    }
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/InsertUserS'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 201) {
      throw Exception(data['message'] ?? 'Registration failed');
    }
    return data;
  }

  // Profile Update
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String password, // Current password is always required
    String? newPassword, // Optional new password
  }) async {
    final Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'password': password, // Current password
      'newPassword': newPassword ?? '', // Empty string if not changing password
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/users/profile'), // Updated endpoint
      headers: headers,
      body: jsonEncode(requestBody),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Failed to update profile');
    }

    return data;
  }

  // Avatar Management
  Future<Map<String, dynamic>> uploadAvatar(
      Uint8List imageBytes, String fileName, String mimeType) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/avatar'),
      );

      // Add authorization header
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add image file using bytes with proper content type
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          imageBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(data['message'] ??
            data['data']?['message'] ??
            'Failed to upload avatar');
      }

      return data;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  Future<Map<String, dynamic>> getUserAvatar() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/avatar'),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['data']?['message'] ?? 'Failed to get avatar');
    }

    return data;
  }

  Future<Map<String, dynamic>> deleteAvatar() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/avatar'),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['data']?['message'] ?? 'Failed to delete avatar');
    }

    return data;
  }

  String getAvatarUrl(String avatarFilename) {
    return '$baseUrl/avatars/$avatarFilename';
  }

  // Products
  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/getAllProducts'),
      headers: headers,
    );

    print('Products API response: ${response.body}'); // Debug print
    print('Products status code: ${response.statusCode}'); // Debug print

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final data = jsonDecode(response.body);

    // Handle the response structure: {"status":"success","data":{"data":[...]}}
    List<dynamic> productsData;
    if (data is Map &&
        data.containsKey('status') &&
        data['status'] == 'success' &&
        data.containsKey('data') &&
        data['data'] is Map &&
        data['data'].containsKey('data') &&
        data['data']['data'] is List) {
      productsData = data['data']['data'] as List;
    } else if (data is List) {
      productsData = data;
    } else {
      throw Exception('Unexpected response format: ${data.runtimeType}');
    }

    return productsData.map((item) => Product.fromJson(item)).toList();
  }

  Future<Product> getProductById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load product');
    }

    final data = jsonDecode(response.body);
    return Product.fromJson(data);
  }

  // Cart
  Future<Map<String, dynamic>> addToCart(String productId, int quantity) async {
    print(
        'Adding to cart with token: ${_token != null ? "Token present" : "No token"}'); // Debug print
    print('Add to cart API headers: $headers'); // Debug print
    print(
        'Add to cart API - Product ID: $productId (type: ${productId.runtimeType}), Quantity: $quantity'); // Debug print

    // Convert productId to integer for backend
    int productIdInt;
    try {
      productIdInt = int.parse(productId);
      print('Converted productId to integer: $productIdInt'); // Debug print
    } catch (e) {
      throw Exception(
          'Invalid productId: $productId. Must be a valid integer.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
      body: jsonEncode({'productId': productIdInt, 'quantity': quantity}),
    );

    print(
        'Add to cart API response status: ${response.statusCode}'); // Debug print
    print('Add to cart API response body: ${response.body}'); // Debug print

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to add item to cart: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getCart() async {
    print(
        'Getting cart with token: ${_token != null ? "Token present" : "No token"}'); // Debug print
    print('Cart API headers: $headers'); // Debug print

    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
    );

    print('Cart API response status: ${response.statusCode}'); // Debug print
    print('Cart API response body: ${response.body}'); // Debug print

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get cart: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateCartItem(
      String productId, int quantity) async {
    print(
        'Updating cart item with token: ${_token != null ? "Token present" : "No token"}'); // Debug print
    print('Update cart API headers: $headers'); // Debug print
    print(
        'Update cart API - Product ID: $productId (type: ${productId.runtimeType}), Quantity: $quantity'); // Debug print

    // Use PATCH method with productId in URL and quantity in body
    final response = await http.patch(
      Uri.parse('$baseUrl/cart/$productId'),
      headers: headers,
      body: jsonEncode({'quantity': quantity}),
    );

    print(
        'Update cart API response status: ${response.statusCode}'); // Debug print
    print('Update cart API response body: ${response.body}'); // Debug print

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update cart item: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> removeFromCart(String productId) async {
    print(
        'Removing from cart with token: ${_token != null ? "Token present" : "No token"}'); // Debug print
    print('Remove from cart API headers: $headers'); // Debug print
    print(
        'Remove from cart API - Product ID: $productId (type: ${productId.runtimeType})'); // Debug print

    // Convert productId to integer for backend consistency
    int productIdInt;
    try {
      productIdInt = int.parse(productId);
      print('Converted productId to integer: $productIdInt'); // Debug print
    } catch (e) {
      throw Exception(
          'Invalid productId: $productId. Must be a valid integer.');
    }

    // Use the correct endpoint: DELETE /cart/:productId
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$productIdInt'),
      headers: headers,
    );

    print(
        'Remove from cart API response status: ${response.statusCode}'); // Debug print
    print(
        'Remove from cart API response body: ${response.body}'); // Debug print

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to remove item from cart: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> clearCart() async {
    print(
        'Clearing cart with token: ${_token != null ? "Token present" : "No token"}'); // Debug print
    print('Clear cart API headers: $headers'); // Debug print

    final response = await http.delete(
      Uri.parse('$baseUrl/cart'),
      headers: headers,
    );

    print(
        'Clear cart API response status: ${response.statusCode}'); // Debug print
    print('Clear cart API response body: ${response.body}'); // Debug print

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to clear cart: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);
  }

  // Orders
  Future<Map<String, dynamic>> createOrder(
    List<Map<String, dynamic>> cartItems,
  ) async {
    print('Creating order with cart items: $cartItems'); // Debug print

    final response = await http.post(
      Uri.parse('$baseUrl/products/order'),
      headers: headers,
      body: jsonEncode(cartItems),
    );

    print(
        'Create order API response status: ${response.statusCode}'); // Debug print
    print('Create order API response body: ${response.body}'); // Debug print

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Failed to create order: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getUserOrders() async {
    print('Fetching user orders'); // Debug print

    final response = await http.get(
      Uri.parse('$baseUrl/products/lastOrders'),
      headers: headers,
    );

    print(
        'Get orders API response status: ${response.statusCode}'); // Debug print
    print('Get orders API response body: ${response.body}'); // Debug print

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to get orders: ${response.statusCode} - ${response.body}');
    }

    return jsonDecode(response.body);
  }

  // Admin API methods to match your backend
  Future<List<dynamic>> getCustomersOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admins/customersOrders'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get customers orders: ${response.body}');
      }

      final data = jsonDecode(response.body);

      // Your backend returns a direct array of orders
      if (data is List) {
        return data;
      } else if (data is Map<String, dynamic>) {
        // Handle nested response if backend changes format
        if (data['status'] == 'success' && data['data'] != null) {
          final orders = data['data']['data'] ?? data['data'];
          if (orders is List) {
            return orders;
          }
        } else if (data['data'] != null) {
          final orders = data['data'];
          if (orders is List) {
            return orders;
          }
        }
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching orders: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getAllUsers(String adminUserTypeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/GetAllUserS?ObjectId=$adminUserTypeId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get all users: ${response.body}');
      }

      final data = jsonDecode(response.body);

      // Your backend returns nested structure: {status: "success", data: {data: [...]}}
      if (data is Map<String, dynamic>) {
        if (data['status'] == 'success' && data['data'] != null) {
          final usersData = data['data']['data'];
          if (usersData is List) {
            return usersData;
          }
        } else if (data['data'] != null) {
          final users = data['data'];
          if (users is List) {
            return users;
          }
        }
      } else if (data is List) {
        // Response is directly a list
        return data;
      }

      return [];
    } catch (e) {
      throw Exception('Error fetching users: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> insertProduct(
      Map<String, dynamic> productData, String adminUserTypeId) async {
    // Add ObjectId for admin verification
    final requestBody = {
      ...productData,
      'ObjectId': adminUserTypeId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/products/insertProduct'),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to insert product: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> editUser(String userId,
      Map<String, dynamic> userData, String adminUserTypeId) async {
    // Add ObjectId for admin verification
    final requestBody = {
      ...userData,
      'ObjectId': adminUserTypeId,
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/users/EditUsers'),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit user: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus(
      dynamic orderId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/products/order/$orderId'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update order status: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error updating order status: ${e.toString()}');
    }
  }
}

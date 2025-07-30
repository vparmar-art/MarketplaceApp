import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService extends ChangeNotifier {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    // Initialization moved to init() to ensure proper async loading
  }

  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api/';
  String? _token;

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    } catch (e) {
      // Handle token loading error silently
    }
  }

  Future<void> init() async {
    await _loadToken();
  }

  // Ensure token is loaded before making requests
  Future<void> ensureInitialized() async {
    if (_token == null) {
      await _loadToken();
    }
  }



  Future<void> setToken(String token) async {
    _token = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> get headers {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Token $_token';
    }

    return headers;
  }

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: data != null ? json.encode(data) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: data != null ? json.encode(data) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic PATCH request
  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: data != null ? json.encode(data) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Upload file with multipart request
  Future<dynamic> uploadFile(String endpoint, File file, {String fileField = 'file', Map<String, String>? fields}) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      // Add authorization header
      if (_token != null) {
        request.headers['Authorization'] = 'Token $_token';
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          file.path,
        ),
      );

      // Add other fields if provided
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else {
      _handleHttpError(response);
    }
  }

  // Handle HTTP errors
  void _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        throw Exception('Bad request: ${response.body}');
      case 401:
        throw Exception('Unauthorized: ${response.body}');
      case 403:
        throw Exception('Forbidden: ${response.body}');
      case 404:
        throw Exception('Not found: ${response.body}');
      case 500:
        throw Exception('Server error: ${response.body}');
      default:
        throw Exception('HTTP error ${response.statusCode}: ${response.body}');
    }
  }

  // Handle general errors
  void _handleError(dynamic error) {
    // Handle error silently in production
  }

  // Authentication endpoints
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await post('login/', data: {
      'username': username,
      'password': password,
    });
    
    // Check for different token key names
    String? token;
    if (response['token'] != null) {
      token = response['token'];
    } else if (response['access'] != null) {
      token = response['access']; // Alternative token key
    } else if (response['access_token'] != null) {
      token = response['access_token']; // Another alternative
    }
    
    if (token != null) {
      await setToken(token);
    }
    
    return response;
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    return await post('register/', data: {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<void> logout() async {
    try {
      await post('logout/');
    } finally {
      await clearToken();
    }
  }

  // User profile endpoints
  Future<Map<String, dynamic>> getUserProfile() async {
    return await get('profiles/me/');
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    return await patch('profiles/me/', data: data);
  }

  // Category endpoints
  Future<List<dynamic>> getCategories() async {
    return await get('categories/');
  }

  Future<Map<String, dynamic>> getCategoryDetail(int id) async {
    return await get('categories/$id/');
  }

  // Product endpoints
  Future<dynamic> getProducts({int? page, String? search, int? categoryId}) async {
    String endpoint = 'products/?';
    if (page != null) endpoint += 'page=$page&';
    if (search != null) endpoint += 'search=$search&';
    if (categoryId != null) endpoint += 'category=$categoryId&';
    return await get(endpoint);
  }

  Future<Map<String, dynamic>> getProductDetail(int id) async {
    return await get('products/$id/');
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    return await post('products/', data: data);
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data) async {
    return await patch('products/$id/', data: data);
  }

  Future<void> deleteProduct(int id) async {
    await delete('products/$id/');
  }

  // Product image upload
  Future<Map<String, dynamic>> uploadProductImage(int productId, File image) async {
    return await uploadFile(
      'products/$productId/images/',
      image,
      fileField: 'image',
    );
  }

  // Review endpoints
  Future<List<dynamic>> getProductReviews(int productId) async {
    return await get('products/$productId/reviews/');
  }

  Future<Map<String, dynamic>> createReview(int productId, int rating, String comment) async {
    return await post('products/$productId/reviews/', data: {
      'rating': rating,
      'comment': comment,
    });
  }

  // Order endpoints
  Future<List<dynamic>> getOrders() async {
    return await get('orders/');
  }

  Future<Map<String, dynamic>> getUserOrders({int? page, int? pageSize}) async {
    String endpoint = 'orders/my-orders/?';
    if (page != null) endpoint += 'page=$page&';
    if (pageSize != null) endpoint += 'page_size=$pageSize&';
    return await get(endpoint);
  }

  Future<Map<String, dynamic>> getOrderDetail(int id) async {
    return await get('orders/$id/');
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    return await post('orders/', data: data);
  }

  Future<Map<String, dynamic>> updateOrderStatus(int id, String status) async {
    return await patch('orders/$id/', data: {
      'status': status,
    });
  }

  // Order document upload
  Future<Map<String, dynamic>> uploadOrderDocument(int orderId, File document, String documentType) async {
    return await uploadFile(
      'orders/$orderId/documents/',
      document,
      fileField: 'document',
      fields: {'document_type': documentType},
    );
  }
}
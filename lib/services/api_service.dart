import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/banner.dart' show PromoBanner;
import '../models/category.dart' show ProductCategory;

class ApiService {
  static const String baseUrl = 'http://bellen-nodes-htzjq6lxvvlw-908287247.ap-south-1.elb.amazonaws.com:80';
  static const Duration timeout = Duration(seconds: 30);
  
  final Dio _dio;
  final http.Client _httpClient;

  ApiService() : _dio = Dio(), _httpClient = http.Client() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = timeout;
    _dio.options.receiveTimeout = timeout;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Helper method to get the best image URL from variants
  String? _getBestImageUrl(List<dynamic>? imageVariants) {
    if (imageVariants == null || imageVariants.isEmpty) return null;
    
    // Try to find the medium resolution first, then large, then small
    final medium = imageVariants.firstWhere(
      (variant) => variant['resolution'] == 'md',
      orElse: () => imageVariants.first,
    );
    
    return medium['url'];
  }

  // PRODUCT OPERATIONS
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'] ?? [];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch products: ${response.statusCode}');
    } catch (e) {
      print('Get products error: $e');
      rethrow;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _dio.get('/products/search/$query');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'] ?? [];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      
      throw Exception('Failed to search products: ${response.statusCode}');
    } catch (e) {
      print('Search products error: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _dio.get('/products/category/$category');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'] ?? [];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch products by category: ${response.statusCode}');
    } catch (e) {
      print('Get products by category error: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsByType(String type) async {
    try {
      final response = await _dio.get('/products/type/$type');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'] ?? [];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch products by type: ${response.statusCode}');
    } catch (e) {
      print('Get products by type error: $e');
      rethrow;
    }
  }

  Future<Product> createProduct(Product product) async {
    try {
      FormData formData;
      
      if (product.imageFile != null) {
        // Create multipart form data with image
        formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            product.imageFile!.path,
            filename: product.imageFile!.path.split('/').last,
          ),
          'name': product.name,
          'category': product.category,
          'newPrice': product.newPrice.toString(),
          'oldPrice': product.oldPrice?.toString() ?? '',
          'quantity': product.quantity.toString(),
          'type': product.type.name,
          'desc': '', // Add description field if needed
          'season': '', // Add season field if needed
        });
      } else {
        // Create form data without image
        formData = FormData.fromMap({
          'name': product.name,
          'category': product.category,
          'newPrice': product.newPrice.toString(),
          'oldPrice': product.oldPrice?.toString() ?? '',
          'quantity': product.quantity.toString(),
          'type': product.type.name,
          'desc': '', // Add description field if needed
          'season': '', // Add season field if needed
        });
      }

      final response = await _dio.post('/upload/products', data: formData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Product.fromJson(response.data);
      }
      
      throw Exception('Failed to create product: ${response.statusCode}');
    } catch (e) {
      print('Create product error: $e');
      rethrow;
    }
  }

  Future<Product> updateProduct(Product product) async {
    try {
      FormData formData;
      
      if (product.imageFile != null) {
        // Create multipart form data with image
        formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            product.imageFile!.path,
            filename: product.imageFile!.path.split('/').last,
          ),
          'name': product.name,
          'category': product.category,
          'new_price': product.newPrice.toString(),
          'old_price': product.oldPrice?.toString() ?? '',
          'quantity': product.quantity.toString(),
          'type': product.type.name,
          'desc': '', // Add description field if needed
          'season': '', // Add season field if needed
        });
      } else {
        // Create form data without image
        formData = FormData.fromMap({
          'name': product.name,
          'category': product.category,
          'new_price': product.newPrice.toString(),
          'old_price': product.oldPrice?.toString() ?? '',
          'quantity': product.quantity.toString(),
          'type': product.type.name,
          'desc': '', // Add description field if needed
          'season': '', // Add season field if needed
        });
      }

      final response = await _dio.put('/products/${product.id}', data: formData);
      
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
      
      throw Exception('Failed to update product: ${response.statusCode}');
    } catch (e) {
      print('Update product error: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await _dio.delete('/products/$productId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete product error: $e');
      rethrow;
    }
  }

  // BANNER OPERATIONS
  Future<List<PromoBanner>> getBanners() async {
    try {
      final response = await _dio.get('/banners');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['banners'] ?? [];
        return data.map((json) => PromoBanner.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch banners: ${response.statusCode}');
    } catch (e) {
      print('Get banners error: $e');
      rethrow;
    }
  }

  Future<List<PromoBanner>> getActiveBanners() async {
    try {
      final response = await _dio.get('/banners/active');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['banners'] ?? [];
        return data.map((json) => PromoBanner.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch active banners: ${response.statusCode}');
    } catch (e) {
      print('Get active banners error: $e');
      rethrow;
    }
  }

  Future<PromoBanner> createBanner(PromoBanner banner) async {
    try {
      FormData formData;
      
      if (banner.imageFile != null) {
        // Create multipart form data with image
        formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            banner.imageFile!.path,
            filename: banner.imageFile!.path.split('/').last,
          ),
          'name': banner.name,
        });
      } else {
        // Create form data without image
        formData = FormData.fromMap({
          'name': banner.name,
        });
      }

      final response = await _dio.post('/upload/banners', data: formData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PromoBanner.fromJson(response.data);
      }
      
      throw Exception('Failed to create banner: ${response.statusCode}');
    } catch (e) {
      print('Create banner error: $e');
      rethrow;
    }
  }

  Future<PromoBanner> updateBanner(PromoBanner banner) async {
    try {
      FormData formData;
      
      if (banner.imageFile != null) {
        // Create multipart form data with image
        formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            banner.imageFile!.path,
            filename: banner.imageFile!.path.split('/').last,
          ),
          'title': banner.name, // Backend expects 'title' field
        });
      } else {
        // Create form data without image
        formData = FormData.fromMap({
          'title': banner.name, // Backend expects 'title' field
        });
      }

      final response = await _dio.put('/banners/${banner.id}', data: formData);
      
      if (response.statusCode == 200) {
        return PromoBanner.fromJson(response.data);
      }
      
      throw Exception('Failed to update banner: ${response.statusCode}');
    } catch (e) {
      print('Update banner error: $e');
      rethrow;
    }
  }

  Future<void> deleteBanner(String bannerId) async {
    try {
      final response = await _dio.delete('/banners/$bannerId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete banner: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete banner error: $e');
      rethrow;
    }
  }

  // CATEGORY OPERATIONS
  Future<List<ProductCategory>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['categories'] ?? [];
        return data.map((json) => ProductCategory.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch categories: ${response.statusCode}');
    } catch (e) {
      print('Get categories error: $e');
      rethrow;
    }
  }

  Future<List<ProductCategory>> getActiveCategories() async {
    try {
      final response = await _dio.get('/categories/active');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['categories'] ?? [];
        return data.map((json) => ProductCategory.fromJson(json)).toList();
      }
      
      throw Exception('Failed to fetch active categories: ${response.statusCode}');
    } catch (e) {
      print('Get active categories error: $e');
      rethrow;
    }
  }

  Future<ProductCategory> createCategory(ProductCategory category) async {
    try {
      FormData formData;
      
      if (category.imageFile != null) {
        // Create multipart form data with image
        formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            category.imageFile!.path,
            filename: category.imageFile!.path.split('/').last,
          ),
          'name': category.name,
          'description': category.description ?? '',
        });
      } else {
        // Create form data without image
        formData = FormData.fromMap({
          'name': category.name,
          'description': category.description ?? '',
        });
      }

      final response = await _dio.post('/upload/category', data: formData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductCategory.fromJson(response.data);
      }
      
      throw Exception('Failed to create category: ${response.statusCode}');
    } catch (e) {
      print('Create category error: $e');
      rethrow;
    }
  }

  Future<ProductCategory> updateCategory(ProductCategory category) async {
    try {
      FormData formData;
      
      if (category.imageFile != null) {
        // Create multipart form data with image
        formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            category.imageFile!.path,
            filename: category.imageFile!.path.split('/').last,
          ),
          'name': category.name,
          'priority': '1', // Default priority
        });
      } else {
        // Create form data without image
        formData = FormData.fromMap({
          'name': category.name,
          'priority': '1', // Default priority
        });
      }

      final response = await _dio.put('/categories/${category.id}', data: formData);
      
      if (response.statusCode == 200) {
        return ProductCategory.fromJson(response.data);
      }
      
      throw Exception('Failed to update category: ${response.statusCode}');
    } catch (e) {
      print('Update category error: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final response = await _dio.delete('/categories/$categoryId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete category error: $e');
      rethrow;
    }
  }

  // DASHBOARD OPERATIONS
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to fetch dashboard stats: ${response.statusCode}');
    } catch (e) {
      print('Get dashboard stats error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRecentItems() async {
    try {
      final response = await _dio.get('/recent');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      
      throw Exception('Failed to fetch recent items: ${response.statusCode}');
    } catch (e) {
      print('Get recent items error: $e');
      rethrow;
    }
  }

  // CACHE MANAGEMENT
  Future<void> clearCache(String entity) async {
    try {
      await _dio.delete('/cache/$entity');
    } catch (e) {
      print('Clear cache error: $e');
      rethrow;
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _dio.delete('/cache');
    } catch (e) {
      print('Clear all cache error: $e');
      rethrow;
    }
  }

  void dispose() {
    _dio.close();
    _httpClient.close();
  }
}
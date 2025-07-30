import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  Product? _selectedProduct;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Product? get selectedProduct => _selectedProduct;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setSelectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      setLoading(true);
      clearError();
      _products = await _apiService.getProducts();
      notifyListeners();
    } catch (e) {
      setError('Failed to fetch products: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createProduct(Product product) async {
    try {
      setLoading(true);
      clearError();
      
      final createdProduct = await _apiService.createProduct(product);
      _products.add(createdProduct);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to create product: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedProduct = await _apiService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == product.id);
      
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to update product: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      setLoading(true);
      clearError();
      
      await _apiService.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to delete product: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return _products;
    
    try {
      return await _apiService.searchProducts(query);
    } catch (e) {
      setError('Failed to search products: $e');
      return [];
    }
  }

  Future<List<Product>> filterByCategory(String category) async {
    if (category.isEmpty || category == 'All') return _products;
    
    try {
      return await _apiService.getProductsByCategory(category);
    } catch (e) {
      setError('Failed to filter products by category: $e');
      return [];
    }
  }

  Future<List<Product>> filterByType(ProductType type) async {
    try {
      return await _apiService.getProductsByType(type.name);
    } catch (e) {
      setError('Failed to filter products by type: $e');
      return [];
    }
  }

  List<Product> searchProductsLocal(String query) {
    if (query.isEmpty) return _products;
    
    return _products.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      product.category.toLowerCase().contains(query.toLowerCase()) ||
      product.type.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<Product> filterByCategoryLocal(String category) {
    if (category.isEmpty || category == 'All') return _products;
    
    return _products.where((product) =>
      product.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  List<Product> filterByTypeLocal(ProductType type) {
    return _products.where((product) => product.type == type).toList();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
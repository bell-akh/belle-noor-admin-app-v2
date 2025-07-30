import 'package:flutter/foundation.dart';
import '../models/category.dart' show ProductCategory;
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ProductCategory> _categories = [];
  bool _isLoading = false;
  String? _error;
  ProductCategory? _selectedCategory;

  List<ProductCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProductCategory? get selectedCategory => _selectedCategory;

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

  void setSelectedCategory(ProductCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      setLoading(true);
      clearError();
      _categories = await _apiService.getCategories();
      notifyListeners();
    } catch (e) {
      setError('Failed to fetch categories: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createCategory(ProductCategory category) async {
    try {
      setLoading(true);
      clearError();
      
      final createdCategory = await _apiService.createCategory(category);
      _categories.add(createdCategory);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to create category: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateCategory(ProductCategory category) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedCategory = await _apiService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      
      if (index != -1) {
        _categories[index] = updatedCategory;
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to update category: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    try {
      setLoading(true);
      clearError();
      
      await _apiService.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to delete category: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  List<ProductCategory> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    
    return _categories.where((category) =>
      category.name.toLowerCase().contains(query.toLowerCase()) ||
      (category.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  Future<List<ProductCategory>> getActiveCategories() async {
    try {
      return await _apiService.getActiveCategories();
    } catch (e) {
      setError('Failed to fetch active categories: $e');
      return [];
    }
  }

  List<ProductCategory> getActiveCategoriesLocal() {
    return _categories.where((category) => category.isActive).toList();
  }

  List<String> getCategoryNames() {
    return _categories.map((category) => category.name).toList();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
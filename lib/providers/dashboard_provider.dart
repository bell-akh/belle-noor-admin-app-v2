import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _recentItems = {};
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get stats => _stats;
  Map<String, dynamic> get recentItems => _recentItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> fetchDashboardStats() async {
    try {
      setLoading(true);
      clearError();
      _stats = await _apiService.getDashboardStats();
      notifyListeners();
    } catch (e) {
      setError('Failed to fetch dashboard stats: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchRecentItems() async {
    try {
      setLoading(true);
      clearError();
      _recentItems = await _apiService.getRecentItems();
      notifyListeners();
    } catch (e) {
      setError('Failed to fetch recent items: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> refreshDashboard() async {
    await Future.wait([
      fetchDashboardStats(),
      fetchRecentItems(),
    ]);
  }

  Future<void> clearCache(String entity) async {
    try {
      await _apiService.clearCache(entity);
      // Refresh data after clearing cache
      await refreshDashboard();
    } catch (e) {
      setError('Failed to clear cache: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _apiService.clearAllCache();
      // Refresh data after clearing cache
      await refreshDashboard();
    } catch (e) {
      setError('Failed to clear all cache: $e');
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
} 
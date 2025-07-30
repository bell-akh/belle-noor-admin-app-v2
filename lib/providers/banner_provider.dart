import 'package:flutter/foundation.dart';
import '../models/banner.dart' show PromoBanner;
import '../services/api_service.dart';

class BannerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<PromoBanner> _banners = [];
  bool _isLoading = false;
  String? _error;
  PromoBanner? _selectedBanner;

  List<PromoBanner> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PromoBanner? get selectedBanner => _selectedBanner;

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

  void setSelectedBanner(PromoBanner? banner) {
    _selectedBanner = banner;
    notifyListeners();
  }

  Future<void> fetchBanners() async {
    try {
      setLoading(true);
      clearError();
      _banners = await _apiService.getBanners();
      notifyListeners();
    } catch (e) {
      setError('Failed to fetch banners: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createBanner(PromoBanner banner) async {
    try {
      setLoading(true);
      clearError();
      
      final createdBanner = await _apiService.createBanner(banner);
      _banners.add(createdBanner);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to create banner: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateBanner(PromoBanner banner) async {
    try {
      setLoading(true);
      clearError();
      
      final updatedBanner = await _apiService.updateBanner(banner);
      final index = _banners.indexWhere((b) => b.id == banner.id);
      
      if (index != -1) {
        _banners[index] = updatedBanner;
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to update banner: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteBanner(String bannerId) async {
    try {
      setLoading(true);
      clearError();
      
      await _apiService.deleteBanner(bannerId);
      _banners.removeWhere((b) => b.id == bannerId);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to delete banner: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  List<PromoBanner> searchBanners(String query) {
    if (query.isEmpty) return _banners;
    
    return _banners.where((banner) =>
      banner.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<List<PromoBanner>> getActiveBanners() async {
    try {
      return await _apiService.getActiveBanners();
    } catch (e) {
      setError('Failed to fetch active banners: $e');
      return [];
    }
  }

  List<PromoBanner> getActiveBannersLocal() {
    return _banners.where((banner) => banner.isActive).toList();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
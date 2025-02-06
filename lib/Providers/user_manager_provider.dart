import 'package:flutter/material.dart';

import '../Core/Utils/storage_keys.dart';
import '../Core/infrastructure/storage/storage_service.dart';
import '../Features/User/models/contractor.dart';
import '../Features/User/models/service_category.dart';
import '../Features/User/models/user_info.dart';
import '../Features/User/services/user_api.dart';
import '../Features/auth/Services/token_manager.dart';

class UserManagerProvider extends ChangeNotifier {
  late final StorageService storage;
  String? _token;
  UserInfo? _userInfo;
  List<ServiceCategory> _categories = [];
  List<Contractor> _bestContractors = [];
  List<Contractor> _contractorsbyService = [];
  String _searchQuery = '';
  String _contractorsByServiceSearch = '';
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get token => _token;
  UserInfo? get userInfo => _userInfo;
  bool get isAuthenticated => _token != null && _userInfo != null;
  List<ServiceCategory> get categories => _categories;
  List<Contractor> get bestContractors => _bestContractors;
  List<Contractor> get contractorsbyService => _contractorsbyService;
  String get searchQuery => _searchQuery;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserManagerProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    try {
      storage = await StorageService.getInstance();
      await _loadUserData();
    } catch (e) {
      debugPrint('Provider initialization error: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      _token = storage.getString(StorageKeys.tokenKey);
      debugPrint('Loaded token: $_token');

      if (_token != null) {
        // Try to get user info with current token
        final userInfoSuccess = await fetchUserInfo();

        // If user info fails, try token refresh
        if (!userInfoSuccess && _token != null) {
          final refreshed = await TokenManager.instance.refreshToken();
          if (refreshed) {
            // Update token and try user info again
            _token = TokenManager.instance.token;
            await fetchUserInfo();
          } else {
            // If refresh fails, clear authentication
            await clearAuthData();
          }
        }
      }

      // Always fetch public data
      await Future.wait([
        fetchCategories(),
        fetchBestContractors(),
      ]);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user data: $e');
      notifyListeners();
    }
  }

  // Initialize data
  Future<void> initialize() async {
    try {
      _error = null;
      await Future.wait([
        fetchCategories(),
        fetchBestContractors(),
        if (_token != null) fetchUserInfo(),
      ]);
    } catch (e) {
      _error = e.toString();
      debugPrint('Initialization error: $e');
      notifyListeners();
    }
  }

  // Update token
  Future<void> updateToken(String newToken) async {
    _token = newToken;
    await storage.setString(StorageKeys.tokenKey, newToken);
    await _loadUserData();
  }

  // Clear data on logout
  Future<void> clearData() async {
    _token = null;
    _userInfo = null;
    await storage.remove(StorageKeys.tokenKey);
    notifyListeners();
    // Reinitialize public data
    await initialize();
  }

  // Fetch user info
  Future<bool> fetchUserInfo() async {
    if (_token == null) return false;

    try {
      _setLoading(true);
      final response = await UserApi.getUserInfo(token: _token);

      if (response.success && response.data != null) {
        _userInfo = response.data;
        debugPrint('User info fetched successfully: ${_userInfo?.fullName}');
        notifyListeners();
        return true;
      } else {
        _error = response.error;
        debugPrint('Error fetching user info: ${response.error}');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Exception fetching user info: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearAuthData() async {
    _token = null;
    _userInfo = null;
    await storage.remove(StorageKeys.tokenKey);
    await TokenManager.instance.clearToken();
    notifyListeners();
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    try {
      _setLoading(true);
      final response = await UserApi.getCategories();

      if (response.success && response.data != null) {
        _categories = response.data!;
        debugPrint('Categories fetched: ${_categories.length}');
      } else {
        _error = response.error;
        debugPrint('Error fetching categories: ${response.error}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Exception fetching categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch best contractors
  Future<void> fetchBestContractors() async {
    try {
      _setLoading(true);
      final response = await UserApi.getBestContractors();

      if (response.success && response.data != null) {
        _bestContractors = response.data!;
        debugPrint('Contractors fetched: ${_bestContractors.length}');
      } else {
        _error = response.error;
        debugPrint('Error fetching contractors: ${response.error}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Exception fetching contractors: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Search functionality
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Navigation
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Favorite functionality
  void toggleFavorite(int contractorId) {
    final contractorIndex =
        _bestContractors.indexWhere((c) => c.id == contractorId);
    if (contractorIndex >= 0) {
      _bestContractors[contractorIndex] =
          _bestContractors[contractorIndex].copyWith(
        isFavorite: !_bestContractors[contractorIndex].isFavorite,
      );
      notifyListeners();
    }
  }

  // Best contractors
  List<Contractor> get getBestContractors {
    if (_searchQuery.isEmpty) return _bestContractors;
    return _bestContractors
        .where((contractor) =>
            contractor.fullName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            contractor.service
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Fetch contractors by service
  Future<void> fetchContractorsByService(int? id) async {
    try {
      _setLoading(true);
      final response = await UserApi.getContractorsByService(id: id);

      if (response.success && response.data != null) {
        _contractorsbyService = response.data!;
        debugPrint('Contractors fetched: ${_contractorsbyService.length}');
      } else {
        _error = response.error;
        debugPrint('Error fetching contractors: ${response.error}');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Exception fetching contractors: $e');
    } finally {
      _setLoading(false);
    }
  }

  void updateContractorsByServiceSearch(String query) {
    _contractorsByServiceSearch = query;
    notifyListeners();
  }

  void clearContractorsByServiceSearch() {
    _contractorsByServiceSearch = '';
    notifyListeners();
  }

  List<Contractor> get getContractorsByService {
    if (_contractorsByServiceSearch.isEmpty) return _contractorsbyService;
    return _contractorsbyService
        .where((contractor) =>
            contractor.fullName
                .toLowerCase()
                .contains(_contractorsByServiceSearch.toLowerCase()) ||
            contractor.service
                .toLowerCase()
                .contains(_contractorsByServiceSearch.toLowerCase()))
        .toList();
  }
}

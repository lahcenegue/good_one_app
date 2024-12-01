import 'package:flutter/material.dart';

import '../Features/User/models/contractor.dart';
import '../Features/User/models/service_category.dart';
import '../Features/User/services/user_api.dart';

class UserManagerProvider extends ChangeNotifier {
  List<ServiceCategory>? _categories;
  List<Contractor>? _contractors;
  String _searchQuery = '';
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ServiceCategory> get categories => _categories ?? [];
  List<Contractor> get contractors => _contractors ?? [];
  String get searchQuery => _searchQuery;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserManagerProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialize();
    });
  }

  // Initialize data
  Future<void> initialize() async {
    await Future.wait([
      fetchCategories(),
      fetchContractors(),
    ]);
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await UserApi.getCategories();

      if (response.success && response.data != null) {
        _categories = List<ServiceCategory>.from(response.data!);
      } else {
        _error = response.error;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch contractors
  Future<void> fetchContractors() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await UserApi.getContractors();

      if (response.success && response.data != null) {
        _contractors = List<Contractor>.from(response.data!);
      } else {
        _error = response.error;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
        _contractors?.indexWhere((c) => c.id == contractorId);
    if (contractorIndex != null && contractorIndex >= 0) {
      _contractors![contractorIndex].isFavorite =
          !_contractors![contractorIndex].isFavorite;
      notifyListeners();
    }
  }

  // Filtered contractors based on search
  List<Contractor> get filteredContractors {
    if (_searchQuery.isEmpty) return contractors;
    return contractors
        .where((contractor) =>
            contractor.fullName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            contractor.service
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }
}

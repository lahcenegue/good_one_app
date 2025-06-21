import 'package:flutter/material.dart';
import 'package:good_one_app/Features/User/Models/contractor.dart';
import 'package:good_one_app/Features/User/Models/service_category.dart';
import 'package:good_one_app/Features/User/Services/user_api.dart';

class ContractorsByServiceProvider extends ChangeNotifier {
  // --- Filter State ---
  String? _selectedPricingTypeFilter;
  RangeValues? _selectedPriceRange;
  String _selectedSortBy = 'default';
  int? _minRatingFilter;

  // --- Search State ---
  String _contractorsByServiceSearch = '';

  // --- Data Lists ---
  final List<Contractor> _allContractorsForCurrentService = [];
  ServiceCategory? _currentViewedServiceCategory;
  final Set<int> _selectedSubcategoryIds = {};

  // --- Loading and Error States ---
  bool _isLoadingContractorsByService = false;
  String? _contractorsByServiceError;

  // --- Getters ---
  String? get selectedPricingTypeFilter => _selectedPricingTypeFilter;
  RangeValues? get selectedPriceRange => _selectedPriceRange;
  String get selectedSortBy => _selectedSortBy;
  int? get minRatingFilter => _minRatingFilter;

  List<Contractor> get allContractorsForCurrentService =>
      List.unmodifiable(_allContractorsForCurrentService);

  List<Contractor> get contractorsByService {
    List<Contractor> filteredList = List.from(_allContractorsForCurrentService);

    // Filter by selected subcategories
    if (_selectedSubcategoryIds.isNotEmpty) {
      filteredList = filteredList.where((contractor) {
        return contractor.subcategory != null &&
            _selectedSubcategoryIds.contains(contractor.subcategory!.id);
      }).toList();
    }

    // Filter by search query
    if (_contractorsByServiceSearch.isNotEmpty) {
      final query = _contractorsByServiceSearch.toLowerCase();
      filteredList = filteredList
          .where((contractor) =>
              (contractor.fullName?.toLowerCase().contains(query) ?? false) ||
              (contractor.service?.toLowerCase().contains(query) ?? false) ||
              (contractor.subcategory?.name.toLowerCase().contains(query) ??
                  false))
          .toList();
    }

    return List.unmodifiable(filteredList);
  }

  List<Contractor> get filteredAndSortedContractors {
    List<Contractor> filteredList = List.from(contractorsByService);

    // Apply pricing type filter
    if (_selectedPricingTypeFilter != null) {
      filteredList = filteredList.where((contractor) {
        String effectiveType = contractor.getEffectivePricingType();
        return effectiveType == _selectedPricingTypeFilter;
      }).toList();
    }

    // Apply price range filter
    if (_selectedPriceRange != null) {
      filteredList = filteredList.where((contractor) {
        double? price = contractor.getPrimaryPrice();
        if (price == null || price <= 0)
          return true; // Include services without pricing
        return price >= _selectedPriceRange!.start &&
            price <= _selectedPriceRange!.end;
      }).toList();
    }

    // Apply minimum ratings filter
    if (_minRatingFilter != null) {
      filteredList = filteredList.where((contractor) {
        return (contractor.rating?.timesRated ?? 0) >= _minRatingFilter!;
      }).toList();
    }

    // Apply sorting
    switch (_selectedSortBy) {
      case 'rating':
        filteredList.sort(
            (a, b) => (b.rating?.rating ?? 0).compareTo(a.rating?.rating ?? 0));
        break;
      case 'price_asc':
        filteredList = _sortContractorsByPrice(filteredList, ascending: true);
        break;
      case 'price_desc':
        filteredList = _sortContractorsByPrice(filteredList, ascending: false);
        break;
      case 'orders':
        filteredList.sort((a, b) => (b.orders ?? 0).compareTo(a.orders ?? 0));
        break;
      case 'ratings_count':
        filteredList.sort((a, b) =>
            (b.rating?.timesRated ?? 0).compareTo(a.rating?.timesRated ?? 0));
        break;
      case 'default':
      default:
        // Keep original order from API
        break;
    }

    return List.unmodifiable(filteredList);
  }

  String get contractorsByServiceSearchTerm => _contractorsByServiceSearch;
  bool get isLoadingContractorsByService => _isLoadingContractorsByService;
  String? get contractorsByServiceError => _contractorsByServiceError;
  ServiceCategory? get currentViewedServiceCategory =>
      _currentViewedServiceCategory;
  Set<int> get selectedSubcategoryIds =>
      Set.unmodifiable(_selectedSubcategoryIds);

  // --- Methods ---
  Future<void> fetchContractorsByService(
      int? serviceId, List<ServiceCategory> categories) async {
    print('serviceId: $serviceId');
    _isLoadingContractorsByService = true;
    _contractorsByServiceError = null;
    _selectedSubcategoryIds.clear();
    _allContractorsForCurrentService.clear();
    _currentViewedServiceCategory = null;
    notifyListeners();

    if (serviceId == null) {
      _contractorsByServiceError = "Service ID is required.";
      _isLoadingContractorsByService = false;
      notifyListeners();
      return;
    }

    try {
      try {
        _currentViewedServiceCategory =
            categories.firstWhere((cat) => cat.id == serviceId);
      } catch (e) {
        _currentViewedServiceCategory = null;
        debugPrint(
            "ContractorsByServiceProvider: Service category with ID $serviceId not found in local categories cache.");
      }

      final response = await UserApi.getContractorsByService(id: serviceId);
      if (response.success && response.data != null) {
        _allContractorsForCurrentService.addAll(response.data!);
        _contractorsByServiceError = null;
        debugPrint(
            "ContractorsByServiceProvider: _allContractorsForCurrentService populated with ${_allContractorsForCurrentService.length} contractors for service ID $serviceId.");
      } else {
        _contractorsByServiceError =
            'Failed to fetch contractors for this service';
      }
    } catch (e) {
      _contractorsByServiceError =
          'Exception fetching contractors by service: ${e.toString()}';
    } finally {
      _isLoadingContractorsByService = false;
      notifyListeners();
    }
  }

  // --- Filter Management Methods ---
  void setPricingTypeFilter(String? pricingType) {
    _selectedPricingTypeFilter = pricingType;
    notifyListeners();
  }

  void setPriceRangeFilter(RangeValues? priceRange) {
    _selectedPriceRange = priceRange;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _selectedSortBy = sortBy;
    notifyListeners();
  }

  void setMinRatingFilter(int? minRating) {
    _minRatingFilter = minRating;
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedPricingTypeFilter = null;
    _selectedPriceRange = null;
    _selectedSortBy = 'default';
    _minRatingFilter = null;
    notifyListeners();
  }

  bool get hasActiveFilters {
    return _selectedPricingTypeFilter != null ||
        _selectedPriceRange != null ||
        _selectedSortBy != 'default' ||
        _minRatingFilter != null;
  }

  List<Contractor> _sortContractorsByPrice(List<Contractor> contractors,
      {bool ascending = true}) {
    contractors.sort((a, b) {
      double? priceA = a.getPrimaryPrice();
      double? priceB = b.getPrimaryPrice();

      // Handle services without pricing - put them at the end
      if (priceA == null && priceB == null) return 0;
      if (priceA == null) return 1;
      if (priceB == null) return -1;

      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });

    return contractors;
  }

  // Get available pricing types from current contractors list
  Set<String> getAvailablePricingTypes() {
    Set<String> types = {};
    for (var contractor in contractorsByService) {
      String effectiveType = contractor.getEffectivePricingType();
      types.add(effectiveType);
    }
    return types;
  }

  // Get price range from contractors list
  Map<String, double> getPriceRange() {
    List<double> prices = contractorsByService
        .map((c) => c.getPrimaryPrice())
        .where((price) => price != null && price > 0)
        .cast<double>()
        .toList();

    if (prices.isEmpty) {
      return {'min': 0.0, 'max': 100.0};
    }

    prices.sort();
    return {
      'min': prices.first,
      'max': prices.last,
    };
  }

  List<int> getAvailableRatingCounts() {
    Set<int> ratingCounts = contractorsByService
        .map((c) => c.rating?.timesRated ?? 0)
        .where((count) => count > 0)
        .toSet();

    List<int> sortedCounts = ratingCounts.toList()..sort();

    // Return useful thresholds
    List<int> thresholds = [1, 5, 10, 20, 50];
    return thresholds
        .where((threshold) => sortedCounts.any((count) => count >= threshold))
        .toList();
  }

  // Toggle subcategory selection
  void toggleSubcategorySelection(int subcategoryId) {
    if (_selectedSubcategoryIds.contains(subcategoryId)) {
      _selectedSubcategoryIds.remove(subcategoryId);
    } else {
      _selectedSubcategoryIds.add(subcategoryId);
    }
    notifyListeners();
  }

  // Clear all subcategory selections
  void clearSubcategorySelections() {
    _selectedSubcategoryIds.clear();
    notifyListeners();
  }

  void updateContractorsByServiceSearch(String query) {
    _contractorsByServiceSearch = query;
    notifyListeners();
  }
}

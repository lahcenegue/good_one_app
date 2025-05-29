import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Features/Both/Models/account_edit_request.dart';
import 'package:good_one_app/Features/Both/Models/user_info.dart';
import 'package:good_one_app/Features/Both/Models/notification_model.dart';
import 'package:good_one_app/Features/Both/Services/both_api.dart';
import 'package:good_one_app/Features/User/Models/contractor.dart';
import 'package:good_one_app/Features/User/Models/service_category.dart';
import 'package:good_one_app/Features/User/Services/user_api.dart';
import 'package:good_one_app/Features/Auth/Services/token_manager.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserManagerProvider extends ChangeNotifier {
  // --- Authentication State ---
  String? _token;
  UserInfo? _userInfo;

  // --- Global UI State ---
  // For overall initialization or unclassified states
  String? _globalError; // Renamed from _error for clarity
  bool _isGlobalLoading = false; // Renamed from _isLoading
  int _currentIndex = 0;

  // --- Form Controllers ---
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- Image Picker State ---
  File? _selectedImage;
  String? _imageError;
  final ImagePicker _picker = ImagePicker();

  // --- Search State ---
  String _searchQuery = ''; // For filtering services on ServicesScreen
  String _contractorsByServiceSearch =
      ''; // For filtering contractors on ContractorsByService screen
  List<dynamic> _searchResults = [];
  bool _isSearching = false; // Loading state for search operation
  String? _searchError; // Error state for search operation
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  // --- Data Lists ---
  Contractor? _selectedContractor;
  final List<ServiceCategory> _categories = [];
  final List<Contractor> _bestContractors = [];
  final List<Contractor> _contractorsByService = [];
  final List<Contractor> _allContractorsForCurrentService = [];
  List<NotificationModel> _notifications = [];

  ServiceCategory? _currentViewedServiceCategory;

  final Set<int> _selectedSubcategoryIds = {};

  // --- NEW Specific Loading and Error States ---
  bool _isLoadingUserInfo = false;
  String? _userInfoError;

  bool _isLoadingCategories = false;
  String? _categoriesError;

  bool _isLoadingBestContractors = false;
  String? _bestContractorsError;

  bool _isLoadingContractorsByService = false;
  String? _contractorsByServiceError;

  bool _isNotificationLoading = false; // Already existed
  String? _notificationError; // Already existed

  bool _isLoadingEditAccount = false;
  String? _editAccountError;

  // --- Getters ---
  String? get token => _token;
  UserInfo? get userInfo => _userInfo;
  bool get isAuthenticated => _token != null && _userInfo != null;
  int get currentIndex => _currentIndex;

  // Global states
  String? get globalError => _globalError;
  bool get isGlobalLoading => _isGlobalLoading;

  // Image
  String? get imageError => _imageError;
  File? get selectedImage => _selectedImage;

  // Form Controllers
  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get searchController => _searchController;

  // Search
  String get searchQuery => _searchQuery; // For ServicesScreen filter
  bool get isSearching => _isSearching; // For search API call
  String? get searchError => _searchError; // For search API call
  List<dynamic> get searchResults => List.unmodifiable(_searchResults);

  // Data lists and their specific states
  Contractor? get selectedContractor => _selectedContractor;

  List<ServiceCategory> get categories => List.unmodifiable(_categories);
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoriesError => _categoriesError;

  List<Contractor> get bestContractors => List.unmodifiable(_bestContractors);
  bool get isLoadingBestContractors => _isLoadingBestContractors;
  String? get bestContractorsError => _bestContractorsError;

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

    // Then filter by search query
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

  String get contractorsByServiceSearchTerm => _contractorsByServiceSearch;
  bool get isLoadingContractorsByService => _isLoadingContractorsByService;

  String? get contractorsByServiceError => _contractorsByServiceError;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isNotificationLoading => _isNotificationLoading;
  String? get notificationError => _notificationError;

  bool get isLoadingUserInfo => _isLoadingUserInfo;
  String? get userInfoError => _userInfoError;

  bool get isLoadingEditAccount => _isLoadingEditAccount;
  String? get editAccountError => _editAccountError;
  ServiceCategory? get currentViewedServiceCategory =>
      _currentViewedServiceCategory;
  Set<int> get selectedSubcategoryIds =>
      Set.unmodifiable(_selectedSubcategoryIds);

  // --- Constructor ---
  UserManagerProvider() {
    initialize();
    _searchController.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchInputChanged);
    _searchController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Search input change listener with debounce
  void _onSearchInputChanged() {
    final query = _searchController.text.trim();
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      _searchResults = [];
      _searchError = null; // Clear search error when query is empty
      notifyListeners();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchServiceAndContractor(query);
    });
  }

  // --- Initialization ---
  Future<void> initialize() async {
    setGlobalError(null);
    setGlobalLoading(true); // Manages _isGlobalLoading and notifies

    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);

      List<Future<void>> tasks = [];
      // Task 1: Fetch public data (categories, best contractors)
      tasks.add(_fetchPublicData());

      if (_token != null) {
        // Task 2: Load user-specific data (user info)
        tasks.add(
            _loadUserDataInternal()); // Renamed to avoid conflict if a public _loadUserData is needed
        // Task 3: Fetch notifications
        tasks.add(fetchNotifications());
      }

      // Wait for all top-level tasks to complete.
      // These tasks are responsible for setting their own specific error/loading flags
      // and should catch their operational errors internally.
      await Future.wait(tasks.map((task) => task.catchError((e) {
            debugPrint(
                'A main initialization task failed unexpectedly: $e. This should have been caught internally by the task.');
            // This catchError is a safety net. The task itself should have set its specific error.
            // Optionally, set a global error if any main task has an unhandled failure.
            // setGlobalError("A part of app data could not be loaded.");
          })));
    } catch (e) {
      // Catches errors like StorageManager failure or truly unhandled ones from above.
      setGlobalError('Critical app initialization failed: ${e.toString()}');
    } finally {
      setGlobalLoading(false);
    }
  }

  // --- State Management Helpers ---
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> clearData() async {
    _token = null;
    _userInfo = null;
    _userInfoError = null;
    // Clear other user-specific data if necessary
    await StorageManager.remove(StorageKeys.tokenKey);
    await StorageManager.remove(StorageKeys.accountTypeKey);
    await TokenManager.instance.clearToken();
    _currentIndex = 0;
    notifyListeners();
  }

  void setGlobalLoading(bool value) {
    _isGlobalLoading = value;
    notifyListeners();
  }

  void setGlobalError(String? message) {
    _globalError = message;
    notifyListeners();
  }

  void setImageError(String? message) {
    _imageError = message;
    notifyListeners();
  }

  // --- User Info ---
  Future<void> _loadUserDataInternal() async {
    // This method is part of initialize(), manages _isLoadingUserInfo and _userInfoError
    if (_token == null) {
      _userInfoError =
          "Not authenticated to load user data."; // Should not happen if called correctly
      notifyListeners();
      return;
    }

    _isLoadingUserInfo = true;
    _userInfoError = null;
    notifyListeners();

    try {
      final userInfoSuccess = await _fetchUserInfoInternalLogic();

      if (userInfoSuccess) {
        _initializeControllers();
      } else {
        // _userInfoError would have been set by _fetchUserInfoInternalLogic or token refresh logic
        final refreshed = await TokenManager.instance.refreshToken();
        if (refreshed) {
          _token = TokenManager.instance.token; // Update token
          final refreshedUserInfoSuccess = await _fetchUserInfoInternalLogic();
          if (refreshedUserInfoSuccess) {
            _initializeControllers();
          } else {
            _userInfoError = _userInfoError ??
                'Failed to fetch user info after token refresh.';
          }
          // It's good practice to also re-fetch data that might depend on user context
          // or that might have failed previously due to auth issues.
          // await _fetchPublicData(); // Consider if needed here, or rely on initial call.
        } else {
          await clearData(); // Clears user data, token
          _userInfoError =
              _userInfoError ?? 'Session expired. Please log in again.';
          // _fetchPublicData(); // Public data should still be available
          _currentIndex =
              3; // Example: Navigate to profile/login indicate a problem
        }
      }
    } catch (e) {
      _userInfoError = 'Exception loading user data: ${e.toString()}';
    } finally {
      _isLoadingUserInfo = false;
      notifyListeners();
    }
  }

  Future<bool> _fetchUserInfoInternalLogic() async {
    // This is the core API call logic for user info
    // Assumes _token is valid and available.
    // Sets _userInfoError on failure.
    _isLoadingUserInfo =
        true; // Can be set here or by caller (_loadUserDataInternal)
    _userInfoError = null; // Clear previous error for this specific operation
    // notifyListeners(); // Caller will notify

    try {
      final response = await BothApi.getUserInfo();
      if (response.success && response.data != null) {
        _userInfo = response.data;
        _userInfoError = null;
        // notifyListeners(); // Caller will notify
        return true;
      } else {
        _userInfoError = 'Failed to fetch user info';
        return false;
      }
    } catch (e) {
      _userInfoError = 'Exception fetching user info: ${e.toString()}';
      return false;
    } finally {
      _isLoadingUserInfo = false; // Managed by caller (_loadUserDataInternal)
      notifyListeners(); // Caller will notify
    }
  }

  void _initializeControllers() {
    final user = _userInfo;
    _fullNameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone?.toString() ?? '';
    _cityController.text = user?.city ?? '';
    _countryController.text = user?.country ?? '';
  }

  Future<bool> editAccount(BuildContext context) async {
    _isLoadingEditAccount = true;
    _editAccountError = null;
    notifyListeners();

    try {
      final request = AccountEditRequest(
        image: _selectedImage,
        fullName: fullNameController.text == _userInfo!.fullName
            ? null
            : fullNameController.text,
        email: emailController.text == _userInfo!.email
            ? null
            : emailController.text,
        phone: phoneController.text == (_userInfo!.phone.toString())
            ? null
            : int.tryParse(phoneController.text),
        password:
            passwordController.text.isEmpty ? null : passwordController.text,
      );

      final response = await BothApi.editAccount(request);
      if (response.success && response.data != null) {
        _userInfo = response.data;
        _initializeControllers();
        _selectedImage = null;
        setImageError(null); // Clears image-specific error
        _editAccountError = null;
        notifyListeners();
        return true;
      }
      _editAccountError = 'Failed to edit account';
      return false;
    } catch (e) {
      _editAccountError = 'Exception editing account: ${e.toString()}';
      return false;
    } finally {
      _isLoadingEditAccount = false;
      notifyListeners();
    }
  }

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    // _imageError and _selectedImage are already specific
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (image != null) {
        _selectedImage = File(image.path);
        setImageError(null); // Clear specific image error
      }
    } catch (e) {
      if (context.mounted) {
        setImageError(AppLocalizations.of(context)!.generalError);
      }
    } finally {
      notifyListeners(); // Notify UI of changes to _selectedImage or _imageError
    }
  }

  // --- Categories and Contractors ---
  Future<void> _fetchPublicData() async {
    // This method orchestrates fetching data that doesn't require auth.
    // It calls individual fetch methods which manage their own state.
    await Future.wait([
      fetchCategories().catchError(
          (e) => debugPrint("fetchCategories failed in _fetchPublicData: $e")),
      fetchBestContractors().catchError((e) =>
          debugPrint("fetchBestContractors failed in _fetchPublicData: $e")),
    ]);
  }

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _categoriesError = null;
    notifyListeners();
    try {
      final response = await UserApi.getCategories();
      if (response.success && response.data != null) {
        _categories.clear();
        _categories.addAll(response.data!);
        _categoriesError = null;
      } else {
        _categoriesError = 'Failed to fetch categories';
      }
    } catch (e) {
      _categoriesError = 'Exception fetching categories: ${e.toString()}';
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchBestContractors() async {
    _isLoadingBestContractors = true;
    _bestContractorsError = null;
    notifyListeners();
    try {
      final response = await UserApi.getBestContractors();

      if (response.success && response.data != null) {
        _bestContractors.clear();
        _bestContractors.addAll(response.data!);
        _bestContractorsError = null;
      } else {
        _bestContractorsError = 'Failed to fetch best contractors';
      }
    } catch (e) {
      _bestContractorsError =
          'Exception fetching best contractors: ${e.toString()}';
    } finally {
      _isLoadingBestContractors = false;
      notifyListeners();
    }
  }

  Future<void> fetchContractorsByService(int? serviceId) async {
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
            _categories.firstWhere((cat) => cat.id == serviceId);
      } catch (e) {
        _currentViewedServiceCategory = null;
        debugPrint(
            "UserManagerProvider: Service category with ID $serviceId not found in local _categories cache. Subcategory chips might not be available.");
      }

      final response = await UserApi.getContractorsByService(id: serviceId);
      if (response.success && response.data != null) {
        _allContractorsForCurrentService.addAll(response.data!);
        _contractorsByServiceError = null;
        debugPrint(
            "UserManagerProvider: _allContractorsForCurrentService populated with ${_allContractorsForCurrentService.length} contractors for service ID $serviceId.");
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

  Future<void> searchServiceAndContractor(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }
    _isSearching = true;
    _searchError = null;
    notifyListeners();
    try {
      final response = await UserApi.search(query);
      if (response.success && response.data != null) {
        _searchResults.clear();
        _searchResults.addAll(response.data!);
        _searchError = null;
      } else {
        _searchError = 'Failed fetching search results';
      }
    } catch (e) {
      _searchError = 'Exception fetching search results: ${e.toString()}';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void setSelectedContractor(Contractor contractor) {
    _selectedContractor = contractor;
    notifyListeners();
  }

  void clearSelectedContractor() {
    _selectedContractor = null;
    notifyListeners();
  }

  // --- Notifications ---
  Future<void> fetchNotifications() async {
    _isNotificationLoading = true; // Uses existing specific loading
    _notificationError = null; // Uses existing specific error
    notifyListeners();
    try {
      debugPrint('Fetching notifications...');
      final response = await BothApi.fetchNotifications();
      if (response.success && response.data != null) {
        _notifications = response.data!;
        _notificationError = null;
      } else {
        _notificationError = 'Failed to load notifications';
      }
    } catch (e) {
      _notificationError = 'Exception fetching notifications: ${e.toString()}';
    } finally {
      _isNotificationLoading = false;
      notifyListeners();
    }
  }

  // --- Search Query Filters ---
  void searchServicesQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateContractorsByServiceSearch(String query) {
    _contractorsByServiceSearch = query;
    notifyListeners();
  }

  // bool _matchesSearchQuery(Contractor contractor) {
  //   final query = _contractorsByServiceSearch.toLowerCase();
  //   return contractor.fullName!.toLowerCase().contains(query) ||
  //       (contractor.service?.toLowerCase().contains(query) ??
  //           false); // Added null check for service
  // }
}

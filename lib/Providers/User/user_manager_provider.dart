import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/infrastructure/Services/token_manager.dart';
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

import 'package:good_one_app/l10n/app_localizations.dart';

class UserManagerProvider extends ChangeNotifier {
  // ================================
  // PRIVATE FIELDS
  // ================================

  // Authentication State
  String? _token;
  UserInfo? _userInfo;

  // Global UI State
  String? _globalError;
  bool _isGlobalLoading = false;
  int _currentIndex = 0;

  // Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Image Handling State
  File? _selectedImage;
  String? _imageError;
  final ImagePicker _picker = ImagePicker();

  // Search State
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _searchDebounce;

  // Data Collections
  Contractor? _selectedContractor;
  final List<ServiceCategory> _categories = [];
  final List<Contractor> _bestContractors = [];
  List<NotificationModel> _notifications = [];

  // Loading States
  bool _isLoadingUserInfo = false;
  bool _isLoadingCategories = false;
  bool _isLoadingBestContractors = false;
  bool _isNotificationLoading = false;
  bool _isLoadingEditAccount = false;

  // Error States
  String? _userInfoError;
  String? _categoriesError;
  String? _bestContractorsError;
  String? _notificationError;
  String? _editAccountError;

  // Feature States
  String _homeScreenSortBy = 'default';
  int _newNotificationCount = 0;

  // ================================
  // GETTERS
  // ================================

  // Authentication Getters
  String? get token => _token;
  UserInfo? get userInfo => _userInfo;
  bool get isAuthenticated => _token != null && _userInfo != null;

  // UI State Getters
  int get currentIndex => _currentIndex;
  String? get globalError => _globalError;
  bool get isGlobalLoading => _isGlobalLoading;

  // Form Controller Getters
  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get searchController => _searchController;

  // Image State Getters
  String? get imageError => _imageError;
  File? get selectedImage => _selectedImage;

  // Search State Getters
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  List<dynamic> get searchResults => List.unmodifiable(_searchResults);

  // Data Collection Getters
  Contractor? get selectedContractor => _selectedContractor;
  List<ServiceCategory> get categories => List.unmodifiable(_categories);
  List<Contractor> get bestContractors => List.unmodifiable(_bestContractors);
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  // Loading State Getters
  bool get isLoadingUserInfo => _isLoadingUserInfo;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingBestContractors => _isLoadingBestContractors;
  bool get isNotificationLoading => _isNotificationLoading;
  bool get isLoadingEditAccount => _isLoadingEditAccount;

  // Error State Getters
  String? get userInfoError => _userInfoError;
  String? get categoriesError => _categoriesError;
  String? get bestContractorsError => _bestContractorsError;
  String? get notificationError => _notificationError;
  String? get editAccountError => _editAccountError;

  // Feature State Getters
  String get homeScreenSortBy => _homeScreenSortBy;
  int get unreadNotificationCount => _newNotificationCount;

  // ================================
  // CONSTRUCTOR & INITIALIZATION
  // ================================

  UserManagerProvider() {
    _initialize();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// Initialize the provider with all necessary data
  Future<void> initialize() async {
    debugPrint('UserManager: Starting initialization');

    _setGlobalLoading(true);
    _setGlobalError(null);

    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);

      // Prepare initialization tasks
      final List<Future<void>> tasks = [_fetchPublicData()];

      if (_token != null) {
        // Only fetch user info if not already set
        if (_userInfo == null) {
          tasks.add(_loadUserDataInternal());
        }

        tasks.addAll([
          _initializeNotifications(),
          _validateUserType(),
        ]);
      }

      // Execute all tasks with error isolation
      await Future.wait(tasks.map((task) => task.catchError((error) {
            debugPrint(
                'UserManager: Task failed during initialization: $error');
          })));

      debugPrint('UserManager: Initialization completed successfully');
    } catch (error) {
      final errorMessage = 'Critical app initialization failed: $error';
      debugPrint('UserManager: $errorMessage');
      _setGlobalError(errorMessage);
    } finally {
      _setGlobalLoading(false);
    }
  }

  /// Enhanced user type validation with server verification
  Future<void> _validateUserType() async {
    try {
      if (_userInfo?.type == null) {
        debugPrint('UserManager: User type is null, skipping validation');
        return;
      }

      // ADD THESE DEBUG LINES
      debugPrint('UserManager: _userInfo.type = "${_userInfo!.type}"');
      debugPrint('UserManager: AppConfig.customer = "${AppConfig.customer}"');
      debugPrint(
          'UserManager: Types match: ${_userInfo!.type == AppConfig.customer}');

      if (_userInfo!.type != AppConfig.customer) {
        debugPrint(
            'UserManager: User type mismatch detected. Expected ${AppConfig.customer}, got ${_userInfo!.type}');
        await _clearDataAndRedirect(AppRoutes.workerMain);
      } else {
        debugPrint('UserManager: User type validation passed');
      }
    } catch (error) {
      debugPrint('UserManager: Error during user type validation: $error');
    }
  }

  /// Initialize notifications
  Future<void> _initializeNotifications() async {
    try {
      await Future.wait([
        fetchNotifications(),
        _fetchNotificationCount(),
      ]);
    } catch (error) {
      debugPrint('UserManager: Failed to initialize notifications: $error');
    }
  }

  /// Set user data directly (called during login to avoid null states)
  void setUserDataDirectly(UserInfo userData) {
    _userInfo = userData;
    _initializeFormControllers();
    notifyListeners();
    debugPrint('UserManager: User data set directly from login');
  }

  /// Private initialization helper
  void _initialize() {
    initialize();
  }

  /// Setup search input listener with debouncing
  void _setupSearchListener() {
    _searchController.addListener(_onSearchInputChanged);
  }

  /// Cleanup all resources
  void _cleanupResources() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchInputChanged);

    // Dispose all controllers
    _searchController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
  }

  // ================================
  // STATE MANAGEMENT METHODS
  // ================================

  /// Set current navigation index
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Clear all user data and navigate to specified route
  Future<void> _clearDataAndRedirect(String route) async {
    try {
      await clearData();
      await NavigationService.navigateToAndReplace(route);
    } catch (error) {
      debugPrint('UserManager: Error during clear and redirect: $error');
    }
  }

  /// Enhanced clear data method
  Future<void> clearData() async {
    try {
      // Clear authentication state
      _token = null;
      _userInfo = null;
      _userInfoError = null;

      // Clear notifications data
      _notifications.clear();
      _notificationError = null;
      _isNotificationLoading = false;
      _newNotificationCount = 0;

      // Clear storage
      await Future.wait([
        StorageManager.remove(StorageKeys.tokenKey),
        StorageManager.remove(StorageKeys.accountTypeKey),
        TokenManager.instance.clearAuthToken(),
      ]);

      // Reset UI state
      _currentIndex = 0;

      notifyListeners();
      debugPrint('UserManager: Data cleared successfully');
    } catch (error) {
      debugPrint('UserManager: Error clearing data: $error');
    }
  }

  /// Set global loading state
  void _setGlobalLoading(bool value) {
    if (_isGlobalLoading != value) {
      _isGlobalLoading = value;
      notifyListeners();
    }
  }

  /// Set global error state
  void _setGlobalError(String? message) {
    if (_globalError != message) {
      _globalError = message;
      notifyListeners();
    }
  }

  /// Set image error state
  void setImageError(String? message) {
    if (_imageError != message) {
      _imageError = message;
      notifyListeners();
    }
  }

  // ================================
  // USER DATA MANAGEMENT
  // ================================

  /// Load user data with enhanced error handling and token refresh
  Future<void> _loadUserDataInternal() async {
    if (_token == null) {
      _setUserInfoError("Authentication required to load user data");
      return;
    }

    _setUserInfoLoading(true);
    _setUserInfoError(null);

    try {
      bool userInfoSuccess = await _fetchUserInfoInternalLogic();

      if (userInfoSuccess) {
        _initializeFormControllers();
        debugPrint('UserManager: User data loaded successfully');
      } else {
        // Attempt token refresh
        final refreshed = await TokenManager.instance.refreshAuthToken();

        if (refreshed) {
          _token = TokenManager.instance.accessToken;
          userInfoSuccess = await _fetchUserInfoInternalLogic();

          if (userInfoSuccess) {
            _initializeFormControllers();
            debugPrint('UserManager: User data loaded after token refresh');
          } else {
            _setUserInfoError('Failed to fetch user info after token refresh');
          }
        } else {
          // Token refresh failed, clear data and redirect
          await _clearDataAndRedirect(AppRoutes.login);
          _setUserInfoError('Session expired. Please log in again');
        }
      }
    } catch (error) {
      _setUserInfoError('Exception loading user data: $error');
    } finally {
      _setUserInfoLoading(false);
    }
  }

  /// Fetch user info from API
  Future<bool> _fetchUserInfoInternalLogic() async {
    try {
      final response = await BothApi.getUserInfo();

      if (response.success && response.data != null) {
        _userInfo = response.data;
        _setUserInfoError(null);
        return true;
      } else {
        _setUserInfoError(response.error ?? 'Failed to fetch user info');
        return false;
      }
    } catch (error) {
      _setUserInfoError('Exception fetching user info: $error');
      return false;
    }
  }

  /// Initialize form controllers with user data
  void _initializeFormControllers() {
    if (_userInfo == null) return;

    _fullNameController.text = _userInfo!.fullName ?? '';
    _emailController.text = _userInfo!.email ?? '';
    _phoneController.text = _userInfo!.phone?.toString() ?? '';
    _cityController.text = _userInfo!.city ?? '';
    _countryController.text = _userInfo!.country ?? '';

    debugPrint('UserManager: Form controllers initialized');
  }

  /// Edit user account with comprehensive validation
  Future<bool> editAccount(BuildContext context) async {
    if (_userInfo == null) {
      _setEditAccountError('User information not available');
      return false;
    }

    _setEditAccountLoading(true);
    _setEditAccountError(null);

    try {
      final request = AccountEditRequest(
        image: _selectedImage,
        fullName:
            _getChangedValue(_fullNameController.text, _userInfo!.fullName),
        email: _getChangedValue(_emailController.text, _userInfo!.email),
        phone: _getChangedPhoneValue(),
        password:
            _passwordController.text.isEmpty ? null : _passwordController.text,
      );

      final response = await BothApi.editAccount(request);

      if (response.success && response.data != null) {
        _userInfo = response.data;
        _initializeFormControllers();
        _selectedImage = null;
        setImageError(null);
        _setEditAccountError(null);

        debugPrint('UserManager: Account edited successfully');
        return true;
      } else {
        _setEditAccountError(response.error ?? 'Failed to edit account');
        return false;
      }
    } catch (error) {
      _setEditAccountError('Exception editing account: $error');
      return false;
    } finally {
      _setEditAccountLoading(false);
    }
  }

  /// Helper method to get changed values
  String? _getChangedValue(String newValue, String? currentValue) {
    return newValue.trim() == (currentValue ?? '') ? null : newValue.trim();
  }

  /// Helper method to get changed phone value
  int? _getChangedPhoneValue() {
    final phoneText = _phoneController.text.trim();
    final currentPhone = _userInfo!.phone?.toString() ?? '';

    if (phoneText == currentPhone) return null;
    return int.tryParse(phoneText);
  }

  /// Pick image with enhanced error handling
  Future<void> pickImage(BuildContext context, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        setImageError(null);
        debugPrint('UserManager: Image selected successfully');
      }
    } catch (error) {
      if (context.mounted) {
        setImageError(AppLocalizations.of(context)!.generalError);
      }
      debugPrint('UserManager: Error picking image: $error');
    } finally {
      notifyListeners();
    }
  }

  // ================================
  // LOADING AND ERROR STATE SETTERS
  // ================================

  void _setUserInfoLoading(bool value) {
    if (_isLoadingUserInfo != value) {
      _isLoadingUserInfo = value;
      notifyListeners();
    }
  }

  void _setUserInfoError(String? error) {
    if (_userInfoError != error) {
      _userInfoError = error;
      notifyListeners();
    }
  }

  void _setEditAccountLoading(bool value) {
    if (_isLoadingEditAccount != value) {
      _isLoadingEditAccount = value;
      notifyListeners();
    }
  }

  void _setEditAccountError(String? error) {
    if (_editAccountError != error) {
      _editAccountError = error;
      notifyListeners();
    }
  }

// ================================
  // PUBLIC DATA FETCHING METHODS
  // ================================

  /// Fetch public data (categories and contractors)
  Future<void> _fetchPublicData() async {
    try {
      await Future.wait([
        fetchCategories().catchError((error) {
          debugPrint("UserManager: fetchCategories failed: $error");
        }),
        fetchBestContractors().catchError((error) {
          debugPrint("UserManager: fetchBestContractors failed: $error");
        }),
      ]);
    } catch (error) {
      debugPrint('UserManager: Error fetching public data: $error');
    }
  }

  /// Fetch service categories with enhanced error handling
  Future<void> fetchCategories() async {
    _setCategoriesLoading(true);
    _setCategoriesError(null);

    try {
      final response = await UserApi.getCategories();

      if (response.success && response.data != null) {
        _categories.clear();
        _categories.addAll(response.data!);
        _setCategoriesError(null);
        debugPrint('UserManager: Loaded ${_categories.length} categories');
      } else {
        _setCategoriesError(response.error ?? 'Failed to fetch categories');
      }
    } catch (error) {
      _setCategoriesError('Exception fetching categories: $error');
    } finally {
      _setCategoriesLoading(false);
    }
  }

  /// Fetch best contractors with enhanced error handling
  Future<void> fetchBestContractors() async {
    _setBestContractorsLoading(true);
    _setBestContractorsError(null);

    try {
      final response = await UserApi.getBestContractors();

      if (response.success && response.data != null) {
        _bestContractors.clear();
        _bestContractors.addAll(response.data!);
        _setBestContractorsError(null);
        debugPrint(
            'UserManager: Loaded ${_bestContractors.length} contractors');
      } else {
        _setBestContractorsError(
            response.error ?? 'Failed to fetch best contractors');
      }
    } catch (error) {
      _setBestContractorsError('Exception fetching best contractors: $error');
    } finally {
      _setBestContractorsLoading(false);
    }
  }

  // ================================
  // SEARCH FUNCTIONALITY
  // ================================

  /// Handle search input changes with debouncing
  void _onSearchInputChanged() {
    final query = _searchController.text.trim();
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _clearSearchResults();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchServiceAndContractor(query);
    });
  }

  /// Search for services and contractors
  Future<void> searchServiceAndContractor(String query) async {
    if (query.trim().isEmpty) {
      _clearSearchResults();
      return;
    }

    _setSearching(true);
    _setSearchError(null);

    try {
      final response = await UserApi.search(query.trim());

      if (response.success && response.data != null) {
        _searchResults.clear();
        _searchResults.addAll(response.data!);
        _setSearchError(null);
        debugPrint(
            'UserManager: Found ${_searchResults.length} search results');
      } else {
        _setSearchError(response.error ?? 'Failed to fetch search results');
      }
    } catch (error) {
      _setSearchError('Exception fetching search results: $error');
    } finally {
      _setSearching(false);
    }
  }

  /// Set search query for filtering
  void searchServicesQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  /// Clear search results
  void _clearSearchResults() {
    _searchResults.clear();
    _setSearchError(null);
    notifyListeners();
  }

  // ================================
  // CONTRACTOR MANAGEMENT
  // ================================

  /// Set selected contractor
  void setSelectedContractor(Contractor contractor) {
    if (_selectedContractor != contractor) {
      _selectedContractor = contractor;
      notifyListeners();
    }
  }

  /// Clear selected contractor
  void clearSelectedContractor() {
    if (_selectedContractor != null) {
      _selectedContractor = null;
      notifyListeners();
    }
  }

  // ================================
  // HOME SCREEN SORTING
  // ================================

  /// Set home screen sort criteria
  void setHomeScreenSortBy(String sortBy) {
    if (_homeScreenSortBy != sortBy) {
      _homeScreenSortBy = sortBy;
      notifyListeners();
    }
  }

  /// Get sorted best contractors based on current sort criteria
  List<Contractor> getSortedBestContractors() {
    List<Contractor> sortedContractors = List.from(_bestContractors);

    switch (_homeScreenSortBy) {
      case 'rating':
        sortedContractors.sort(
            (a, b) => (b.rating?.rating ?? 0).compareTo(a.rating?.rating ?? 0));
        break;
      case 'price_asc':
        sortedContractors =
            _sortContractorsByPrice(sortedContractors, ascending: true);
        break;
      case 'price_desc':
        sortedContractors =
            _sortContractorsByPrice(sortedContractors, ascending: false);
        break;
      case 'orders':
        sortedContractors
            .sort((a, b) => (b.orders ?? 0).compareTo(a.orders ?? 0));
        break;
      case 'hourly':
        sortedContractors =
            _filterAndSortByPricingType(sortedContractors, 'hourly');
        break;
      case 'daily':
        sortedContractors =
            _filterAndSortByPricingType(sortedContractors, 'daily');
        break;
      case 'fixed':
        sortedContractors =
            _filterAndSortByPricingType(sortedContractors, 'fixed');
        break;
      case 'default':
      default:
        // Keep original order
        break;
    }

    return List.unmodifiable(sortedContractors);
  }

  /// Filter and sort contractors by pricing type
  List<Contractor> _filterAndSortByPricingType(
    List<Contractor> contractors,
    String pricingType,
  ) {
    final List<Contractor> withPricingType = [];
    final List<Contractor> withoutPricingType = [];

    for (final contractor in contractors) {
      final effectiveType = contractor.getEffectivePricingType();
      if (effectiveType == pricingType) {
        withPricingType.add(contractor);
      } else {
        withoutPricingType.add(contractor);
      }
    }

    final sortedWithType =
        _sortContractorsByPrice(withPricingType, ascending: true);
    return [...sortedWithType, ...withoutPricingType];
  }

  /// Sort contractors by price
  List<Contractor> _sortContractorsByPrice(
    List<Contractor> contractors, {
    bool ascending = true,
  }) {
    contractors.sort((a, b) {
      final priceA = a.getPrimaryPrice();
      final priceB = b.getPrimaryPrice();

      if (priceA == null && priceB == null) return 0;
      if (priceA == null) return 1;
      if (priceB == null) return -1;

      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });

    return contractors;
  }

  // ================================
  // NOTIFICATION MANAGEMENT
  // ================================

  /// Fetch notifications with enhanced error handling
  Future<void> fetchNotifications() async {
    _setNotificationLoading(true);
    _setNotificationError(null);

    try {
      debugPrint('UserManager: Fetching notifications...');
      final response = await BothApi.fetchNotifications();

      if (response.success && response.data != null) {
        _notifications = response.data!;
        _updateNewNotificationCount();
        _setNotificationError(null);

        debugPrint(
            'UserManager: Loaded ${_notifications.length} notifications, '
            '$_newNotificationCount new');
      } else {
        _setNotificationError(response.error ?? 'Failed to load notifications');
      }
    } catch (error) {
      _setNotificationError('Exception fetching notifications: $error');
    } finally {
      _setNotificationLoading(false);
    }
  }

  /// Fetch notification counts from server
  Future<void> fetchNotificationCounts() async {
    try {
      debugPrint('UserManager: Fetching notification counts...');

      final results = await Future.wait([
        BothApi.getNewNotificationsCount(),
        BothApi.getUnreadNotificationsCount(),
      ]);

      final newCountResponse = results[0];
      bool hasChanges = false;

      if (newCountResponse.success && newCountResponse.data != null) {
        final newCount = newCountResponse.data!;
        if (_newNotificationCount != newCount) {
          _newNotificationCount = newCount;
          hasChanges = true;
          debugPrint(
              'UserManager: Updated new notification count: $_newNotificationCount');
        }
      }

      if (hasChanges) {
        notifyListeners();
      }
    } catch (error) {
      debugPrint('UserManager: Exception in fetchNotificationCounts: $error');
    }
  }

  /// Mark all notifications as seen (when entering notifications screen)
  Future<void> markAllNotificationsAsSeenNew() async {
    debugPrint('UserManager: markAllNotificationsAsSeenNew called. '
        'Current new count: $_newNotificationCount');

    if (_newNotificationCount == 0) {
      debugPrint('UserManager: No new notifications to mark as seen');
      return;
    }

    try {
      // Optimistic update for better UX
      final oldNewCount = _newNotificationCount;
      _updateNotificationsSeenStatus();

      debugPrint('UserManager: Optimistically updated UI - '
          'marked $oldNewCount notifications as seen');

      // Sync with backend
      final response = await BothApi.markNotificationsAsSeen();

      if (response.success) {
        debugPrint('UserManager: Successfully synced seen status with backend');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'UserManager: Failed to sync seen status: ${response.error}');
        // Revert optimistic update on failure
        _revertNotificationsSeenStatus(oldNewCount);
      }
    } catch (error) {
      debugPrint(
          'UserManager: Exception in markAllNotificationsAsSeenNew: $error');
    }
  }

  /// Mark specific notifications as read
  Future<void> markNotificationsAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) {
      debugPrint('UserManager: No notification IDs provided');
      return;
    }

    try {
      debugPrint(
          'UserManager: Marking ${notificationIds.length} notifications as read');

      // Optimistic update
      _updateSpecificNotificationsReadStatus(notificationIds);

      // Sync with backend
      final response = await BothApi.markNotificationsAsRead(notificationIds);

      if (response.success) {
        debugPrint(
            'UserManager: Successfully marked specific notifications as read');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'UserManager: Failed to mark specific notifications as read: ${response.error}');
        await fetchNotifications(); // Refresh to get correct state
      }
    } catch (error) {
      debugPrint('UserManager: Exception in markNotificationsAsRead: $error');
      await fetchNotifications(); // Refresh to get correct state
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    debugPrint('UserManager: markAllNotificationsAsRead called. '
        'Current new count: $_newNotificationCount');

    if (_newNotificationCount == 0) {
      debugPrint('UserManager: No new notifications to mark as read');
      return;
    }

    try {
      // Optimistic update
      _updateAllNotificationsReadStatus();

      debugPrint(
          'UserManager: Optimistically updated UI - marked all notifications as read');

      // Sync with backend
      final response = await BothApi.markAllNotificationsAsRead();

      if (response.success) {
        debugPrint('UserManager: Successfully synced read status with backend');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'UserManager: Failed to sync read status: ${response.error}');
        await fetchNotifications(); // Refresh to get correct state
      }
    } catch (error) {
      debugPrint(
          'UserManager: Exception in markAllNotificationsAsRead: $error');
    }
  }

  /// Clear notification error
  void clearNotificationError() {
    _setNotificationError(null);
  }

  // ================================
  // PRIVATE HELPER METHODS
  // ================================

  /// Fetch notification count from server
  Future<void> _fetchNotificationCount() async {
    try {
      final response = await BothApi.getNewNotificationsCount();
      if (response.success && response.data != null) {
        _newNotificationCount = response.data!;
      }
    } catch (error) {
      debugPrint('UserManager: Error fetching notification count: $error');
    }
  }

  /// Update new notification count based on local data
  void _updateNewNotificationCount() {
    _newNotificationCount = _notifications.where((n) => n.isNew).length;
  }

  /// Update notifications seen status (optimistic update)
  void _updateNotificationsSeenStatus() {
    final updatedNotifications = _notifications
        .map((notification) => notification.copyWith(
              isNew: false,
              seenAt: DateTime.now(),
            ))
        .toList();

    _notifications = updatedNotifications;
    _newNotificationCount = 0;
    notifyListeners();
  }

  /// Revert notifications seen status (rollback optimistic update)
  void _revertNotificationsSeenStatus(int oldNewCount) {
    final revertedNotifications = _notifications
        .map((notification) => notification.copyWith(
              isNew: true,
              seenAt: null,
            ))
        .toList();

    _notifications = revertedNotifications;
    _newNotificationCount = oldNewCount;
    notifyListeners();
  }

  /// Update specific notifications read status (optimistic update)
  void _updateSpecificNotificationsReadStatus(List<String> notificationIds) {
    final updatedNotifications = _notifications.map((notification) {
      if (notificationIds.contains(notification.id)) {
        return notification.copyWith(
          isNew: false,
          isRead: true,
          seenAt: notification.seenAt ?? DateTime.now(),
          readAt: DateTime.now(),
        );
      }
      return notification;
    }).toList();

    _notifications = updatedNotifications;
    _updateNewNotificationCount();
    notifyListeners();
  }

  /// Update all notifications read status (optimistic update)
  void _updateAllNotificationsReadStatus() {
    final updatedNotifications = _notifications
        .map((notification) => notification.copyWith(
              isNew: false,
              isRead: true,
              seenAt: notification.seenAt ?? DateTime.now(),
              readAt: DateTime.now(),
            ))
        .toList();

    _notifications = updatedNotifications;
    _newNotificationCount = 0;
    notifyListeners();
  }

  // ================================
  // LOADING AND ERROR STATE SETTERS
  // ================================

  void _setCategoriesLoading(bool value) {
    if (_isLoadingCategories != value) {
      _isLoadingCategories = value;
      notifyListeners();
    }
  }

  void _setCategoriesError(String? error) {
    if (_categoriesError != error) {
      _categoriesError = error;
      notifyListeners();
    }
  }

  void _setBestContractorsLoading(bool value) {
    if (_isLoadingBestContractors != value) {
      _isLoadingBestContractors = value;
      notifyListeners();
    }
  }

  void _setBestContractorsError(String? error) {
    if (_bestContractorsError != error) {
      _bestContractorsError = error;
      notifyListeners();
    }
  }

  void _setSearching(bool value) {
    if (_isSearching != value) {
      _isSearching = value;
      notifyListeners();
    }
  }

  void _setSearchError(String? error) {
    if (_searchError != error) {
      _searchError = error;
      notifyListeners();
    }
  }

  void _setNotificationLoading(bool value) {
    if (_isNotificationLoading != value) {
      _isNotificationLoading = value;
      notifyListeners();
    }
  }

  void _setNotificationError(String? error) {
    if (_notificationError != error) {
      _notificationError = error;
      notifyListeners();
    }
  }
}

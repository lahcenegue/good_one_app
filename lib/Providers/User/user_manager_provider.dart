import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';
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

import 'package:provider/provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class UserManagerProvider extends ChangeNotifier {
  // --- Authentication State ---
  String? _token;
  UserInfo? _userInfo;

  // --- Global UI State ---
  String? _globalError;
  bool _isGlobalLoading = false;
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
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  // --- Data Lists ---
  Contractor? _selectedContractor;
  final List<ServiceCategory> _categories = [];
  final List<Contractor> _bestContractors = [];
  List<NotificationModel> _notifications = [];

  // --- Specific Loading and Error States ---
  bool _isLoadingUserInfo = false;
  String? _userInfoError;

  bool _isLoadingCategories = false;
  String? _categoriesError;

  bool _isLoadingBestContractors = false;
  String? _bestContractorsError;

  bool _isNotificationLoading = false;
  String? _notificationError;

  bool _isLoadingEditAccount = false;
  String? _editAccountError;

  // --- Home Screen Sort State ---
  String _homeScreenSortBy = 'default';

  // --- Notification Count ---
  int _newNotificationCount = 0;

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
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;
  List<dynamic> get searchResults => List.unmodifiable(_searchResults);

  // Data lists and their specific states
  Contractor? get selectedContractor => _selectedContractor;

  List<ServiceCategory> get categories => List.unmodifiable(_categories);
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoriesError => _categoriesError;

  List<Contractor> get bestContractors => List.unmodifiable(_bestContractors);
  bool get isLoadingBestContractors => _isLoadingBestContractors;
  String? get bestContractorsError => _bestContractorsError;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isNotificationLoading => _isNotificationLoading;
  String? get notificationError => _notificationError;

  /// Get the count of new notifications (never seen before)
  int get unreadNotificationCount => _newNotificationCount;

  bool get isLoadingUserInfo => _isLoadingUserInfo;
  String? get userInfoError => _userInfoError;

  bool get isLoadingEditAccount => _isLoadingEditAccount;
  String? get editAccountError => _editAccountError;

  String get homeScreenSortBy => _homeScreenSortBy;

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
      _searchError = null;
      notifyListeners();
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchServiceAndContractor(query);
    });
  }

  // --- Initialization ---
  Future<void> initialize() async {
    print(
        '======================== initialize user manager ==================');
    setGlobalError(null);
    setGlobalLoading(true);

    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);

      List<Future<void>> tasks = [];
      tasks.add(_fetchPublicData());

      if (_token != null) {
        tasks.add(_loadUserDataInternal());
        tasks.add(_initializeNotifications());
        // Initialize chat for authenticated users
        tasks.add(_initializeChat());
      }

      await Future.wait(tasks.map((task) => task.catchError((e) {
            debugPrint('A main initialization task failed unexpectedly: $e');
          })));
    } catch (e) {
      setGlobalError('Critical app initialization failed: ${e.toString()}');
    } finally {
      setGlobalLoading(false);
    }
  }

  Future<void> _initializeChat() async {
    try {
      if (_userInfo?.id != null) {
        final context = NavigationService.navigatorKey.currentContext;
        if (context != null) {
          final chatProvider =
              Provider.of<ChatProvider>(context, listen: false);
          if (!chatProvider.initialFetchComplete ||
              chatProvider.currentUserId != _userInfo!.id.toString()) {
            await chatProvider.initialize(_userInfo!.id.toString());
          }
        }
      }
    } catch (e) {
      debugPrint('UserManager: Failed to initialize chat: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    await Future.wait([
      fetchNotifications(),
      BothApi.getNewNotificationsCount().then((response) {
        if (response.success && response.data != null) {
          _newNotificationCount = response.data!;
        }
      }),
    ]);
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

    // Clear notifications data
    _notifications.clear();
    _notificationError = null;
    _isNotificationLoading = false;
    _newNotificationCount = 0;

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

  // --- Home Screen Sort Methods ---
  void setHomeScreenSortBy(String sortBy) {
    _homeScreenSortBy = sortBy;
    notifyListeners();
  }

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
        break;
    }

    return List.unmodifiable(sortedContractors);
  }

  List<Contractor> _filterAndSortByPricingType(
    List<Contractor> contractors,
    String pricingType,
  ) {
    List<Contractor> withPricingType = [];
    List<Contractor> withoutPricingType = [];

    for (var contractor in contractors) {
      String effectiveType = contractor.getEffectivePricingType();
      if (effectiveType == pricingType) {
        withPricingType.add(contractor);
      } else {
        withoutPricingType.add(contractor);
      }
    }

    withPricingType = _sortContractorsByPrice(withPricingType, ascending: true);
    return [...withPricingType, ...withoutPricingType];
  }

  List<Contractor> _sortContractorsByPrice(List<Contractor> contractors,
      {bool ascending = true}) {
    contractors.sort((a, b) {
      double? priceA = a.getPrimaryPrice();
      double? priceB = b.getPrimaryPrice();

      if (priceA == null && priceB == null) return 0;
      if (priceA == null) return 1;
      if (priceB == null) return -1;

      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });

    return contractors;
  }

  // --- User Info ---
  Future<void> _loadUserDataInternal() async {
    if (_token == null) {
      _userInfoError = "Not authenticated to load user data.";
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
        final refreshed = await TokenManager.instance.refreshToken();
        if (refreshed) {
          _token = TokenManager.instance.token;
          final refreshedUserInfoSuccess = await _fetchUserInfoInternalLogic();
          if (refreshedUserInfoSuccess) {
            _initializeControllers();
          } else {
            _userInfoError = _userInfoError ??
                'Failed to fetch user info after token refresh.';
          }
        } else {
          await clearData();
          _userInfoError =
              _userInfoError ?? 'Session expired. Please log in again.';
          _currentIndex = 3;
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
    _isLoadingUserInfo = true;
    _userInfoError = null;

    try {
      final response = await BothApi.getUserInfo();
      if (response.success && response.data != null) {
        _userInfo = response.data;
        _userInfoError = null;
        return true;
      } else {
        _userInfoError = 'Failed to fetch user info';
        return false;
      }
    } catch (e) {
      _userInfoError = 'Exception fetching user info: ${e.toString()}';
      return false;
    } finally {
      _isLoadingUserInfo = false;
      notifyListeners();
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
        setImageError(null);
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
      }
    } catch (e) {
      if (context.mounted) {
        setImageError(AppLocalizations.of(context)!.generalError);
      }
    } finally {
      notifyListeners();
    }
  }

  // --- Categories and Contractors ---
  Future<void> _fetchPublicData() async {
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
    _isNotificationLoading = true;
    _notificationError = null;
    notifyListeners();
    try {
      debugPrint('UserManager: Fetching notifications...');
      final response = await BothApi.fetchNotifications();
      if (response.success && response.data != null) {
        _notifications = response.data!;

        // Count new notifications based on local data
        _newNotificationCount = _notifications.where((n) => n.isNew).length;

        debugPrint(
            'UserManager: Loaded ${_notifications.length} notifications, $_newNotificationCount new');
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

  /// Enhanced method to fetch only notification counts (for home page badge)
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
    } catch (e) {
      debugPrint('UserManager: Exception in fetchNotificationCounts: $e');
    }
  }

  /// Enhanced mark all notifications as seen (when entering notifications screen)
  Future<void> markAllNotificationsAsSeenNew() async {
    debugPrint(
        'UserManager: markAllNotificationsAsSeenNew called. Current new count: $_newNotificationCount');

    if (_newNotificationCount == 0) {
      debugPrint('UserManager: No new notifications to mark as seen');
      return;
    }

    try {
      // Update local state immediately for better UX
      final oldNewCount = _newNotificationCount;
      final updatedNotifications = _notifications
          .map((notification) => notification.copyWith(
                isNew: false,
                seenAt: DateTime.now(),
              ))
          .toList();

      _notifications = updatedNotifications;
      _newNotificationCount = 0;

      debugPrint(
          'UserManager: Optimistically updated UI - marked $oldNewCount notifications as seen');
      notifyListeners();

      // Call the API to sync with backend
      final response = await BothApi.markNotificationsAsSeen();

      if (response.success) {
        debugPrint('UserManager: Successfully synced seen status with backend');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'UserManager: Failed to sync seen status: ${response.error}');
        // Revert optimistic update on failure
        _newNotificationCount = oldNewCount;
        _notifications = _notifications
            .map((notification) => notification.copyWith(
                  isNew: true,
                  seenAt: null,
                ))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('UserManager: Exception in markAllNotificationsAsSeenNew: $e');
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

      // Update local state immediately
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
      _newNotificationCount = _notifications.where((n) => n.isNew).length;
      notifyListeners();

      // Sync with backend
      final response = await BothApi.markNotificationsAsRead(notificationIds);

      if (response.success) {
        debugPrint(
            'UserManager: Successfully marked specific notifications as read');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'UserManager: Failed to mark specific notifications as read: ${response.error}');
        await fetchNotifications();
      }
    } catch (e) {
      debugPrint('UserManager: Exception in markNotificationsAsRead: $e');
      await fetchNotifications();
    }
  }

  /// Mark all notifications as seen (when entering notifications screen)
  Future<void> markAllNotificationsAsRead() async {
    debugPrint(
        'UserManager: markAllNotificationsAsRead called. Current new count: $_newNotificationCount');

    if (_newNotificationCount == 0) {
      debugPrint('UserManager: No new notifications to mark as read');
      return;
    }

    try {
      // Update local state immediately for better UX
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

      debugPrint(
          'UserManager: Optimistically updated UI - marked all notifications as read');
      notifyListeners();

      // Call the API to sync with backend
      final response = await BothApi.markAllNotificationsAsRead();

      if (response.success) {
        debugPrint('UserManager: Successfully synced read status with backend');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'UserManager: Failed to sync read status: ${response.error}');
        await fetchNotifications();
      }
    } catch (e) {
      debugPrint('UserManager: Exception in markAllNotificationsAsRead: $e');
    }
  }

  /// Reset notification error
  void clearNotificationError() {
    _notificationError = null;
    notifyListeners();
  }

  // --- Search Query Filters ---
  void searchServicesQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

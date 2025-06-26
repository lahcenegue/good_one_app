import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_response.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/infrastructure/Services/token_manager.dart';
import 'package:good_one_app/Features/Worker/Models/balance_model.dart';
import 'package:good_one_app/Features/Worker/Models/chart_models.dart';
import 'package:good_one_app/Features/Worker/Models/earnings_model.dart';
import 'package:good_one_app/Features/Worker/Models/withdrawal_model.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/withdrawal_result.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Features/Both/Models/account_edit_request.dart';
import 'package:good_one_app/Features/Both/Models/notification_model.dart';
import 'package:good_one_app/Features/Both/Models/user_info.dart';
import 'package:good_one_app/Features/Both/Services/both_api.dart';
import 'package:good_one_app/Features/Worker/Models/add_image_model.dart';
import 'package:good_one_app/Features/Worker/Models/category_model.dart';
import 'package:good_one_app/Features/Worker/Models/create_service_model.dart';
import 'package:good_one_app/Features/Worker/Models/my_services_model.dart';
import 'package:good_one_app/Features/Worker/Models/subcategory_model.dart';
import 'package:good_one_app/Features/Worker/Services/worker_api.dart';

import 'package:provider/provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class WorkerManagerProvider extends ChangeNotifier {
  // ================================
  // PRIVATE FIELDS
  // ================================

  // Authentication State
  String? _token;
  UserInfo? _workerInfo;

  // Error States (Section-specific)
  String? _authError;
  String? _balanceError;
  String? _withdrawalError;
  String? _profileError;
  String? _servicesError;
  String? _accountStateError;
  String? _earningsError;
  String? _addServiceError;
  String? _notificationError;
  String? _imageError;

  // UI State
  int _currentIndex = 0;
  bool _isLoading = false;

  // Loading States
  bool _isBalanceLoading = false;
  bool _isEarningsLoading = false;
  bool _isWithdrawalLoading = false;
  bool _isProfileLoading = false;
  bool _isAccountStateLoading = false;
  bool _isServiceLoading = false;
  bool _isNotificationLoading = false;

  // Financial Data
  BalanceModel? _balance;
  EarningsSummaryModel? _earningsSummary;
  List<EarningsHistoryModel> _earningsHistory = [];
  WithdrawalModel? _withdrawalModel;
  List<WithdrawStatus>? _withdrawStatus;

  // User Preferences
  bool _saveAccountInfo = true;

  // Form Controllers - Profile
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Form Controllers - Withdrawal
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transitController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  // Form Controllers - Service Management
  final TextEditingController _servicePriceController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hourlyPriceController = TextEditingController();
  final TextEditingController _dailyPriceController = TextEditingController();
  final TextEditingController _fixedPriceController = TextEditingController();

  // Image Handling
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Notifications
  List<NotificationModel> _notifications = [];
  int _newNotificationCount = 0;
  int _unreadNotificationCount = 0;
  DateTime? _lastNotificationFetch;

  // Services Management
  List<MyServicesModel> _myServices = [];
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  SubcategoryModel? _selectedSubcategory;
  List<AddImageModel> _galleryImages = [];
  bool _hasCertificate = false;
  int? _editingServiceId;
  int? _active;
  String _selectedPricingType = 'hourly';

  // ================================
  // GETTERS
  // ================================

  // Authentication Getters
  String? get token => _token;
  UserInfo? get workerInfo => _workerInfo;
  bool get isAuthenticated => _token != null && _workerInfo != null;

  // Error State Getters
  String? get authError => _authError;
  String? get balanceError => _balanceError;
  String? get withdrawalError => _withdrawalError;
  String? get profileError => _profileError;
  String? get servicesError => _servicesError;
  String? get accountStateError => _accountStateError;
  String? get earningsError => _earningsError;
  String? get addServiceError => _addServiceError;
  String? get notificationError => _notificationError;
  String? get imageError => _imageError;

  // Critical Error Check
  bool get hasCriticalError => _authError != null;
  String? get criticalError => _authError;

  // UI State Getters
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;

  // Loading State Getters
  bool get isBalanceLoading => _isBalanceLoading;
  bool get isEarningsLoading => _isEarningsLoading;
  bool get isWithdrawalLoading => _isWithdrawalLoading;
  bool get isProfileLoading => _isProfileLoading;
  bool get isAccountStateLoading => _isAccountStateLoading;
  bool get isServiceLoading => _isServiceLoading;
  bool get isNotificationLoading => _isNotificationLoading;

  // Financial Data Getters
  BalanceModel? get balance => _balance;
  EarningsSummaryModel? get earningsSummary => _earningsSummary;
  List<EarningsHistoryModel> get earningsHistory =>
      List.unmodifiable(_earningsHistory);
  WithdrawalModel? get withdrawalModel => _withdrawalModel;
  List<WithdrawStatus>? get withdrawStatus => _withdrawStatus;

  // User Preferences Getters
  bool get saveAccountInfo => _saveAccountInfo;

  // Form Controller Getters
  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get cityController => _cityController;
  TextEditingController get countryController => _countryController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get amountController => _amountController;
  TextEditingController get transitController => _transitController;
  TextEditingController get institutionController => _institutionController;
  TextEditingController get accountController => _accountController;
  TextEditingController get servicePriceController => _servicePriceController;
  TextEditingController get experienceController => _experienceController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get hourlyPriceController => _hourlyPriceController;
  TextEditingController get dailyPriceController => _dailyPriceController;
  TextEditingController get fixedPriceController => _fixedPriceController;

  // Image State Getters
  File? get selectedImage => _selectedImage;

  // Notification Getters
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadNotificationCount => _newNotificationCount;
  int get newNotificationCount => _newNotificationCount;
  int get totalUnreadCount => _unreadNotificationCount;

  // Service Management Getters
  List<MyServicesModel> get myServices => List.unmodifiable(_myServices);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  CategoryModel? get selectedCategory => _selectedCategory;
  SubcategoryModel? get selectedSubcategory => _selectedSubcategory;
  List<AddImageModel> get galleryImages => List.unmodifiable(_galleryImages);
  bool get hasCertificate => _hasCertificate;
  int? get active => _active;
  String get selectedPricingType => _selectedPricingType;

  // ================================
  // CONSTRUCTOR & INITIALIZATION
  // ================================

  WorkerManagerProvider() {
    _initialize();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// Initialize the provider with all necessary data
  Future<void> initialize() async {
    debugPrint('WorkerManager: Starting initialization');

    _setAuthError(null);
    _setLoading(true);

    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);

      if (_token != null) {
        await Future.wait([
          _loadWorkerData(),
          fetchNotifications(),
          fetchMyServices(),
          getEarningsSummary(),
          _initializeChat(),
          _validateUserType(),
        ]);

        debugPrint('WorkerManager: Initialization completed successfully');
      } else {
        await _clearDataAndRedirect(AppRoutes.login);
      }
    } catch (error) {
      final errorMessage = 'Initialization failed: $error';
      debugPrint('WorkerManager: $errorMessage');
      _setAuthError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Enhanced user type validation with server verification
  Future<void> _validateUserType() async {
    try {
      if (_workerInfo?.type == null) {
        debugPrint('WorkerManager: User type is null, skipping validation');
        return;
      }

      if (_workerInfo!.type != AppConfig.service) {
        debugPrint(
            'WorkerManager: User type mismatch detected. Expected worker, got ${_workerInfo!.type}');

        // Clear inconsistent data and redirect to correct interface
        await _clearDataAndRedirect(AppRoutes.userMain);
      } else {
        debugPrint('WorkerManager: User type validation passed');
      }
    } catch (error) {
      debugPrint('WorkerManager: Error during user type validation: $error');
    }
  }

  /// Initialize chat functionality
  Future<void> _initializeChat() async {
    try {
      if (_workerInfo?.id == null) {
        debugPrint(
            'WorkerManager: Worker ID not available for chat initialization');
        return;
      }

      final context = NavigationService.navigatorKey.currentContext;
      if (context == null) {
        debugPrint('WorkerManager: Navigation context not available for chat');
        return;
      }

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Check if chat needs initialization
      if (!chatProvider.initialFetchComplete ||
          chatProvider.currentUserId != _workerInfo!.id.toString()) {
        await chatProvider.initialize(_workerInfo!.id.toString());
        debugPrint(
            'WorkerManager: Chat initialized for worker ${_workerInfo!.id}');
      }
    } catch (error) {
      debugPrint('WorkerManager: Failed to initialize chat: $error');
    }
  }

  /// Private initialization helper
  void _initialize() {
    initialize();
  }

  /// Cleanup all resources
  void _cleanupResources() {
    // Dispose all form controllers
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    _amountController.dispose();
    _transitController.dispose();
    _institutionController.dispose();
    _accountController.dispose();
    _servicePriceController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    _hourlyPriceController.dispose();
    _dailyPriceController.dispose();
    _fixedPriceController.dispose();
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

  /// Clear all data and navigate to specified route
  Future<void> _clearDataAndRedirect(String route) async {
    try {
      await clearData();
      await NavigationService.navigateToAndReplace(route);
    } catch (error) {
      debugPrint('WorkerManager: Error during clear and redirect: $error');
    }
  }

  /// Enhanced clear data method
  Future<void> clearData() async {
    try {
      // Clear authentication state
      _token = null;
      _workerInfo = null;

      // Clear all errors
      _clearAllErrors();

      // Clear notifications data
      _notifications.clear();
      _newNotificationCount = 0;
      _unreadNotificationCount = 0;
      _lastNotificationFetch = null;

      // Clear earnings data
      _earningsHistory.clear();
      _earningsSummary = null;

      // Clear storage
      await Future.wait([
        StorageManager.remove(StorageKeys.tokenKey),
        StorageManager.remove(StorageKeys.accountTypeKey),
        TokenManager.instance.clearAuthToken(),
      ]);

      // Reset UI state
      _currentIndex = 0;

      notifyListeners();
      debugPrint('WorkerManager: Data cleared successfully');
    } catch (error) {
      debugPrint('WorkerManager: Error clearing data: $error');
    }
  }

  // ================================
  // ERROR MANAGEMENT METHODS
  // ================================

  void _setAuthError(String? message) {
    if (_authError != message) {
      _authError = message;
      notifyListeners();
    }
  }

  void _setBalanceError(String? message) {
    if (_balanceError != message) {
      _balanceError = message;
      notifyListeners();
    }
  }

  void _setWithdrawalError(String? message) {
    if (_withdrawalError != message) {
      _withdrawalError = message;
      notifyListeners();
    }
  }

  void _setProfileError(String? message) {
    if (_profileError != message) {
      _profileError = message;
      notifyListeners();
    }
  }

  void _setServicesError(String? message) {
    if (_servicesError != message) {
      _servicesError = message;
      notifyListeners();
    }
  }

  void _setAccountStateError(String? message) {
    if (_accountStateError != message) {
      _accountStateError = message;
      notifyListeners();
    }
  }

  void _setEarningsError(String? message) {
    if (_earningsError != message) {
      _earningsError = message;
      notifyListeners();
    }
  }

  void _setAddServiceError(String? message) {
    if (_addServiceError != message) {
      _addServiceError = message;
      notifyListeners();
    }
  }

  void _setNotificationError(String? message) {
    if (_notificationError != message) {
      _notificationError = message;
      notifyListeners();
    }
  }

  void setImageError(String? message) {
    if (_imageError != message) {
      _imageError = message;
      notifyListeners();
    }
  }

  /// Clear all error states
  void _clearAllErrors() {
    _authError = null;
    _balanceError = null;
    _withdrawalError = null;
    _earningsError = null;
    _profileError = null;
    _servicesError = null;
    _accountStateError = null;
    _addServiceError = null;
    _notificationError = null;
    _imageError = null;
  }

  /// Clear specific error by type
  void clearError(String errorType) {
    switch (errorType) {
      case 'auth':
        _setAuthError(null);
        break;
      case 'balance':
        _setBalanceError(null);
        break;
      case 'withdrawal':
        _setWithdrawalError(null);
        break;
      case 'earnings':
        _setEarningsError(null);
        break;
      case 'profile':
        _setProfileError(null);
        break;
      case 'services':
        _setServicesError(null);
        break;
      case 'accountState':
        _setAccountStateError(null);
        break;
      case 'addService':
        _setAddServiceError(null);
        break;
      case 'notification':
        _setNotificationError(null);
        break;
      case 'image':
        setImageError(null);
        break;
    }
  }

  /// Categorize errors for better user experience
  String _categorizeError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout')) {
      return 'The request took too long. Please check your internet connection and try again.';
    }

    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }

    if (errorString.contains('server error') || errorString.contains('500')) {
      return 'Server is temporarily unavailable. Please try again in a few moments.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('token')) {
      return 'Your session has expired. Please log out and log back in.';
    }

    if (errorString.contains('file') || errorString.contains('image')) {
      return 'File upload failed. Please try with a smaller image or check your connection.';
    }

    if (errorString.contains('validation')) {
      return 'Please check all required fields and ensure they are filled correctly.';
    }

    return 'An unexpected error occurred. Please check your details and try again.';
  }

  // ================================
  // LOADING STATE SETTERS
  // ================================

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setBalanceLoading(bool value) {
    if (_isBalanceLoading != value) {
      _isBalanceLoading = value;
      notifyListeners();
    }
  }

  void _setEarningsLoading(bool value) {
    if (_isEarningsLoading != value) {
      _isEarningsLoading = value;
      notifyListeners();
    }
  }

  void _setWithdrawalLoading(bool value) {
    if (_isWithdrawalLoading != value) {
      _isWithdrawalLoading = value;
      notifyListeners();
    }
  }

  void _setProfileLoading(bool value) {
    if (_isProfileLoading != value) {
      _isProfileLoading = value;
      notifyListeners();
    }
  }

  void _setAccountStateLoading(bool value) {
    if (_isAccountStateLoading != value) {
      _isAccountStateLoading = value;
      notifyListeners();
    }
  }

  void _setServiceLoading(bool value) {
    if (_isServiceLoading != value) {
      _isServiceLoading = value;
      notifyListeners();
    }
  }

  void _setNotificationLoading(bool value) {
    if (_isNotificationLoading != value) {
      _isNotificationLoading = value;
      notifyListeners();
    }
  }

  // ================================
  // USER DATA MANAGEMENT
  // ================================

  /// Load worker data with enhanced error handling and token refresh
  Future<void> _loadWorkerData() async {
    _token = await StorageManager.getString(StorageKeys.tokenKey);

    try {
      if (_token != null) {
        bool userInfoSuccess = await fetchWorkerInfo();

        if (userInfoSuccess) {
          await getMyBalance();
          _initializeFormControllers();
          debugPrint('WorkerManager: Worker data loaded successfully');
        } else {
          // Attempt token refresh
          final refreshed = await TokenManager.instance.refreshAuthToken();

          if (refreshed) {
            _token = TokenManager.instance.accessToken;
            await initialize();
          } else {
            await _clearDataAndRedirect(AppRoutes.login);
          }
        }
      }
    } catch (error) {
      _setAuthError('Failed to load worker data: $error');
    }
  }

  /// Fetch worker information from API
  Future<bool> fetchWorkerInfo() async {
    if (_token == null) return false;

    _setProfileError(null);
    _setProfileLoading(true);

    try {
      final response = await BothApi.getUserInfo();

      if (response.success && response.data != null) {
        _workerInfo = response.data;
        _setProfileError(null);
        debugPrint('WorkerManager: Worker info fetched successfully');
        return true;
      } else {
        _setProfileError(response.error ?? 'Failed to fetch worker info');
        return false;
      }
    } catch (error) {
      _setProfileError('Exception fetching worker info: $error');
      return false;
    } finally {
      _setProfileLoading(false);
    }
  }

  /// Initialize form controllers with worker data
  void _initializeFormControllers() {
    if (_workerInfo == null) return;

    _fullNameController.text = _workerInfo!.fullName ?? '';
    _emailController.text = _workerInfo!.email ?? '';
    _phoneController.text = _workerInfo!.phone?.toString() ?? '';
    _cityController.text = _workerInfo!.city ?? '';
    _countryController.text = _workerInfo!.country ?? '';

    debugPrint('WorkerManager: Form controllers initialized');
  }

  /// Edit worker account with comprehensive validation
  Future<bool> editAccount(BuildContext context) async {
    if (_workerInfo == null) {
      _setProfileError('Worker information not available');
      return false;
    }

    _setProfileLoading(true);
    _setProfileError(null);

    try {
      final request = AccountEditRequest(
        image: _selectedImage,
        fullName:
            _getChangedValue(_fullNameController.text, _workerInfo!.fullName),
        email: _getChangedValue(_emailController.text, _workerInfo!.email),
        city: _getChangedValue(_cityController.text, _workerInfo!.city),
        country:
            _getChangedValue(_countryController.text, _workerInfo!.country),
        phone: _getChangedPhoneValue(),
        password:
            _passwordController.text.isEmpty ? null : _passwordController.text,
      );

      final response = await BothApi.editAccount(request);

      if (response.success && response.data != null) {
        _workerInfo = response.data;
        _initializeFormControllers();
        _selectedImage = null;
        setImageError(null);
        _setProfileError(null);

        debugPrint('WorkerManager: Account edited successfully');
        return true;
      } else {
        _setProfileError(response.error ?? 'Failed to edit account');
        return false;
      }
    } catch (error) {
      _setProfileError('Exception editing account: $error');
      return false;
    } finally {
      _setProfileLoading(false);
    }
  }

  /// Helper method to get changed values
  String? _getChangedValue(String newValue, String? currentValue) {
    return newValue.trim() == (currentValue ?? '') ? null : newValue.trim();
  }

  /// Helper method to get changed phone value
  int? _getChangedPhoneValue() {
    final phoneText = _phoneController.text.trim();
    final currentPhone = _workerInfo!.phone?.toString() ?? '';

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
        debugPrint('WorkerManager: Image selected successfully');
      }
    } catch (error) {
      if (context.mounted) {
        setImageError(AppLocalizations.of(context)!.generalError);
      }
      debugPrint('WorkerManager: Error picking image: $error');
    } finally {
      notifyListeners();
    }
  }

  // ================================
  // BALANCE MANAGEMENT
  // ================================

  /// Get worker's balance with enhanced error handling
  Future<void> getMyBalance() async {
    if (_token == null) return;

    _setBalanceError(null);
    _setBalanceLoading(true);

    try {
      final response = await WorkerApi.getMyBalance();

      if (response.success && response.data != null) {
        _balance = response.data!;
        _setBalanceError(null);
        debugPrint('WorkerManager: Balance fetched successfully');
      } else {
        _setBalanceError(response.error ?? 'Failed to fetch balance');
      }
    } catch (error) {
      _setBalanceError('Exception fetching balance: $error');
    } finally {
      _setBalanceLoading(false);
    }
  }

  // ================================
  // EARNINGS MANAGEMENT
  // ================================

  /// Get earnings history
  Future<void> getEarningsHistory() async {
    if (_token == null) return;

    _setEarningsError(null);
    _setEarningsLoading(true);

    try {
      final response = await WorkerApi.getEarningsHistory();

      if (response.success && response.data != null) {
        _earningsHistory = response.data!;
        _setEarningsError(null);
        debugPrint('WorkerManager: Earnings history fetched successfully');
      } else {
        _setEarningsError(response.error ?? 'Failed to fetch earnings history');
      }
    } catch (error) {
      _setEarningsError('Exception fetching earnings history: $error');
    } finally {
      _setEarningsLoading(false);
    }
  }

  /// Get earnings summary
  Future<void> getEarningsSummary() async {
    if (_token == null) return;

    _setEarningsError(null);
    _setEarningsLoading(true);

    try {
      final response = await WorkerApi.getEarningsSummary();

      if (response.success && response.data != null) {
        _earningsSummary = response.data!;
        _setEarningsError(null);
        debugPrint('WorkerManager: Earnings summary fetched successfully');
      } else {
        _setEarningsError(response.error ?? 'Failed to fetch earnings summary');
      }
    } catch (error) {
      _setEarningsError('Exception fetching earnings summary: $error');
    } finally {
      _setEarningsLoading(false);
    }
  }

  /// Refresh all earnings data
  Future<void> refreshEarningsData() async {
    await Future.wait([
      getMyBalance(),
      getEarningsSummary(),
      getEarningsHistory(),
    ]);
  }

  // ================================
  // WITHDRAWAL MANAGEMENT
  // ================================

  /// Load saved account information from storage
  Future<void> loadSavedAccountInfo() async {
    try {
      final bankAccount =
          await StorageManager.getObject(StorageKeys.bankAccountKey);

      if (bankAccount != null) {
        _fullNameController.text = bankAccount['fullName'] ?? '';
        _transitController.text = bankAccount['transit'] ?? '';
        _institutionController.text = bankAccount['institution'] ?? '';
        _accountController.text = bankAccount['account'] ?? '';
      }

      notifyListeners();
      debugPrint('WorkerManager: Saved account info loaded');
    } catch (error) {
      debugPrint('WorkerManager: Error loading saved account info: $error');
      _setWithdrawalError('Error loading saved account info');
    }
  }

  /// Save account information to storage
  Future<void> saveAccountInfos() async {
    if (!_saveAccountInfo) return;

    try {
      final bankAccountData = {
        'fullName': _fullNameController.text.trim(),
        'transit': _transitController.text.trim(),
        'institution': _institutionController.text.trim(),
        'account': _accountController.text.trim(),
      };

      await StorageManager.setObject(
          StorageKeys.bankAccountKey, bankAccountData);
      debugPrint('WorkerManager: Account info saved successfully');
    } catch (error) {
      debugPrint('WorkerManager: Error saving account info: $error');
      _setWithdrawalError('Error saving account info');
    }
  }

  /// Validate withdrawal form
  bool validateWithdrawalForm() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    if (amount <= 0) return false;

    return _fullNameController.text.trim().isNotEmpty &&
        _transitController.text.trim().isNotEmpty &&
        _institutionController.text.trim().isNotEmpty &&
        _accountController.text.trim().isNotEmpty;
  }

  /// Set save account info preference
  void setSaveAccountInfo(bool value) {
    if (_saveAccountInfo != value) {
      _saveAccountInfo = value;
      notifyListeners();
    }
  }

  /// Request withdrawal with comprehensive validation
  Future<WithdrawalAttemptResult> requestWithdrawal() async {
    if (_token == null) {
      return WithdrawalAttemptResult(
        false,
        errorMessage: "Authentication error. Please log in again.",
      );
    }

    try {
      final request = WithdrawalRequest(
        amount: double.tryParse(_amountController.text.trim()),
        method: 'bank',
        name: _fullNameController.text.trim(),
        transit: _transitController.text.trim(),
        institution: _institutionController.text.trim(),
        account: _accountController.text.trim(),
        email: _emailController.text.trim(),
      );

      // Validate request data
      if (request.amount == null || request.amount! <= 0) {
        return WithdrawalAttemptResult(false,
            errorMessage: "Invalid amount entered.");
      }

      if (request.name!.isEmpty ||
          request.transit == null ||
          request.institution == null ||
          request.account == null) {
        return WithdrawalAttemptResult(false,
            errorMessage: "Please fill in all required fields.");
      }

      final response = await WorkerApi.withdrawRequest(request);

      if (response.success) {
        _withdrawalModel = response.data;
        _setWithdrawalError(null);
        await getMyBalance();
        notifyListeners();

        debugPrint('WorkerManager: Withdrawal request submitted successfully');
        return WithdrawalAttemptResult(true);
      } else {
        final errorMessage =
            response.error ?? 'Failed to process withdrawal. Please try again.';
        _setWithdrawalError(errorMessage);
        return WithdrawalAttemptResult(false, errorMessage: errorMessage);
      }
    } catch (error) {
      debugPrint("WorkerManager: Exception in requestWithdrawal: $error");
      const errorMessage =
          'An unexpected error occurred. Please check your connection and try again.';
      _setWithdrawalError(errorMessage);
      return WithdrawalAttemptResult(false, errorMessage: errorMessage);
    }
  }

  /// Handle withdrawal form submission
  Future<bool> submitWithdrawal(BuildContext context) async {
    if (!validateWithdrawalForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.requiredFields),
          backgroundColor: AppColors.errorDark,
        ),
      );
      return false;
    }

    _setWithdrawalLoading(true);

    try {
      await saveAccountInfos();
      final result = await requestWithdrawal();

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.whiteText),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      AppLocalizations.of(context)!.withdrawalRequestSubmitted),
                ),
              ],
            ),
            backgroundColor: AppColors.successDark,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return true;
      } else {
        final errorMessage =
            result.errorMessage ?? AppLocalizations.of(context)!.generalError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorDark,
          ),
        );
        return false;
      }
    } catch (error) {
      debugPrint("WorkerManager: Exception in submitWithdrawal: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.generalError),
          backgroundColor: AppColors.errorDark,
        ),
      );
      return false;
    } finally {
      _setWithdrawalLoading(false);
    }
  }

  /// Fetch withdrawal status
  Future<bool> fetchWithdrawalStatus() async {
    if (_token == null) return false;

    _setWithdrawalError(null);
    _setLoading(true);

    try {
      final response = await WorkerApi.withdrawStatus();

      if (response.success && response.data != null) {
        _withdrawStatus = response.data;
        notifyListeners();
        debugPrint('WorkerManager: Withdrawal status fetched successfully');
        return true;
      } else {
        _setWithdrawalError('Failed to fetch withdrawal status');
        return false;
      }
    } catch (error) {
      _setWithdrawalError('Exception fetching withdrawal status: $error');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ================================
  // ACCOUNT STATE MANAGEMENT
  // ================================

  /// Change account state (active/inactive)
  Future<void> changeAccountState(int accountState) async {
    if (_token == null) return;

    _setAccountStateError(null);
    _setAccountStateLoading(true);

    try {
      final response = await WorkerApi.changeAccountState(accountState);

      if (response.success) {
        await Future.wait([
          fetchWorkerInfo(),
          fetchMyServices(),
        ]);
        debugPrint('WorkerManager: Account state changed successfully');
      } else {
        _setAccountStateError(
            response.error ?? 'Failed to change account state');
      }
    } catch (error) {
      _setAccountStateError('Exception changing account state: $error');
    } finally {
      _setAccountStateLoading(false);
    }
  }

  // ================================
  // SERVICE MANAGEMENT
  // ================================

  /// Fetch worker's services
  Future<void> fetchMyServices() async {
    _setServiceLoading(true);
    _setServicesError(null);

    try {
      final response = await WorkerApi.fetchMyServices();

      if (response.success && response.data != null) {
        _myServices = response.data!;
        _setServicesError(null);
        debugPrint(
            'WorkerManager: Services fetched successfully: ${_myServices.length} services');
      } else {
        _setServicesError(response.error ?? 'Failed to fetch services');
      }
    } catch (error) {
      _setServicesError('Failed to fetch services: $error');
    } finally {
      _setServiceLoading(false);
    }
  }

  /// Get services chart data for statistics
  List<ServiceChartData> getServicesChartData() {
    final totalServices = _myServices.length;
    final visibleServices =
        _myServices.where((service) => service.active == 1).length;
    final hiddenServices = totalServices - visibleServices;

    return [
      ServiceChartData('Services', visibleServices, hiddenServices),
    ];
  }

  /// Fetch categories for service creation
  Future<void> fetchCategories() async {
    _setServiceLoading(true);
    _setServicesError(null);

    _selectedCategory = null;
    _selectedSubcategory = null;

    try {
      final response = await WorkerApi.fetchCategories();

      if (response.success && response.data != null) {
        _categories = response.data!;
        _setServicesError(null);
        debugPrint('WorkerManager: Categories fetched successfully');
      } else {
        _setAddServiceError(response.error ?? 'Failed to fetch categories');
      }
    } catch (error) {
      _setAddServiceError('Failed to fetch categories: $error');
    } finally {
      _setServiceLoading(false);
    }
  }

  /// Set selected category and reset subcategory
  void setCategory(CategoryModel? category) {
    _selectedCategory = category;
    _selectedSubcategory = null;
    _setAddServiceError(null);
    notifyListeners();
  }

  /// Set selected subcategory
  void setSubcategory(SubcategoryModel? subcategory) {
    if (_selectedSubcategory != subcategory) {
      _selectedSubcategory = subcategory;
      notifyListeners();
    }
  }

  /// Set pricing type
  void setPricingType(String pricingType) {
    if (_selectedPricingType != pricingType) {
      _selectedPricingType = pricingType;
      notifyListeners();
    }
  }

  /// Get current price based on selected pricing type
  double? getCurrentPrice() {
    switch (_selectedPricingType) {
      case 'hourly':
        return double.tryParse(_hourlyPriceController.text);
      case 'daily':
        return double.tryParse(_dailyPriceController.text);
      case 'fixed':
        return double.tryParse(_fixedPriceController.text);
      default:
        return null;
    }
  }

  /// Create or edit service
  Future<int> createAndEditService({bool isEditing = false}) async {
    if (!validateServiceInputs() && !isEditing) {
      return 0;
    }

    _setServiceLoading(true);

    try {
      final request = CreateServiceRequest(
        serviceId: _editingServiceId,
        category: _selectedCategory?.name,
        categoryId: _selectedCategory?.id,
        subCategoryId: _selectedSubcategory?.id,
        pricingType: _selectedPricingType,
        price: getCurrentPrice(),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        experience: int.tryParse(_experienceController.text),
        license: _selectedImage,
        active: _active,
      );

      final response = await WorkerApi.createNewService(isEditing, request);

      if (response.success && response.data != null) {
        await fetchMyServices();
        debugPrint(
            'WorkerManager: Service ${isEditing ? 'updated' : 'created'} successfully');
        return response.data!.serviceId!;
      } else {
        final errorMessage =
            _categorizeError(response.error ?? 'Unknown error occurred');
        _setAddServiceError(errorMessage);
        return 0;
      }
    } catch (error) {
      final errorMessage = _categorizeError(error);
      _setAddServiceError(errorMessage);
      return 0;
    } finally {
      _setServiceLoading(false);
    }
  }

  /// Validate service inputs
  bool validateServiceInputs() {
    if (_selectedCategory == null) {
      _setAddServiceError('Please select a service category.');
      return false;
    }

    if (_selectedSubcategory == null) {
      _setAddServiceError('Please select a subcategory.');
      return false;
    }

    if (_descriptionController.text.isEmpty) {
      _setAddServiceError('Please enter a service description.');
      return false;
    }

    final currentPrice = getCurrentPrice();
    if (currentPrice == null || currentPrice <= 0) {
      final priceLabel = _selectedPricingType == 'hourly'
          ? 'hourly rate'
          : _selectedPricingType == 'daily'
              ? 'daily rate'
              : 'fixed price';
      _setAddServiceError('Please enter a valid $priceLabel.');
      return false;
    }

    final experience = int.tryParse(_experienceController.text);
    if (experience == null || experience < 0) {
      _setAddServiceError('Please enter valid years of experience.');
      return false;
    }

    _setAddServiceError(null);
    return true;
  }

  /// Reset category selection
  void resetCategorySelection() {
    _selectedCategory = null;
    _selectedSubcategory = null;
    _setAddServiceError(null);
    _selectedPricingType = 'hourly';
    _hourlyPriceController.clear();
    _dailyPriceController.clear();
    _fixedPriceController.clear();
    _experienceController.clear();
    _descriptionController.clear();
    _selectedImage = null;
    _editingServiceId = null;
    notifyListeners();
  }

  /// Reset service state
  void resetServiceState() {
    _selectedCategory = null;
    _selectedSubcategory = null;
    _selectedImage = null;
    _galleryImages.clear();
    _setAddServiceError(null);
    _selectedPricingType = 'hourly';
    _hourlyPriceController.clear();
    _dailyPriceController.clear();
    _fixedPriceController.clear();
    _experienceController.clear();
    _descriptionController.clear();
    notifyListeners();
  }

  /// Set service ID for editing
  void setServiceId(int id) {
    if (_editingServiceId != id) {
      _editingServiceId = id;
      notifyListeners();
    }
  }

  /// Set active status
  void setActive(bool value) {
    final newActive = value ? 1 : 0;
    if (_active != newActive) {
      _active = newActive;
      notifyListeners();
    }
  }

  /// Set certificate status
  void setHasCertificate(bool? value) {
    final newValue = value ?? false;
    if (_hasCertificate != newValue) {
      _hasCertificate = newValue;
      notifyListeners();
    }
  }

  /// Upload service image
  Future<void> uploadServiceImage(
      BuildContext context, ImageSource source, int serviceId) async {
    try {
      _setServiceLoading(true);
      await pickImage(context, source);

      if (_selectedImage != null) {
        final request =
            AddImageRequest(serviceId: serviceId, image: _selectedImage!);
        final response = await WorkerApi().addGalleryImage(request);

        if (response.success && response.data != null) {
          _galleryImages.add(response.data!);
          debugPrint('WorkerManager: Service image uploaded successfully');
        } else {
          _setAddServiceError(response.error ?? 'Failed to upload image');
        }
      }
    } catch (error) {
      _setAddServiceError('Failed to upload image: $error');
    } finally {
      _setServiceLoading(false);
    }
  }

  /// Remove service image
  Future<void> removeServiceImage(String imageName) async {
    _setServiceLoading(true);

    try {
      final response = await WorkerApi().removeGalleryImage(imageName);

      if (response.success && response.data == true) {
        _galleryImages.removeWhere((image) => image.image == imageName);
        debugPrint('WorkerManager: Service image removed successfully');
      } else {
        _setAddServiceError(response.error ?? 'Failed to remove image');
      }
    } catch (error) {
      _setAddServiceError('Failed to remove image: $error');
    } finally {
      _setServiceLoading(false);
    }
  }

  /// Initialize service controllers for editing
  void initializeServiceControllers(MyServicesModel service) {
    _editingServiceId = service.id;
    _descriptionController.text = service.about;

    _selectedPricingType = service.pricingType ?? 'hourly';

    switch (service.pricingType) {
      case 'hourly':
        _hourlyPriceController.text = service.costPerHour?.toString() ?? '';
        _dailyPriceController.clear();
        _fixedPriceController.clear();
        break;
      case 'daily':
        _dailyPriceController.text = service.costPerDay?.toString() ?? '';
        _hourlyPriceController.clear();
        _fixedPriceController.clear();
        break;
      case 'fixed':
        _fixedPriceController.text = service.fixedPrice?.toString() ?? '';
        _hourlyPriceController.clear();
        _dailyPriceController.clear();
        break;
      default:
        _hourlyPriceController.text = service.costPerHour?.toString() ?? '';
        _dailyPriceController.clear();
        _fixedPriceController.clear();
    }

    _experienceController.text = service.yearsOfExperience.toString();
    setHasCertificate(service.hasCertificate != 0);
    _galleryImages =
        List.from(service.gallary.map((img) => AddImageModel(image: img)));

    notifyListeners();
  }

  // ================================
  // NOTIFICATION MANAGEMENT
  // ================================

  /// Fetch notifications with enhanced caching and error handling
  Future<void> fetchNotifications({bool forceRefresh = false}) async {
    if (_isNotificationLoading) {
      debugPrint('WorkerManager: Notification fetch already in progress');
      return;
    }

    // Check cache validity (30 seconds)
    if (!forceRefresh && _lastNotificationFetch != null) {
      final timeSinceLastFetch =
          DateTime.now().difference(_lastNotificationFetch!);
      if (timeSinceLastFetch.inSeconds < 30) {
        debugPrint('WorkerManager: Using cached notifications');
        return;
      }
    }

    _setNotificationLoading(true);
    _setNotificationError(null);

    try {
      debugPrint('WorkerManager: Fetching notifications...');

      final results = await Future.wait([
        BothApi.fetchNotifications(),
        BothApi.getNewNotificationsCount(),
        BothApi.getUnreadNotificationsCount(),
      ]);

      final notificationsResponse =
          results[0] as ApiResponse<List<NotificationModel>>;
      final newCountResponse = results[1] as ApiResponse<int>;
      final unreadCountResponse = results[2] as ApiResponse<int>;

      // Handle notifications response
      if (notificationsResponse.success && notificationsResponse.data != null) {
        _notifications = notificationsResponse.data!;
        _lastNotificationFetch = DateTime.now();
        debugPrint(
            'WorkerManager: Loaded ${_notifications.length} notifications');
      } else {
        _setNotificationError(
            notificationsResponse.error ?? 'Failed to load notifications');
      }

      // Handle counts
      if (newCountResponse.success && newCountResponse.data != null) {
        _newNotificationCount = newCountResponse.data!;
      } else {
        _newNotificationCount = _notifications.where((n) => n.isNew).length;
      }

      if (unreadCountResponse.success && unreadCountResponse.data != null) {
        _unreadNotificationCount = unreadCountResponse.data!;
      } else {
        _unreadNotificationCount =
            _notifications.where((n) => !n.isRead).length;
      }
    } catch (error, stackTrace) {
      _setNotificationError('Exception fetching notifications: $error');
      debugPrint('WorkerManager: Exception in fetchNotifications: $error');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _setNotificationLoading(false);
    }
  }

  /// Fetch notification counts only
  Future<void> fetchNotificationCounts() async {
    try {
      debugPrint('WorkerManager: Fetching notification counts...');

      final results = await Future.wait([
        BothApi.getNewNotificationsCount(),
        BothApi.getUnreadNotificationsCount(),
      ]);

      bool hasChanges = false;

      if (results[0].success && results[0].data != null) {
        final newCount = results[0].data!;
        if (_newNotificationCount != newCount) {
          _newNotificationCount = newCount;
          hasChanges = true;
        }
      }

      if (results[1].success && results[1].data != null) {
        final unreadCount = results[1].data!;
        if (_unreadNotificationCount != unreadCount) {
          _unreadNotificationCount = unreadCount;
          hasChanges = true;
        }
      }

      if (hasChanges) {
        notifyListeners();
      }
    } catch (error) {
      debugPrint('WorkerManager: Exception in fetchNotificationCounts: $error');
    }
  }

  /// Mark all notifications as seen with optimistic updates
  Future<void> markAllNotificationsAsSeenNew() async {
    if (_newNotificationCount == 0) {
      debugPrint('WorkerManager: No new notifications to mark as seen');
      return;
    }

    try {
      final oldNewCount = _newNotificationCount;
      _updateNotificationsSeenStatus();

      debugPrint(
          'WorkerManager: Optimistically updated UI - marked $oldNewCount notifications as seen');

      final response = await BothApi.markNotificationsAsSeen();

      if (response.success) {
        debugPrint(
            'WorkerManager: Successfully synced seen status with backend');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'WorkerManager: Failed to sync seen status: ${response.error}');
        _revertNotificationsSeenStatus(oldNewCount);
        _setNotificationError(
            'Failed to mark notifications as seen: ${response.error}');
      }
    } catch (error) {
      debugPrint(
          'WorkerManager: Exception in markAllNotificationsAsSeenNew: $error');
      _setNotificationError('Error marking notifications as seen: $error');
    }
  }

  /// Mark all notifications as read with optimistic updates
  Future<void> markAllNotificationsAsRead() async {
    if (_unreadNotificationCount == 0) {
      debugPrint('WorkerManager: No unread notifications to mark as read');
      return;
    }

    try {
      final oldUnreadCount = _unreadNotificationCount;
      _updateAllNotificationsReadStatus();

      debugPrint(
          'WorkerManager: Optimistically updated UI - marked $oldUnreadCount notifications as read');

      final response = await BothApi.markAllNotificationsAsRead();

      if (response.success) {
        debugPrint(
            'WorkerManager: Successfully synced read status with backend');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'WorkerManager: Failed to sync read status: ${response.error}');
        await fetchNotifications(forceRefresh: true);
        _setNotificationError(
            'Failed to mark notifications as read: ${response.error}');
      }
    } catch (error) {
      debugPrint(
          'WorkerManager: Exception in markAllNotificationsAsRead: $error');
    }
  }

  /// Mark specific notifications as read
  Future<void> markNotificationsAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) {
      debugPrint('WorkerManager: No notification IDs provided');
      return;
    }

    try {
      debugPrint(
          'WorkerManager: Marking ${notificationIds.length} notifications as read');

      _updateSpecificNotificationsReadStatus(notificationIds);

      final response = await BothApi.markNotificationsAsRead(notificationIds);

      if (response.success) {
        debugPrint(
            'WorkerManager: Successfully marked specific notifications as read');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'WorkerManager: Failed to mark specific notifications as read: ${response.error}');
        await fetchNotifications(forceRefresh: true);
        _setNotificationError(
            'Failed to mark notifications as read: ${response.error}');
      }
    } catch (error) {
      debugPrint('WorkerManager: Exception in markNotificationsAsRead: $error');
      await fetchNotifications(forceRefresh: true);
      _setNotificationError('Error marking notifications as read: $error');
    }
  }

  /// Clear notification error
  void clearNotificationError() {
    _setNotificationError(null);
  }

  // ================================
  // PRIVATE NOTIFICATION HELPERS
  // ================================

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
    _newNotificationCount = _notifications.where((n) => n.isNew).length;
    _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;
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
    _unreadNotificationCount = 0;
    notifyListeners();
  }

  // ================================
  // UTILITY SETTERS AND HELPERS
  // ================================

  /// Set selected image (for service management)
  set selectedImage(File? value) {
    if (_selectedImage != value) {
      _selectedImage = value;
      notifyListeners();
    }
  }

  /// Set gallery images (for service management)
  set galleryImages(List<AddImageModel> value) {
    _galleryImages = List.from(value);
    notifyListeners();
  }
}

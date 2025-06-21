import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_response.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
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
import 'package:good_one_app/Features/Auth/Services/token_manager.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class WorkerManagerProvider extends ChangeNotifier {
  // Authentication State
  String? _token;
  UserInfo? _workerInfo;

  // Section-specific errors instead of global error
  // String? _error;
  String? _authError;
  String? _balanceError;
  String? _withdrawalError;
  String? _profileError;
  String? _servicesError;
  String? _accountStateError;

  // UI State
  int _currentIndex = 0;
  bool _isLoading = false;

  // Balance section
  BalanceModel? _balance;
  bool _isBalanceLoading = false;

// Earnings section
  EarningsSummaryModel? _earningsSummary;
  List<EarningsHistoryModel> _earningsHistory = [];
  bool _isEarningsLoading = false;
  String? _earningsError;

  // Withdrawal section
  WithdrawalModel? _withdrawalModel;
  List<WithdrawStatus>? _withdrawStatus;
  bool _isWithdrawalLoading = false;
  bool _saveAccountInfo = true;

  // Profile section
  bool _isProfileLoading = false;

  // Account state section
  bool _isAccountStateLoading = false;

  // Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transitController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  // User Profile Image Handling
  File? _selectedImage;
  String? _imageError;
  final ImagePicker _picker = ImagePicker();

  // Enhanced notification handling fields
  List<NotificationModel> _notifications = [];
  bool _isNotificationLoading = false;
  int _newNotificationCount = 0;
  int _unreadNotificationCount = 0;
  String? _notificationError;
  DateTime? _lastNotificationFetch;

  // My services
  List<MyServicesModel> _myServices = [];

  // Add Service State
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  SubcategoryModel? _selectedSubcategory;
  List<AddImageModel> _galleryImages = [];
  String? _addServiceError;
  bool _isServiceLoading = false;
  bool _hasCertificate = false;
  int? _editingServiceId;
  int? _active;
  String _selectedPricingType = 'hourly';

  // Form controllers for Add Service
  final TextEditingController _servicePriceController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _hourlyPriceController = TextEditingController();
  final TextEditingController _dailyPriceController = TextEditingController();
  final TextEditingController _fixedPriceController = TextEditingController();

  // Getters for Authentication and User Info
  String? get token => _token;
  UserInfo? get workerInfo => _workerInfo;

  // Section-specific error getters
  String? get authError => _authError;
  String? get balanceError => _balanceError;
  String? get withdrawalError => _withdrawalError;
  String? get profileError => _profileError;
  String? get servicesError => _servicesError;
  String? get accountStateError => _accountStateError;

  // Check if there are any critical errors that should block the app
  bool get hasCriticalError => _authError != null;

  // Get the most critical error for display
  String? get criticalError => _authError;

  // Balance section getters
  BalanceModel? get balance => _balance;
  bool get isBalanceLoading => _isBalanceLoading;

  // Earnings section getters
  EarningsSummaryModel? get earningsSummary => _earningsSummary;
  List<EarningsHistoryModel> get earningsHistory =>
      List.unmodifiable(_earningsHistory);
  bool get isEarningsLoading => _isEarningsLoading;
  String? get earningsError => _earningsError;

  // General loading state
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;

  // Profile section getters
  bool get isProfileLoading => _isProfileLoading;

  // Account state getters
  bool get isAccountStateLoading => _isAccountStateLoading;

  // Getters for notifications
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isNotificationLoading => _isNotificationLoading;
  int get unreadNotificationCount => _newNotificationCount;
  int get newNotificationCount => _newNotificationCount;
  int get totalUnreadCount => _unreadNotificationCount;
  String? get notificationError => _notificationError;

  // Private field to store the count from backend
  String? get imageError => _imageError;
  File? get selectedImage => _selectedImage;

  WithdrawalModel? get withdrawalModel => _withdrawalModel;
  List<WithdrawStatus>? get withdrawStatus => _withdrawStatus;

  // Withdrawal Dialog Getters
  bool get isWithdrawalLoading => _isWithdrawalLoading;
  bool get saveAccountInfo => _saveAccountInfo;

  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get cityController => _cityController;
  TextEditingController get countryController => _countryController;
  TextEditingController get passwordController => _passwordController;

  TextEditingController get transitController => _transitController;
  TextEditingController get institutionController => _institutionController;
  TextEditingController get accountController => _accountController;

  // Getters for Add Service
  List<CategoryModel> get categories => _categories;
  List<MyServicesModel> get myServices => _myServices;
  CategoryModel? get selectedCategory => _selectedCategory;
  SubcategoryModel? get selectedSubcategory => _selectedSubcategory;

  List<AddImageModel> get galleryImages => _galleryImages;
  String? get addServiceError => _addServiceError;
  bool get isServiceLoading => _isServiceLoading;
  bool get hasCertificate => _hasCertificate;
  int? get avtice => _active;
  String get selectedPricingType => _selectedPricingType;

  TextEditingController get amountController => _amountController;
  TextEditingController get servicePriceController => _servicePriceController;
  TextEditingController get experienceController => _experienceController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get hourlyPriceController => _hourlyPriceController;
  TextEditingController get dailyPriceController => _dailyPriceController;
  TextEditingController get fixedPriceController => _fixedPriceController;

  WorkerManagerProvider() {
    initialize();
  }

  // -----------------------------------
  // Error Management Methods
  // -----------------------------------

  void setAuthError(String? message) {
    _authError = message;
    notifyListeners();
  }

  void setBalanceError(String? message) {
    _balanceError = message;
    notifyListeners();
  }

  void setWithdrawalError(String? message) {
    _withdrawalError = message;
    notifyListeners();
  }

  void setProfileError(String? message) {
    _profileError = message;
    notifyListeners();
  }

  void setServicesError(String? message) {
    _servicesError = message;
    notifyListeners();
  }

  void setAccountStateError(String? message) {
    _accountStateError = message;
    notifyListeners();
  }

  void setEarningsError(String? message) {
    _earningsError = message;
    notifyListeners();
  }

  void clearAllErrors() {
    _authError = null;
    _balanceError = null;
    _withdrawalError = null;
    _earningsError = null;
    _profileError = null;
    _servicesError = null;
    _accountStateError = null;
    notifyListeners();
  }

  void clearError(String errorType) {
    switch (errorType) {
      case 'auth':
        _authError = null;
        break;
      case 'balance':
        _balanceError = null;
        break;
      case 'withdrawal':
        _withdrawalError = null;
        break;
      case 'earnings':
        _earningsError = null;
        break;
      case 'profile':
        _profileError = null;
        break;
      case 'services':
        _servicesError = null;
        break;
      case 'accountState':
        _accountStateError = null;
        break;
    }
    notifyListeners();
  }

  // -----------------------------------
  // Initialization
  // -----------------------------------

  Future<void> initialize() async {
    print(
        '======================== initialize Worker manager ==================');
    setAuthError(null);
    _setLoading(true);

    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);
      if (_token != null) {
        await Future.wait([
          _loadWorkerData(),
          fetchNotifications(),
          fetchMyServices(),
          getEarningsSummary(),
          if (_workerInfo?.id != null)
            Provider.of<ChatProvider>(
                    NavigationService.navigatorKey.currentContext!,
                    listen: false)
                .initialize(_workerInfo!.id.toString()),
        ]);
      } else {
        await clearData();
        await NavigationService.navigateToAndReplace(AppRoutes.userMain);
      }
    } catch (e) {
      setAuthError('Initialization failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // -----------------------------------
  // Withdrawal Dialog Management
  // -----------------------------------

  /// Loads saved account information from storage
  Future<void> loadSavedAccountInfo() async {
    try {
      // Load saved bank account info
      final bankAccount =
          await StorageManager.getObject(StorageKeys.bankAccountKey);
      if (bankAccount != null) {
        _fullNameController.text = bankAccount['fullName'] ?? '';
        _transitController.text = bankAccount['transit'] ?? '';
        _institutionController.text = bankAccount['institution'] ?? '';
        _accountController.text = bankAccount['account'] ?? '';
      }

      notifyListeners();
    } catch (e) {
      print('Error loading saved account info: $e');
      setWithdrawalError('Error loading saved account info: $e');
    }
  }

  /// Saves account information to storage
  Future<void> saveAccountInfos() async {
    if (!_saveAccountInfo) return;

    try {
      // Save bank account info
      final bankAccountData = {
        'fullName': _fullNameController.text.trim(),
        'transit': _transitController.text.trim(),
        'institution': _institutionController.text.trim(),
        'account': _accountController.text.trim(),
      };
      await StorageManager.setObject(
          StorageKeys.bankAccountKey, bankAccountData);
    } catch (e) {
      print('Error saving account info: $e');
      setWithdrawalError('Error saving account info: $e');
    }
  }

  /// Validates the withdrawal form
  bool validateWithdrawalForm() {
    if (_amountController.text.trim().isEmpty ||
        (double.tryParse(_amountController.text.trim()) ?? 0) <= 0) {
      return false;
    }

    // Validate bank account form
    return _amountController.text.trim().isNotEmpty &&
        _fullNameController.text.trim().isNotEmpty &&
        _transitController.text.trim().isNotEmpty &&
        _institutionController.text.trim().isNotEmpty &&
        _accountController.text.trim().isNotEmpty;
  }

  /// Sets the save account info preference
  void setSaveAccountInfo(bool value) {
    _saveAccountInfo = value;
    notifyListeners();
  }

  /// Sets the withdrawal loading state
  void setWithdrawalLoading(bool value) {
    _isWithdrawalLoading = value;
    notifyListeners();
  }

  Future<WithdrawalAttemptResult> requestWithdrawal() async {
    if (_token == null) {
      return WithdrawalAttemptResult(
        false,
        errorMessage: "Authentication error. Please log in again.",
      );
    }

    try {
      final request = WithdrawalRequest(
        amount: double.tryParse(_amountController.text),
        method: 'bank',
        name: _fullNameController.text.trim(),
        transit: _transitController.text.trim(),
        institution: _institutionController.text.trim(),
        account: _accountController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (request.amount == null || request.amount! <= 0) {
        return WithdrawalAttemptResult(
          false,
          errorMessage: "Invalid amount entered.",
        );
      }

      if (request.name!.isEmpty ||
          request.transit == null ||
          request.institution == null ||
          request.account == null) {
        return WithdrawalAttemptResult(
          false,
          errorMessage: "Please fill in all required fields.",
        );
      }

      final response = await WorkerApi.withdrawRequest(request);
      if (response.success) {
        _withdrawalModel = response.data;
        setWithdrawalError(null);
        await getMyBalance();
        notifyListeners();
        return WithdrawalAttemptResult(true);
      } else {
        setWithdrawalError(response.error ??
            'Failed to process withdrawal. Please try again.');
        return WithdrawalAttemptResult(
          false,
          errorMessage: response.error ??
              'Failed to process withdrawal. Please try again.',
        );
      }
    } catch (e) {
      print("Exception in requestWithdrawal: $e");
      final errorMessage =
          'An unexpected error occurred. Please check your connection and try again.';
      setWithdrawalError(errorMessage);
      return WithdrawalAttemptResult(
        false,
        errorMessage: errorMessage,
      );
    }
  }

  /// Handles withdrawal form submission
  Future<bool> submitWithdrawal(
    BuildContext context,
  ) async {
    if (!validateWithdrawalForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.requiredFields),
          backgroundColor: AppColors.errorDark,
        ),
      );
      return false;
    }

    setWithdrawalLoading(true);

    try {
      await saveAccountInfos();
      final result = await requestWithdrawal();

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.whiteText,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.withdrawalRequestSubmitted,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.successDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return true;
      } else {
        // Use the error message from the result
        final String errorMessage =
            result.errorMessage ?? AppLocalizations.of(context)!.generalError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorDark,
          ),
        );
        return false;
      }
    } catch (e) {
      print("Exception in submitWithdrawal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.generalError),
          backgroundColor: AppColors.errorDark,
        ),
      );
      return false;
    } finally {
      setWithdrawalLoading(false);
    }
  }

  // Withdrawalstatus
  Future<bool> fetchWithdrawalStatus() async {
    if (_token == null) return false;
    setWithdrawalError(null);
    _setLoading(true);
    try {
      final response = await WorkerApi.withdrawStatus();
      if (response.success && response.data != null) {
        _withdrawStatus = response.data;
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        setWithdrawalError('failed to fetching withdraw status');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      setWithdrawalError('Exception fetching withdraw status');
      _setLoading(false);
      return false;
    }
  }

  // -----------------------------------
  // Balance Management
  // -----------------------------------
  Future<void> getMyBalance() async {
    if (_token == null) return;
    setBalanceError(null);
    _setBalanceLoading(true);
    try {
      final response = await WorkerApi.getMyBalance();
      if (response.success && response.data != null) {
        _balance = response.data!;

        notifyListeners();
      } else {
        setBalanceError('Failed to fetch balance: ${response.error}');
      }
    } catch (e) {
      setBalanceError('Exception fetch my balance: $e');
    } finally {
      _setBalanceLoading(false);
    }
  }

  // -----------------------------------
// Enhanced Earnings Management
// -----------------------------------
  Future<void> getEarningsHistory() async {
    if (_token == null) return;
    setEarningsError(null);
    _setEarningsLoading(true);
    try {
      final response = await WorkerApi.getEarningsHistory();
      if (response.success && response.data != null) {
        _earningsHistory = response.data!;
        notifyListeners();
      } else {
        setEarningsError('Failed to fetch earnings history: ${response.error}');
      }
    } catch (e) {
      setEarningsError('Exception fetching earnings history: $e');
    } finally {
      _setEarningsLoading(false);
    }
  }

  Future<void> getEarningsSummary() async {
    if (_token == null) return;
    setEarningsError(null);
    _setEarningsLoading(true);
    try {
      final response = await WorkerApi.getEarningsSummary();
      if (response.success && response.data != null) {
        _earningsSummary = response.data!;
        notifyListeners();
      } else {
        setEarningsError('Failed to fetch earnings summary: ${response.error}');
      }
    } catch (e) {
      setEarningsError('Exception fetching earnings summary: $e');
    } finally {
      _setEarningsLoading(false);
    }
  }

  Future<void> refreshEarningsData() async {
    await Future.wait([
      getMyBalance(),
      getEarningsSummary(),
      getEarningsHistory(),
    ]);
  }

  void _setBalanceLoading(bool value) {
    _isBalanceLoading = value;
    notifyListeners();
  }

  void _setEarningsLoading(bool value) {
    _isEarningsLoading = value;
    notifyListeners();
  }

  // -----------------------------------
  // Account State Management
  // -----------------------------------
  Future<void> changeAccountState(int accountState) async {
    if (_token == null) return;
    setAccountStateError(null);
    _setAccountStateLoading(true);
    try {
      final response = await WorkerApi.changeAccountState(accountState);
      if (response.success) {
        await Future.wait([
          fetchWorkerInfo(),
          fetchMyServices(),
        ]);
      } else {
        setAccountStateError(
            response.error ?? 'Failed to change account state.');
      }
    } catch (e) {
      setAccountStateError('Exception changing account state: $e');
    } finally {
      _setAccountStateLoading(false);
    }
  }

  void _setAccountStateLoading(bool value) {
    _isAccountStateLoading = value;
    notifyListeners();
  }

  // -----------------------------------
  // User Data Management
  // -----------------------------------
  Future<void> _loadWorkerData() async {
    _token = await StorageManager.getString(StorageKeys.tokenKey);

    try {
      if (_token != null) {
        final userInfoSuccess = await fetchWorkerInfo();
        if (userInfoSuccess) {
          await getMyBalance();
          _initializeUsersControllers();
        } else {
          final refreshed = await TokenManager.instance.refreshToken();
          if (refreshed) {
            _token = TokenManager.instance.token;
            await initialize();
          } else {
            await clearData();
            await NavigationService.navigateToAndReplace(AppRoutes.userMain);
          }
        }
      }
    } catch (e) {
      setAuthError('Failed to load user data: $e');
    }
  }

  Future<bool> fetchWorkerInfo() async {
    if (_token == null) return false;
    setProfileError(null);
    _setProfileLoading(true);
    try {
      final response = await BothApi.getUserInfo();
      if (response.success && response.data != null) {
        _workerInfo = response.data;
        notifyListeners();
        return true;
      } else {
        setProfileError('Failed to fetch user info: ${response.error}');
        return false;
      }
    } catch (e) {
      setProfileError('Exception fetching user info: $e');
      return false;
    } finally {
      _setProfileLoading(false);
    }
  }

  void _setProfileLoading(bool value) {
    _isProfileLoading = value;
    notifyListeners();
  }

  Future<bool> editAccount(BuildContext context) async {
    try {
      _setProfileLoading(true);
      setProfileError(null);

      final request = AccountEditRequest(
        image: _selectedImage,
        fullName: fullNameController.text == _workerInfo!.fullName
            ? null
            : fullNameController.text,
        email: emailController.text == _workerInfo!.email
            ? null
            : emailController.text,
        city: cityController.text == _workerInfo!.city
            ? null
            : cityController.text,
        country: countryController.text == _workerInfo!.country
            ? null
            : countryController.text,
        phone: phoneController.text == (_workerInfo!.phone.toString())
            ? null
            : int.tryParse(phoneController.text),
        password:
            passwordController.text.isEmpty ? null : passwordController.text,
      );

      final response = await BothApi.editAccount(request);
      if (response.success && response.data != null) {
        _workerInfo = response.data;
        _initializeUsersControllers();
        _selectedImage = null;
        setImageError(null);
        notifyListeners();
        return true;
      }
      setProfileError('Failed to edit account: ${response.error}');
      return false;
    } catch (e) {
      setProfileError('Exception editing account: $e');
      return false;
    } finally {
      _setProfileLoading(false);
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
        _imageError = null;
        notifyListeners();
      }
    } catch (e) {
      if (context.mounted) {
        setImageError(AppLocalizations.of(context)!.generalError);
      }
    }
  }

  // -----------------------------------
  // Services Management
  // -----------------------------------

  Future<void> fetchMyServices() async {
    _setServiceLoading(true);
    setServicesError(null);
    try {
      final response = await WorkerApi.fetchMyServices();
      if (response.success && response.data != null) {
        _myServices = response.data!;
      } else {
        setServicesError(response.error);
      }
    } catch (e) {
      setServicesError('Failed to fetch my services: $e');
    } finally {
      _setServiceLoading(false);
    }
  }

  // Statistic Charts
  List<ServiceChartData> getServicesChartData() {
    final totalServices = myServices.length;
    final visibleServices =
        myServices.where((service) => service.active == 1).length;
    final hiddenServices = totalServices - visibleServices;
    return [
      ServiceChartData(
        'Services',
        visibleServices,
        hiddenServices,
      ),
    ];
  }

  // -----------------------------------
  // Notifications
  // -----------------------------------

  Future<void> fetchNotifications({bool forceRefresh = false}) async {
    // Prevent unnecessary API calls
    if (_isNotificationLoading) {
      debugPrint('WorkerManager: Notification fetch already in progress');
      return;
    }

    // Check if we need to refresh (cache for 30 seconds)
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

      // Fetch notifications and count in parallel for better performance
      final results = await Future.wait([
        BothApi.fetchNotifications(),
        BothApi.getNewNotificationsCount(),
        BothApi.getUnreadNotificationsCount(),
      ]);

      // Cast results to proper types
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
        debugPrint(
            'WorkerManager: Failed to fetch notifications: ${notificationsResponse.error}');
      }

      // Handle new count response
      if (newCountResponse.success && newCountResponse.data != null) {
        _newNotificationCount = newCountResponse.data!;
        debugPrint(
            'WorkerManager: New notification count: $_newNotificationCount');
      } else {
        debugPrint(
            'WorkerManager: Failed to get new count: ${newCountResponse.error}');
        // Fallback to local count
        _newNotificationCount = _notifications.where((n) => n.isNew).length;
      }

      // Handle unread count response
      if (unreadCountResponse.success && unreadCountResponse.data != null) {
        _unreadNotificationCount = unreadCountResponse.data!;
        debugPrint(
            'WorkerManager: Unread notification count: $_unreadNotificationCount');
      } else {
        debugPrint(
            'WorkerManager: Failed to get unread count: ${unreadCountResponse.error}');
        // Fallback to local count
        _unreadNotificationCount =
            _notifications.where((n) => !n.isRead).length;
      }
    } catch (e, stackTrace) {
      _setNotificationError(
          'Exception fetching notifications: ${e.toString()}');
      debugPrint('WorkerManager: Exception in fetchNotifications: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _setNotificationLoading(false);
    }
  }

  /// Enhanced method to fetch only notification counts (for home page badge)
  Future<void> fetchNotificationCounts() async {
    try {
      debugPrint('WorkerManager: Fetching notification counts...');

      final results = await Future.wait([
        BothApi.getNewNotificationsCount(),
        BothApi.getUnreadNotificationsCount(),
      ]);

      final newCountResponse = results[0];
      final unreadCountResponse = results[1];

      bool hasChanges = false;

      if (newCountResponse.success && newCountResponse.data != null) {
        final newCount = newCountResponse.data!;
        if (_newNotificationCount != newCount) {
          _newNotificationCount = newCount;
          hasChanges = true;
          debugPrint(
              'WorkerManager: Updated new notification count: $_newNotificationCount');
        }
      }

      if (unreadCountResponse.success && unreadCountResponse.data != null) {
        final unreadCount = unreadCountResponse.data!;
        if (_unreadNotificationCount != unreadCount) {
          _unreadNotificationCount = unreadCount;
          hasChanges = true;
          debugPrint(
              'WorkerManager: Updated unread notification count: $_unreadNotificationCount');
        }
      }

      if (hasChanges) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('WorkerManager: Exception in fetchNotificationCounts: $e');
    }
  }

  /// Enhanced mark all notifications as seen (when entering notifications screen)
  Future<void> markAllNotificationsAsSeenNew() async {
    debugPrint(
        'WorkerManager: markAllNotificationsAsSeenNew called. Current new count: $_newNotificationCount');

    if (_newNotificationCount == 0) {
      debugPrint('WorkerManager: No new notifications to mark as seen');
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
          'WorkerManager: Optimistically updated UI - marked $oldNewCount notifications as seen');
      notifyListeners();

      // Call the API to sync with backend
      final response = await BothApi.markNotificationsAsSeen();

      if (response.success) {
        debugPrint(
            'WorkerManager: Successfully synced seen status with backend');
        // Refresh counts to ensure consistency
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'WorkerManager: Failed to sync seen status: ${response.error}');
        // Revert optimistic update on failure
        _newNotificationCount = oldNewCount;
        _notifications = _notifications
            .map((notification) => notification.copyWith(
                  isNew: true,
                  seenAt: null,
                ))
            .toList();
        notifyListeners();

        _setNotificationError(
            'Failed to mark notifications as seen: ${response.error}');
      }
    } catch (e) {
      debugPrint(
          'WorkerManager: Exception in markAllNotificationsAsSeenNew: $e');
      _setNotificationError('Error marking notifications as seen: $e');
    }
  }

  /// Enhanced mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    debugPrint(
        'WorkerManager: markAllNotificationsAsRead called. Current unread count: $_unreadNotificationCount');

    if (_unreadNotificationCount == 0) {
      debugPrint('WorkerManager: No unread notifications to mark as read');
      return;
    }

    try {
      // Update local state immediately for better UX
      final oldUnreadCount = _unreadNotificationCount;
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

      debugPrint(
          'WorkerManager: Optimistically updated UI - marked $oldUnreadCount notifications as read');
      notifyListeners();

      // Call the API to sync with backend
      final response = await BothApi.markAllNotificationsAsRead();

      if (response.success) {
        debugPrint(
            'WorkerManager: Successfully synced read status with backend');
        // Refresh counts to ensure consistency
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'WorkerManager: Failed to sync read status: ${response.error}');
        // Revert optimistic update on failure
        _unreadNotificationCount = oldUnreadCount;
        // Revert to previous state (this is simplified - in production you'd want to store the previous state)
        await fetchNotifications(forceRefresh: true);

        _setNotificationError(
            'Failed to mark notifications as read: ${response.error}');
      }
    } catch (e) {
      debugPrint('WorkerManager: Exception in markAllNotificationsAsRead: $e');
      _setNotificationError('Error marking notifications as read: $e');
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

      // Update counts
      _newNotificationCount = _notifications.where((n) => n.isNew).length;
      _unreadNotificationCount = _notifications.where((n) => !n.isRead).length;

      notifyListeners();

      // Sync with backend
      final response = await BothApi.markNotificationsAsRead(notificationIds);

      if (response.success) {
        debugPrint(
            'WorkerManager: Successfully marked specific notifications as read');
        await fetchNotificationCounts();
      } else {
        debugPrint(
            'WorkerManager: Failed to mark specific notifications as read: ${response.error}');
        // Refresh to get correct state
        await fetchNotifications(forceRefresh: true);
        _setNotificationError(
            'Failed to mark notifications as read: ${response.error}');
      }
    } catch (e) {
      debugPrint('WorkerManager: Exception in markNotificationsAsRead: $e');
      await fetchNotifications(forceRefresh: true);
      _setNotificationError('Error marking notifications as read: $e');
    }
  }

  /// Reset notification error
  void clearNotificationError() {
    _notificationError = null;
    notifyListeners();
  }

  // Private helper methods
  void _setNotificationLoading(bool value) {
    _isNotificationLoading = value;
    notifyListeners();
  }

  void _setNotificationError(String? error) {
    _notificationError = error;
    notifyListeners();
  }

  // -----------------------------------
  // Add Service Management
  // -----------------------------------

  /// Fetches categories and subcategories for the Add Service screen.
  Future<void> fetchCategories() async {
    _setServiceLoading(true);
    setServicesError(null);

    _selectedCategory = null;
    _selectedSubcategory = null;

    try {
      final response = await WorkerApi.fetchCategories();

      if (response.success && response.data != null) {
        _categories = response.data!;
      } else {
        _setAddServiceError(response.error);
      }
    } catch (e) {
      _setAddServiceError('Failed to fetch categories: $e');
    } finally {
      _setServiceLoading(false);
    }
  }

  /// Sets the selected category and resets the subcategory.
  void setCategory(CategoryModel? category) {
    _selectedCategory = category;
    _selectedSubcategory = null;
    _addServiceError = null;
    notifyListeners();
  }

  void resetCategorySelection() {
    _selectedCategory = null;
    _selectedSubcategory = null;
    _addServiceError = null;
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

  /// Sets the selected subcategory.
  void setSubcategory(SubcategoryModel? subcategory) {
    _selectedSubcategory = subcategory;
    notifyListeners();
  }

  void setPricingType(String pricingType) {
    _selectedPricingType = pricingType;
    notifyListeners();
  }

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

  /// Create a new service
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
        return response.data!.serviceId!;
      } else {
        String errorMessage = response.error ?? 'Unknown error occurred';
        if (errorMessage.contains('validation')) {
          errorMessage = 'Please check all required fields and try again.';
        } else if (errorMessage.contains('network') ||
            errorMessage.contains('connection')) {
          errorMessage = 'Network error. Please check your connection.';
        }
        _setAddServiceError(errorMessage);
        return 0;
      }
    } catch (e) {
      String errorMessage = 'Failed to create service: $e';
      if (e.toString().contains('SocketException')) {
        errorMessage = 'No internet connection. Please try again.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      }
      _setAddServiceError(errorMessage);
      return 0;
    } finally {
      _setServiceLoading(false);
    }
  }

  void setServiceId(int id) {
    _editingServiceId = id;
    notifyListeners();
  }

  void setActive(bool value) {
    if (value == true) {
      _active = 1;
    } else {
      _active = 0;
    }

    notifyListeners();
  }

  /// Uploads it to the gallery for the service.
  Future<void> uploadServiceImage(
    BuildContext context,
    ImageSource source,
    int serviceId,
  ) async {
    try {
      _setServiceLoading(true);
      await pickImage(context, source);

      if (_selectedImage != null) {
        final request = AddImageRequest(
          serviceId: serviceId,
          image: _selectedImage!,
        );

        final response = await WorkerApi().addGalleryImage(request);
        if (response.success && response.data != null) {
          _galleryImages.add(response.data!);
        } else {
          _setAddServiceError(response.error);
        }
      }
    } catch (e) {
      _setAddServiceError('Failed to upload image: $e');
    } finally {
      _setServiceLoading(false);
    }
  }

  /// Removes an image from the gallery using the image ID.
  Future<void> removeServiceImage(String imageName) async {
    _setServiceLoading(true);
    try {
      final response = await WorkerApi().removeGalleryImage(imageName);
      if (response.success && response.data == true) {
        galleryImages.removeWhere((image) => image.image == imageName);
      } else {
        _setAddServiceError(response.error);
      }
    } catch (e) {
      _setAddServiceError('Failed to remove image: $e');
    } finally {
      _setServiceLoading(false);
    }
  }

  /// Validates all inputs before submitting the service.
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

    double? currentPrice = getCurrentPrice();
    if (currentPrice == null || currentPrice <= 0) {
      String priceLabel = _selectedPricingType == 'hourly'
          ? 'hourly rate'
          : _selectedPricingType == 'daily'
              ? 'daily rate'
              : 'fixed price';
      _setAddServiceError('Please enter a valid $priceLabel.');
      return false;
    }

    if (_experienceController.text.isEmpty ||
        int.tryParse(_experienceController.text)! < 0) {
      _setAddServiceError('Please enter valid years of experience.');
      return false;
    }

    _setAddServiceError(null);
    return true;
  }

  /// Resets all Add Service related state.
  void resetServiceState() {
    _selectedCategory = null;
    _selectedSubcategory = null;
    _selectedImage = null;
    _galleryImages.clear();
    _addServiceError = null;
    _selectedPricingType = 'hourly';
    _hourlyPriceController.clear();
    _dailyPriceController.clear();
    _fixedPriceController.clear();
    _experienceController.clear();
    _descriptionController.clear();
    notifyListeners();
  }

  // -----------------------------------
  // Navigation
  // -----------------------------------
  /// Sets the current index for navigation.
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _initializeUsersControllers() {
    final user = _workerInfo;
    _fullNameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone?.toString() ?? '';
    _cityController.text = user?.city ?? '';
    _countryController.text = user?.country ?? '';
  }

  void initializeServiceControlles(MyServicesModel service) {
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
    setHasCertificate(service.hasCertificate == 0 ? false : true);
    _galleryImages =
        List.from(service.gallary.map((img) => AddImageModel(image: img)));

    notifyListeners();
  }

  /// Clears all authentication data.
  Future<void> clearData() async {
    _token = null;
    _workerInfo = null;

    // Clear all errors
    clearAllErrors();

    // Clear notifications data
    _notifications.clear();
    _isNotificationLoading = false;
    _newNotificationCount = 0;
    _unreadNotificationCount = 0;
    _notificationError = null;
    _lastNotificationFetch = null;

    _earningsHistory.clear();
    _earningsSummary = null;
    _isEarningsLoading = false;
    _earningsError = null;

    await StorageManager.remove(StorageKeys.tokenKey);
    await StorageManager.remove(StorageKeys.accountTypeKey);

    await TokenManager.instance.clearToken();
    _currentIndex = 0;
    notifyListeners();
  }

  /// Sets the service loading state for Add Service operations.
  void _setServiceLoading(bool value) {
    _isServiceLoading = value;
    notifyListeners();
  }

  void setHasCertificate(bool? value) {
    _hasCertificate = value ?? false;
    notifyListeners();
  }

  set selectedImage(File? value) {
    _selectedImage = value;
    notifyListeners();
  }

  set galleryImages(List<AddImageModel> value) {
    _galleryImages = value;
    notifyListeners();
  }

  void setImageError(String? message) {
    _imageError = message;
    notifyListeners();
  }

  void _setAddServiceError(String? message) {
    _addServiceError = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    _transitController.dispose();
    _institutionController.dispose();
    _accountController.dispose();
    _hourlyPriceController.dispose();
    _dailyPriceController.dispose();
    _fixedPriceController.dispose();
    super.dispose();
  }
}

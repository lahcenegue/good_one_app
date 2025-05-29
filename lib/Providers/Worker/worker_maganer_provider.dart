import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Features/Worker/Models/balance_model.dart';
import 'package:good_one_app/Features/Worker/Models/chart_models.dart';
import 'package:good_one_app/Features/Worker/Models/withdrawal_model.dart';
import 'package:good_one_app/Features/Worker/Presentation/Widgets/withdrawal_result.dart';
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

class WorkerManagerProvider extends ChangeNotifier {
  // Authentication State
  String? _token;
  UserInfo? _workerInfo;

  String? _error;

  // UI State
  int _currentIndex = 0;
  bool _isLoading = false;

  //
  BalanceModel? _balance;
  bool _isBankSelected = true;
  WithdrawalModel? _withdrawalModel;
  List<WithdrawStatus>? _withdrawStatus;

  // Withdrawal Dialog State
  bool _isWithdrawalLoading = false;
  bool _saveAccountInfo = true;

  // Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //
  final TextEditingController _ammountController = TextEditingController();
  final TextEditingController _transitController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

  // User Profile Image Handling
  File? _selectedImage;
  String? _imageError;
  final ImagePicker _picker = ImagePicker();

  // Notification Data
  List<NotificationModel> _notifications = [];
  bool _isNotificationLoading = false;

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
  String _selectedPricingType = 'hourly'; // Default to hourly

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
  BalanceModel? get balance => _balance;
  String? get error => _error;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isNotificationLoading => _isNotificationLoading;
  String? get imageError => _imageError;
  File? get selectedImage => _selectedImage;

  bool get isBankSelected => _isBankSelected;
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

  TextEditingController get amountController => _ammountController;
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
  // Initialization
  // -----------------------------------
  /// Initializes the provider by loading user data and fetching notifications.
  Future<void> initialize() async {
    setError(null);
    _setLoading(true);

    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);
      if (_token != null) {
        await Future.wait([
          _loadWorkerData(),
          fetchNotifications(),
          fetchMyServices(),
        ]);
      } else {
        await clearData();
        await NavigationService.navigateToAndReplace(AppRoutes.userMain);
      }
    } catch (e) {
      setError('Initialization failed: $e');
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

      // Load saved Interac info
      final interacAccount =
          await StorageManager.getObject(StorageKeys.interacAccountKey);
      if (interacAccount != null) {
        _emailController.text = interacAccount['email'] ?? '';
      }

      notifyListeners();
    } catch (e) {
      print('Error loading saved account info: $e');
    }
  }

  /// Saves account information to storage
  Future<void> saveAccountInfos(bool isBankTab) async {
    if (!_saveAccountInfo) return;

    try {
      if (isBankTab) {
        // Save bank account info
        final bankAccountData = {
          'fullName': _fullNameController.text.trim(),
          'transit': _transitController.text.trim(),
          'institution': _institutionController.text.trim(),
          'account': _accountController.text.trim(),
        };
        await StorageManager.setObject(
            StorageKeys.bankAccountKey, bankAccountData);
      } else {
        // Save Interac info
        final interacAccountData = {
          'email': _emailController.text.trim(),
        };
        await StorageManager.setObject(
            StorageKeys.interacAccountKey, interacAccountData);
      }
    } catch (e) {
      print('Error saving account info: $e');
    }
  }

  /// Validates the withdrawal form
  bool validateWithdrawalForm(bool isBankTab) {
    if (_ammountController.text.trim().isEmpty ||
        (double.tryParse(_ammountController.text.trim()) ?? 0) <= 0) {
      return false;
    }
    if (isBankTab) {
      // Validate bank account form
      return _ammountController.text.trim().isNotEmpty &&
          _fullNameController.text.trim().isNotEmpty &&
          _transitController.text.trim().isNotEmpty &&
          _institutionController.text.trim().isNotEmpty &&
          _accountController.text.trim().isNotEmpty;
    } else {
      // Validate Interac form
      return _ammountController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _emailController.text.contains('@');
    }
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

  void setBankSelected(bool bankSelected) {
    _isBankSelected = bankSelected;
    print('====================== selected banc: $_isBankSelected');
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
        amount: double.tryParse(_ammountController.text),
        method: _isBankSelected ? 'bank' : 'interac',
        name: _fullNameController.text,
        transit: int.tryParse(_transitController.text),
        institution: int.tryParse(_institutionController.text),
        account: int.tryParse(_accountController.text),
        email: _emailController.text,
      );
      if (request.amount == null || request.amount! <= 0) {
        return WithdrawalAttemptResult(
          false,
          errorMessage: "Invalid amount entered.",
        );
      }

      if (_isBankSelected) {
        if (request.name!.isEmpty ||
            request.transit == null ||
            request.institution == null ||
            request.account == null) {
          return WithdrawalAttemptResult(
            false,
            errorMessage: "Invalid data.",
          );
        }
      } else {
        // Interac
        if (request.email == null ||
            request.email!.isEmpty ||
            !request.email!.contains('@')) {
          return WithdrawalAttemptResult(
            false,
            errorMessage: "Invalid email for Interac.",
          );
        }
      }

      final response = await WorkerApi.withdrawRequest(request);
      if (response.success) {
        _withdrawalModel = response.data;

        notifyListeners();
        return WithdrawalAttemptResult(true);
      } else {
        return WithdrawalAttemptResult(
          false,
          errorMessage: response.error ??
              'Failed to process withdrawal. Please try again.',
        );
      }
    } catch (e) {
      print("Exception in requestWithdrawal: $e");
      return WithdrawalAttemptResult(
        false,
        errorMessage:
            'An unexpected error occurred. Please check your connection and try again.',
      );
    }
  }

  /// Handles withdrawal form submission
  Future<bool> submitWithdrawal(
    BuildContext context,
    bool isBankTab,
  ) async {
    if (!validateWithdrawalForm(isBankTab)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.requiredFields),
          backgroundColor: Colors.red[600],
        ),
      );
      return false;
    }

    setWithdrawalLoading(true);

    WithdrawalAttemptResult result;

    try {
      // Save account info if requested
      await saveAccountInfos(isBankTab);

      result = await requestWithdrawal();

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.withdrawalRequestSubmitted,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return true;
      } else {
        // Show failure SnackBar using the error set by requestWithdrawal
        final String errorMessage = _error ??
            AppLocalizations.of(context)!.generalError; // Use a fallback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[600],
          ),
        );
        return false;
      }
    } catch (e) {
      print("Exception in submitWithdrawal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.generalError),
          backgroundColor: Colors.red[600],
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
    setError(null);
    _setLoading(true);
    try {
      final response = await WorkerApi.withdrawStatus();
      if (response.success && response.data != null) {
        _withdrawStatus = response.data;
        notifyListeners();
        _setLoading(false);
        return true;
      } else {
        setError('failed to fetching withdraw status');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Exception fetching withdraw status');
      _setLoading(false);
      return false;
    }
  }

  // Statistic Charts
  List<ServiceChartData> getServicesChartData() {
    final totalServices = myServices.length;
    final visibleServices =
        myServices.where((service) => service.active == 1).length;
    final hiddenServices = totalServices - visibleServices;
    return [ServiceChartData('Services', visibleServices, hiddenServices)];
  }

  // Load vacation status from storage
  Future<void> changeAccountState(int accountState) async {
    if (_token == null) return;
    setError(null);
    _setLoading(true);
    try {
      final response = await WorkerApi.changeAccountState(accountState);
      if (response.success) {
        await Future.wait([
          fetchWorkerInfo(),
          fetchMyServices(),
        ]);
      } else {
        setError(response.error ?? 'Failed to change account state.');
      }
    } catch (e) {
      setError('Exception fetching user info: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getMyBalance() async {
    if (_token == null) return;
    setError(null);
    _setLoading(true);
    try {
      final response = await WorkerApi.getMyBalance();
      if (response.success && response.data != null) {
        _balance = response.data!;
        notifyListeners();
      }
    } catch (e) {
      setError('Exception fetch my balance: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Loads user data from storage and fetches user info if a token is available.
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
      setError('Failed to load user data: $e');
    }
  }

  // -----------------------------------
  // User Info Management
  // -----------------------------------
  /// Fetches user information from the API.
  Future<bool> fetchWorkerInfo() async {
    if (_token == null) return false;
    setError(null);
    _setLoading(true);
    try {
      final response = await BothApi.getUserInfo();
      if (response.success && response.data != null) {
        _workerInfo = response.data;
        notifyListeners();
        return true;
      } else {
        setError('Failed to fetch user info: ${response.error}');
        return false;
      }
    } catch (e) {
      setError('Exception fetching user info: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Edits the user's account details.
  Future<bool> editAccount(BuildContext context) async {
    try {
      _setLoading(true);

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
      setError('Failed to edit account: ${response.error}');
      return false;
    } catch (e) {
      setError('Exception editing account: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Picks an image
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
  // Notification Management
  // -----------------------------------
  /// Fetches notifications for the user.
  Future<void> fetchNotifications() async {
    _setNotificationLoading(true);

    setError(null);
    try {
      final response = await BothApi.fetchNotifications();
      if (response.success && response.data != null) {
        _notifications = response.data!;

        notifyListeners();
      } else {
        setError('Failed to load notifications: ${response.error}');
      }
    } catch (e) {
      setError('Exception fetching notifications: $e');
    } finally {
      _setNotificationLoading(false);
    }
  }

  // -----------------------------------
  // My Services
  // -----------------------------------
  /// Fetches my services
  Future<void> fetchMyServices() async {
    _setServiceLoading(true);
    setError(null);
    try {
      _setServiceLoading(true);

      final response = await WorkerApi.fetchMyServices();
      if (response.success && response.data != null) {
        _myServices = response.data!;
      } else {
        setError(response.error);
      }
      _setServiceLoading(false);
    } catch (e) {
      setError('Failed to fetch my services: $e');
      _setServiceLoading(false);
    }
  }

  // -----------------------------------
  // Add Service Management
  // -----------------------------------
  /// Fetches categories and subcategories for the Add Service screen.

  Future<void> fetchCategories() async {
    _setServiceLoading(true);

    _selectedCategory = null;
    _selectedSubcategory = null;

    final response = await WorkerApi.fetchCategories();

    if (response.success && response.data != null) {
      _categories = response.data!;
    } else {
      _setAddServiceError(response.error);
    }
    _setServiceLoading(false);
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
    // Also reset pricing selections for new service
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
        _setServiceLoading(false);
        await fetchMyServices();
        return response.data!.serviceId!;
      } else {
        _setServiceLoading(false);
        // Enhanced error handling
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
      _setServiceLoading(false);
      return 0;
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

      _setServiceLoading(false);
    } catch (e) {
      _setAddServiceError('Failed to upload image: $e');
      _setServiceLoading(false);
    }
  }

  /// Removes an image from the gallery using the image ID.
  Future<void> removeServiceImage(String imageName) async {
    _setServiceLoading(true);
    final response = await WorkerApi().removeGalleryImage(imageName);
    if (response.success && response.data == true) {
      galleryImages.removeWhere((image) => image.image == imageName);
    } else {
      _setAddServiceError(response.error);
    }
    _setServiceLoading(false);
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

    // if (_servicePriceController.text.isEmpty ||
    //     double.tryParse(_servicePriceController.text)! <= 0) {
    //   _setAddServiceError('Please enter a valid service price.');
    //   return false;
    // }
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

  void _setNotificationLoading(bool value) {
    _isNotificationLoading = value;
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
        _dailyPriceController.clear(); // Clear other controllers
        _fixedPriceController.clear();
        break;
      case 'daily':
        _dailyPriceController.text = service.costPerDay?.toString() ?? '';
        _hourlyPriceController.clear(); // Clear other controllers
        _fixedPriceController.clear();
        break;
      case 'fixed':
        _fixedPriceController.text = service.fixedPrice?.toString() ?? '';
        _hourlyPriceController.clear(); // Clear other controllers
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

    // Don't set category/subcategory here - let the UI handle it
    notifyListeners();
  }

  /// Clears all authentication data.
  Future<void> clearData() async {
    _token = null;
    _workerInfo = null;
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

  /// Sets a general error message.
  void setError(String? message) {
    _error = message;
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

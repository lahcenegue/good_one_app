import 'dart:io';

import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Infrastructure/storage/storage_manager.dart';
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
import 'package:good_one_app/Features/auth/Services/token_manager.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkerManagerProvider extends ChangeNotifier {
  // Authentication State
  String? _token;
  UserInfo? _workerInfo;
  String? _error;

  // UI State
  int _currentIndex = 0;
  bool _isLoading = false;

  // Form Controllers for User Info
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // User Profile Image Handling
  File? _selectedImage;
  String? _imageError;
  final ImagePicker _picker = ImagePicker();

  // Notification Data
  List<NotificationModel> _notifications = [];
  bool _isNotificationLoading = false;
  String? _notificationError;

  // My services
  List<MyServicesModel> _myServices = [];

  // Add Service State
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  SubcategoryModel? _selectedSubcategory;
  List<AddImageModel> _galleryImages = [];
  String? _serviceError;
  bool _isServiceLoading = false;
  bool _hasCertificate = false;

  // Form controllers for Add Service
  final TextEditingController _servicePriceController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Getters for Authentication and User Info
  String? get token => _token;
  UserInfo? get workerInfo => _workerInfo;
  String? get error => _error;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isNotificationLoading => _isNotificationLoading;
  String? get notificationError => _notificationError;
  String? get imageError => _imageError;
  File? get selectedImage => _selectedImage;
  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get cityController => _cityController;
  TextEditingController get countryController => _countryController;
  TextEditingController get passwordController => _passwordController;

  // Getters for Add Service
  List<CategoryModel> get categories => _categories;
  List<MyServicesModel> get myServices => _myServices;
  CategoryModel? get selectedCategory => _selectedCategory;
  SubcategoryModel? get selectedSubcategory => _selectedSubcategory;

  List<AddImageModel> get galleryImages => _galleryImages;
  String? get serviceError => _serviceError;
  bool get isServiceLoading => _isServiceLoading;
  bool get hasCertificate => _hasCertificate;
  TextEditingController get servicePriceController => _servicePriceController;
  TextEditingController get experienceController => _experienceController;
  TextEditingController get descriptionController => _descriptionController;

  WorkerManagerProvider() {
    initialize();
  }

  // -----------------------------------
  // Initialization
  // -----------------------------------
  /// Initializes the provider by loading user data and fetching notifications.
  Future<void> initialize() async {
    await _loadUserData();
    await fetchNotifications();
  }

  /// Loads user data from storage and fetches user info if a token is available.
  Future<void> _loadUserData() async {
    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);
      if (_token != null) {
        final userInfoSuccess = await fetchUserInfo();
        if (userInfoSuccess) _initializeControllers();

        if (!userInfoSuccess) {
          final refreshed = await TokenManager.instance.refreshToken();
          if (refreshed) {
            _token = TokenManager.instance.token;
            await fetchUserInfo();
          } else {
            await clearAuthData();
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
  Future<bool> fetchUserInfo() async {
    if (_token == null) return false;
    _setLoading(true);
    try {
      final response = await BothApi.getUserInfo();
      if (response.success && response.data != null) {
        _workerInfo = response.data;
        notifyListeners();
        return true;
      }
      setError('Failed to fetch user info: ${response.error}');
      return false;
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

        _initializeControllers();
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
      setImageError(AppLocalizations.of(context)!.generalError);
    }
  }

  // -----------------------------------
  // Notification Management
  // -----------------------------------
  /// Fetches notifications for the user.
  Future<void> fetchNotifications() async {
    _setNotificationLoading(true);
    _setNotificationError(null);
    try {
      debugPrint('Fetching notifications...');
      final response = await BothApi.fetchNotifications();
      if (response.success && response.data != null) {
        _notifications = response.data!;
        debugPrint('Notifications fetched: ${_notifications.length}');
        if (_notifications.isEmpty) {
          debugPrint('No valid notifications returned after parsing');
        } else {
          for (var n in _notifications) {
            debugPrint('Notification: ${n.userName}, ${n.action}');
          }
        }
        notifyListeners();
      } else {
        _setNotificationError(
            'Failed to load notifications: ${response.error}');
      }
    } catch (e) {
      _setNotificationError('Exception fetching notifications: $e');
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
    try {
      _setServiceLoading(true);

      final response = await WorkerApi.fetchMyServices();
      if (response.success && response.data != null) {
        _myServices = response.data!;
      } else {
        _setServiceError(response.error);
      }
      _setServiceLoading(false);
    } catch (e) {
      _setServiceError('Failed to fetch my services: $e');
      _setServiceLoading(false);
    }
  }

  // -----------------------------------
  // Add Service Management
  // -----------------------------------
  /// Fetches categories and subcategories for the Add Service screen.

  Future<void> fetchCategories() async {
    print('==============fetch categorie==================');
    _setServiceLoading(true);
    final response = await WorkerApi.fetchCategories();
    if (response.success && response.data != null) {
      _categories = response.data!;
    } else {
      _setServiceError(response.error);
    }
    _setServiceLoading(false);
  }

  /// Sets the selected category and resets the subcategory.
  void setCategory(CategoryModel? category) {
    _selectedCategory = category;
    _selectedSubcategory = null;
    notifyListeners();
  }

  /// Sets the selected subcategory.
  void setSubcategory(SubcategoryModel? subcategory) {
    _selectedSubcategory = subcategory;
    notifyListeners();
  }

  /// Create a new service
  Future<int> createNewService() async {
    if (!validateServiceInputs()) return 0;

    _setServiceLoading(true);
    try {
      final request = CreateServiceRequest(
        category: _selectedCategory!.name,
        categoryId: _selectedCategory!.id,
        subCategoryId: _selectedSubcategory!.id,
        price: double.tryParse(_servicePriceController.text),
        description: _descriptionController.text,
        experience: int.tryParse(_experienceController.text),
        license: _selectedImage,
      );

      final response = await WorkerApi.createNewService(request);
      if (response.success && response.data != null) {
        _setServiceLoading(false);
        return response.data!.serviceId!;
      } else {
        _setServiceLoading(false);
        _setServiceError(response.error);
        return 0;
      }
    } catch (e) {
      _setServiceError('Failed to create a new service: $e');
      _setServiceLoading(false);
      return 0;
    }
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
          _setServiceError(response.error);
        }
      }

      _setServiceLoading(false);
    } catch (e) {
      _setServiceError('Failed to upload image: $e');
      _setServiceLoading(false);
    }
  }

  /// Removes an image from the gallery using the image ID.
  Future<void> removeServiceImage(int imageId) async {
    _setServiceLoading(true);
    final response = await WorkerApi().removeGalleryImage(imageId);
    if (response.success && response.data == true) {
    } else {
      _setServiceError(response.error);
    }
    _setServiceLoading(false);
  }

  /// Validates all inputs before submitting the service.
  bool validateServiceInputs() {
    if (_selectedCategory == null) {
      _setServiceError('Please select a service category.');
      return false;
    }
    if (_selectedSubcategory == null) {
      _setServiceError('Please select a subcategory.');
      return false;
    }
    if (_descriptionController.text.isEmpty) {
      _setServiceError('Please enter a service description.');
      return false;
    }
    if (_servicePriceController.text.isEmpty ||
        double.tryParse(_servicePriceController.text)! <= 0) {
      _setServiceError('Please enter a valid service price.');
      return false;
    }
    if (_experienceController.text.isEmpty ||
        int.tryParse(_experienceController.text)! < 0) {
      _setServiceError('Please enter valid years of experience.');
      return false;
    }

    _setServiceError(null);
    return true;
  }

  /// Resets all Add Service related state.
  void resetServiceState() {
    _selectedCategory = null;
    _selectedSubcategory = null;
    _selectedImage = null;
    _galleryImages.clear();
    _serviceError = null;
    _servicePriceController.clear();
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

  void _initializeControllers() {
    final user = _workerInfo;
    _fullNameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone?.toString() ?? '';
    _cityController.text = user?.city ?? '';
    _countryController.text = user?.country ?? '';
  }

  /// Clears all authentication data.
  Future<void> clearAuthData() async {
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

  void setHasCertificate(bool value) {
    _hasCertificate = value;
    notifyListeners();
  }

  /// Sets a general error message.
  void setError(String? message) {
    _error = message;
    if (message != null) print(message);
    notifyListeners();
  }

  void setImageError(String? message) {
    _imageError = message;
    notifyListeners();
  }

  void _setNotificationError(String? message) {
    _notificationError = message;
    if (message != null) debugPrint(message);
    notifyListeners();
  }

  void _setServiceError(String? message) {
    _serviceError = message;
    notifyListeners();
  }
}

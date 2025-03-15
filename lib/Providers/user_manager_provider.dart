import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Core/Infrastructure/storage/storage_manager.dart';
import 'package:good_one_app/Features/Both/Models/account_edit_request.dart';
import 'package:good_one_app/Features/Both/Models/user_info.dart';
import 'package:good_one_app/Features/Notifications/Models/notification_model.dart';
import 'package:good_one_app/Features/User/models/contractor.dart';
import 'package:good_one_app/Features/User/models/service_category.dart';
import 'package:good_one_app/Features/User/Services/user_api.dart';
import 'package:good_one_app/Features/auth/Services/token_manager.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserManagerProvider extends ChangeNotifier {
  // Authentication State
  String? _token;
  UserInfo? _userInfo;
  String? _error;

  // UI State
  int _currentIndex = 0;
  bool _isLoading = false;

  // Form Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Image
  File? _selectedImage;
  String? _imageError;
  final ImagePicker _picker = ImagePicker();

  // Search State
  String _searchQuery = '';
  String _contractorsByServiceSearch = '';

  // Contractor Data
  Contractor? _selectedContractor;
  final List<ServiceCategory> _categories = [];
  final List<Contractor> _bestContractors = [];
  final List<Contractor> _contractorsByService = [];

  // Notification Data
  List<NotificationModel> _notifications = [];
  bool _isNotificationLoading = false;
  String? _notificationError;

  // Getters
  String? get token => _token;
  UserInfo? get userInfo => _userInfo;
  bool get isAuthenticated => _token != null && _userInfo != null;
  String? get error => _error;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;

  String get searchQuery => _searchQuery;
  Contractor? get selectedContractor => _selectedContractor;
  List<ServiceCategory> get categories => List.unmodifiable(_categories);
  List<Contractor> get bestContractors => List.unmodifiable(_bestContractors);
  List<Contractor> get contractorsByService =>
      _contractorsByServiceSearch.isEmpty
          ? List.unmodifiable(_contractorsByService)
          : _contractorsByService.where(_matchesSearchQuery).toList();

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

  // Constructor
  UserManagerProvider() {
    _initialize();
  }

  // Initialization
  Future<void> _initialize() async {
    await _loadUserData();
    await fetchNotifications();
  }

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
      await _fetchPublicData();
    } catch (e) {
      setError('Failed to load user data: $e');
    }
  }

  // State Management
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> initialize() async {
    setError(null);
    _setLoading(true);
    try {
      if (_token != null) {
        await Future.wait(
          [
            _fetchPublicData(),
            fetchUserInfo(),
            fetchNotifications(),
          ],
        );
      } else {
        await _fetchPublicData();
      }
    } catch (e) {
      setError('Initialization failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateToken(String newToken) async {
    _token = newToken;
    await StorageManager.setString(StorageKeys.tokenKey, newToken);
    await _loadUserData();
  }

  Future<void> clearData() async {
    await clearAuthData();
    await _fetchPublicData();
  }

  Future<void> clearAuthData() async {
    _token = null;
    _userInfo = null;
    await StorageManager.remove(StorageKeys.tokenKey);
    await StorageManager.remove(StorageKeys.accountTypeKey);
    await TokenManager.instance.clearToken();
    _currentIndex = 0;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _error = message;
    if (message != null) debugPrint(message);
    notifyListeners();
  }

  void setImageError(String? message) {
    _imageError = message;
    notifyListeners();
  }

  // User Info
  Future<bool> fetchUserInfo() async {
    if (_token == null) return false;
    _setLoading(true);
    try {
      final response = await UserApi.getUserInfo();
      if (response.success && response.data != null) {
        _userInfo = response.data;
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

  void _initializeControllers() {
    final user = _userInfo;
    _fullNameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone?.toString() ?? '';
    _cityController.text = user?.city ?? '';
    _countryController.text = user?.country ?? '';
  }

  Future<bool> editAccount(BuildContext context) async {
    try {
      _setLoading(true);

      print(emailController.text);

      final request = AccountEditRequest(
        image: _selectedImage,
        fullName: fullNameController.text == _userInfo!.fullName
            ? null
            : fullNameController.text,
        email: emailController.text == _userInfo!.email
            ? null
            : emailController.text,
        city:
            cityController.text == _userInfo!.city ? null : cityController.text,
        country: countryController.text == _userInfo!.country
            ? null
            : countryController.text,
        phone: phoneController.text == (_userInfo!.phone.toString())
            ? null
            : int.tryParse(phoneController.text),
        password:
            passwordController.text.isEmpty ? null : passwordController.text,
      );

      print(request.email);

      final response = await UserApi.editAccount(request);
      if (response.success && response.data != null) {
        _userInfo = response.data;

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
      setImageError(AppLocalizations.of(context)!.generalError);
    }
  }

  // Categories and Contractors
  Future<void> _fetchPublicData() async {
    await Future.wait(
      [
        fetchCategories(),
        fetchBestContractors(),
      ],
    );
  }

  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      final response = await UserApi.getCategories();
      if (response.success && response.data != null) {
        _categories
          ..clear()
          ..addAll(response.data!);
        print('Categories fetched: ${_categories.length}');
        notifyListeners();
      } else {
        setError('Failed to fetch categories: ${response.error}');
      }
    } catch (e) {
      setError('Exception fetching categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBestContractors() async {
    _setLoading(true);
    try {
      final response = await UserApi.getBestContractors();
      if (response.success && response.data != null) {
        _bestContractors
          ..clear()
          ..addAll(response.data!);
        print('Best contractors fetched: ${_bestContractors.length}');
        notifyListeners();
      } else {
        setError('Failed to fetch contractors: ${response.error}');
      }
    } catch (e) {
      setError('Exception fetching contractors: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchContractorsByService(int? id) async {
    _setLoading(true);
    try {
      final response = await UserApi.getContractorsByService(id: id);
      if (response.success && response.data != null) {
        _contractorsByService
          ..clear()
          ..addAll(response.data!);
        debugPrint(
            'Contractors by service fetched: ${_contractorsByService.length}');
        notifyListeners();
      } else {
        setError('Failed to fetch contractors by service: ${response.error}');
      }
    } catch (e) {
      setError('Exception fetching contractors by service: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchNotifications() async {
    _setNotificationLoading(true);
    _setNotificationError(null);
    try {
      debugPrint('Fetching notifications...');
      final response = await UserApi.fetchNotifications();
      if (response.success && response.data != null) {
        _notifications = response.data!;
        debugPrint('Notifications fetched: ${_notifications.length}');
        if (_notifications.isEmpty) {
          debugPrint('No valid notifications returned after parsing');
        } else {
          _notifications.forEach(
              (n) => debugPrint('Notification: ${n.userName}, ${n.action}'));
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

  void setSelectedContractor(Contractor contractor) {
    _selectedContractor = contractor;
    notifyListeners();
  }

  void clearSelectedContractor() {
    _selectedContractor = null;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateContractorsByServiceSearch(String query) {
    _contractorsByServiceSearch = query;
    notifyListeners();
  }

  bool _matchesSearchQuery(Contractor contractor) {
    final query = _contractorsByServiceSearch.toLowerCase();
    return contractor.fullName!.toLowerCase().contains(query) ||
        contractor.service!.toLowerCase().contains(query);
  }

  List<Contractor> get filteredBestContractors {
    if (_searchQuery.isEmpty) return List.unmodifiable(_bestContractors);
    final query = _searchQuery.toLowerCase();
    return _bestContractors
        .where((c) =>
            c.fullName!.toLowerCase().contains(query) ||
            c.service!.toLowerCase().contains(query))
        .toList();
  }

  void _setNotificationLoading(bool value) {
    _isNotificationLoading = value;
    notifyListeners();
  }

  void _setNotificationError(String? message) {
    _notificationError = message;
    if (message != null) debugPrint(message);
    notifyListeners();
  }
}

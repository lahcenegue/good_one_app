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
  TextEditingController get passwordController => _passwordController;

  // Constructor
  UserManagerProvider() {
    initialize();
  }

  // Initialization
  Future<void> initialize() async {
    setError(null);
    _setLoading(true);
    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);
      if (_token != null) {
        await Future.wait(
          [
            _loadUserData(),
            _fetchPublicData(),
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

  Future<void> _loadUserData() async {
    try {
      final userInfoSuccess = await fetchUserInfo();

      if (userInfoSuccess) {
        _initializeControllers();
      } else {
        final refreshed = await TokenManager.instance.refreshToken();
        if (refreshed) {
          _token = TokenManager.instance.token;
          await fetchUserInfo();
          await _fetchPublicData();
        } else {
          await clearData();
          await _fetchPublicData();
          _currentIndex = 3;
          notifyListeners();
        }
      }
    } catch (e) {
      setError('Failed to load user data: $e');
    }
  }

  // State Management
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> clearData() async {
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
      final response = await BothApi.getUserInfo();

      if (response.success && response.data != null) {
        _userInfo = response.data;
        notifyListeners();
        return true;
      } else {
        setError('Failed to fetch user info');
        return false;
      }
    } catch (e) {
      setError('Exception fetching user info');
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
      if (context.mounted) {
        setImageError(AppLocalizations.of(context)!.generalError);
      }
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

  void setSelectedContractor(Contractor contractor) {
    _selectedContractor = contractor;
    notifyListeners();
  }

  void clearSelectedContractor() {
    _selectedContractor = null;
    notifyListeners();
  }

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

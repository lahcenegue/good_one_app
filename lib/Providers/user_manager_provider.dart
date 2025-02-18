import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Core/Utils/storage_keys.dart';
import '../Core/infrastructure/storage/storage_manager.dart';
import '../Features/User/models/contractor.dart';
import '../Features/User/models/service_category.dart';
import '../Features/User/models/user_info.dart';
import '../Features/User/services/user_api.dart';
import '../Features/auth/Services/token_manager.dart';

class UserManagerProvider extends ChangeNotifier {
  String? _token;
  UserInfo? _userInfo;
  String _searchQuery = '';
  String _contractorsByServiceSearch = '';
  String? _error;
  int _currentIndex = 0;
  bool _isLoading = false;

  // Date and time selection properties
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedTime = '09:00';

  // Cached time slots
  final List<String> _cachedTimeSlots = List.generate(
    24,
    (index) => '${index.toString().padLeft(2, '0')}:00',
  );

  // Categories and contractors lists
  List<ServiceCategory> _categories = [];
  List<Contractor> _bestContractors = [];
  List<Contractor> _contractorsbyService = [];

  // Getters
  String? get token => _token;
  String get selectedTime => _selectedTime;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  UserInfo? get userInfo => _userInfo;
  bool get isAuthenticated => _token != null && _userInfo != null;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  List<String> get timeSlots => _cachedTimeSlots;
  List<ServiceCategory> get categories => _categories;
  List<Contractor> get bestContractors => _bestContractors;
  List<Contractor> get contractorsbyService => _contractorsbyService;

  String get formattedDateTime {
    final formatter = DateFormat('MMM dd, yyyy');
    return '${formatter.format(_selectedDay)} at $_selectedTime';
  }

  int get bookingTimestamp {
    final dateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      int.parse(_selectedTime.split(':')[0]),
      0,
    );
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  UserManagerProvider() {
    _initializeProvider();
  }

  // Navigation
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> _initializeProvider() async {
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _token = StorageManager.getString(StorageKeys.tokenKey);
      debugPrint('Loaded token: $_token');

      if (_token != null) {
        // Try to get user info with current token
        final userInfoSuccess = await fetchUserInfo();

        // If user info fails, try token refresh
        if (!userInfoSuccess && _token != null) {
          final refreshed = await TokenManager.instance.refreshToken();
          if (refreshed) {
            // Update token and try user info again
            _token = TokenManager.instance.token;
            await fetchUserInfo();
          } else {
            // If refresh fails, clear authentication
            await clearAuthData();
          }
        }
      }

      // Always fetch public data
      await _fetchPublicData();
    } catch (e) {
      _setError('Error loading user data: $e');
    }
  }

  // Initialize data
  Future<void> initialize() async {
    try {
      _setError(null);
      if (_token != null) {
        await Future.wait([
          _fetchPublicData(),
          fetchUserInfo(),
        ]);
      } else {
        await _fetchPublicData();
      }
    } catch (e) {
      _setError('Initialization error: $e');
    }
  }

  // Fetch public data method
  Future<void> _fetchPublicData() {
    return Future.wait([
      fetchCategories(),
      fetchBestContractors(),
    ]);
  }

  // Update token
  Future<void> updateToken(String newToken) async {
    _token = newToken;
    await StorageManager.setString(StorageKeys.tokenKey, newToken);
    await _loadUserData();
  }

  // Clear data on logout
  Future<void> clearData() async {
    await clearAuthData();
    // Reinitialize public data
    await _fetchPublicData();
  }

  // Fetch user info
  Future<bool> fetchUserInfo() async {
    if (_token == null) return false;

    try {
      _setLoading(true);
      final response = await UserApi.getUserInfo(token: _token);

      if (response.success && response.data != null) {
        _userInfo = response.data;
        debugPrint('User info fetched successfully: ${_userInfo?.fullName}');
        notifyListeners();
        return true;
      } else {
        _setError('Error fetching user info: ${response.error}');
        return false;
      }
    } catch (e) {
      _setError('Exception fetching user info: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearAuthData() async {
    _token = null;
    _userInfo = null;
    await StorageManager.remove(StorageKeys.tokenKey);
    await StorageManager.remove(StorageKeys.accountTypeKey);
    await TokenManager.instance.clearToken();
    setCurrentIndex(0);
    notifyListeners();
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    try {
      _setLoading(true);
      final response = await UserApi.getCategories();

      if (response.success && response.data != null) {
        _categories = response.data!;
        debugPrint('Categories fetched: ${_categories.length}');
        notifyListeners();
      } else {
        _setError('Error fetching categories: ${response.error}');
      }
    } catch (e) {
      _setError('Exception fetching categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch best contractors
  Future<void> fetchBestContractors() async {
    try {
      _setLoading(true);
      final response = await UserApi.getBestContractors();

      if (response.success && response.data != null) {
        _bestContractors = response.data!;
        debugPrint('Contractors fetched: ${_bestContractors.length}');
        notifyListeners();
      } else {
        _setError('Error fetching contractors: ${response.error}');
      }
    } catch (e) {
      _setError('Exception fetching contractors: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    if (errorMessage != null) {
      debugPrint(errorMessage);
    }
    notifyListeners();
  }

  // Search functionality
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Best contractors
  List<Contractor> get getBestContractors {
    if (_searchQuery.isEmpty) return _bestContractors;
    return _bestContractors.where(_matchesSearchQuery).toList();
  }

  bool _matchesSearchQuery(Contractor contractor) {
    final query = _searchQuery.toLowerCase();
    return contractor.fullName.toLowerCase().contains(query) ||
        contractor.service.toLowerCase().contains(query);
  }

  // Fetch contractors by service
  Future<void> fetchContractorsByService(int? id) async {
    try {
      _setLoading(true);
      final response = await UserApi.getContractorsByService(id: id);

      if (response.success && response.data != null) {
        _contractorsbyService = response.data!;
        debugPrint('Contractors fetched: ${_contractorsbyService.length}');
        notifyListeners();
      } else {
        _setError('Error fetching contractors by service: ${response.error}');
      }
    } catch (e) {
      _setError('Exception fetching contractors by service: $e');
    } finally {
      _setLoading(false);
    }
  }

  void updateContractorsByServiceSearch(String query) {
    _contractorsByServiceSearch = query;
    notifyListeners();
  }

  void clearContractorsByServiceSearch() {
    _contractorsByServiceSearch = '';
    notifyListeners();
  }

  List<Contractor> get getContractorsByService {
    if (_contractorsByServiceSearch.isEmpty) return _contractorsbyService;
    final query = _contractorsByServiceSearch.toLowerCase();
    return _contractorsbyService
        .where((contractor) =>
            contractor.fullName.toLowerCase().contains(query) ||
            contractor.service.toLowerCase().contains(query))
        .toList();
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      notifyListeners();
    }
  }

  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  bool isValidBookingSelection() {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      int.parse(_selectedTime.split(':')[0]),
      0,
    );
    return selectedDateTime.isAfter(now);
  }

  void resetBookingData() {
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedTime = '09:00';
    notifyListeners();
  }
}

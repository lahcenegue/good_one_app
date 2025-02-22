import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Core/Utils/storage_keys.dart';
import '../Core/infrastructure/storage/storage_manager.dart';
import '../Features/User/models/contractor.dart';
import '../Features/User/models/service_category.dart';
import '../Features/User/models/user_info.dart';
import '../Features/User/services/user_api.dart';
import '../Features/auth/Services/token_manager.dart';

/// Manages user-related state and business logic for the application.
///
/// This class handles authentication, contractor data, booking schedules,
/// and location services, notifying listeners when state changes.
class UserManagerProvider extends ChangeNotifier {
  // Authentication State
  String? _token;
  UserInfo? _userInfo;
  String? _error;

  // UI State
  int _currentIndex = 0;
  bool _isLoading = false;

  // Search State
  String _searchQuery = '';
  String _contractorsByServiceSearch = '';

  // Contractor Data
  Contractor? _selectedContractor;
  final List<ServiceCategory> _categories = [];
  final List<Contractor> _bestContractors = [];
  final List<Contractor> _contractorsByService = [];

  // Location State
  final MapController _mapController = MapController();
  final TextEditingController _locationSearchController =
      TextEditingController();
  LatLng? _selectedLocation;
  String _locationAddress = '';
  bool _isLocationScreenLoading = false;
  bool _isLocationSelected = false;

  // Booking State
  DateTime _selectedDay;
  DateTime _focusedDay;
  String _selectedTime;
  int _taskDurationHours = 1;
  DateTime? _taskEndTime;
  final List<int> _availableDurations = [1, 2, 3, 4, 5, 6, 7, 8];
  static const List<String> _timeSlots = [
    '00:00',
    '01:00',
    '02:00',
    '03:00',
    '04:00',
    '05:00',
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
    '22:00',
    '23:00',
  ];

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

  MapController get mapController => _mapController;
  TextEditingController get locationSearchController =>
      _locationSearchController;
  LatLng? get selectedLocation => _selectedLocation;
  String get locationAddress => _locationAddress;
  bool get isLocationScreenLoading => _isLocationScreenLoading;
  bool get isLocationSelected => _isLocationSelected;
  bool get hasSelectedLocation => _selectedLocation != null;

  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  String get selectedTime => _selectedTime;
  int get taskDurationHours => _taskDurationHours;
  List<int> get availableDurations => List.unmodifiable(_availableDurations);
  DateTime? get taskEndTime => _taskEndTime;
  List<String> get timeSlots => _timeSlots;
  String get formattedDateTime => _formatBookingDateTime();

  int get bookingTimestamp => _getTimestamp(_selectedDay, _selectedTime);
  int get bookingEndTimestamp =>
      _getTimestamp(_selectedDay, _selectedTime, _taskDurationHours);

  // Constructor
  UserManagerProvider()
      : _selectedDay = DateTime.now(),
        _focusedDay = DateTime.now(),
        _selectedTime = _computeNextAvailableTime() {
    _initialize();
  }

  // Initialization
  Future<void> _initialize() async {
    await _loadUserData();
    _syncLocationController();
  }

  Future<void> _loadUserData() async {
    try {
      _token = StorageManager.getString(StorageKeys.tokenKey);
      if (_token != null) {
        final userInfoSuccess = await fetchUserInfo();
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
      _setError('Failed to load user data: $e');
    }
  }

  void _syncLocationController() {
    if (hasSelectedLocation && _locationAddress.isNotEmpty) {
      _locationSearchController.text = _locationAddress;
    }
  }

  // State Management
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> initialize() async {
    _setError(null);
    _setLoading(true);
    try {
      if (_token != null) {
        await Future.wait([_fetchPublicData(), fetchUserInfo()]);
      } else {
        await _fetchPublicData();
      }
    } catch (e) {
      _setError('Initialization failed: $e');
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

  void _setError(String? message) {
    _error = message;
    if (message != null) debugPrint(message);
    notifyListeners();
  }

  // User Info
  Future<bool> fetchUserInfo() async {
    if (_token == null) return false;
    _setLoading(true);
    try {
      final response = await UserApi.getUserInfo(token: _token!);
      if (response.success && response.data != null) {
        _userInfo = response.data;
        debugPrint('User info fetched: ${_userInfo?.fullName}');
        notifyListeners();
        return true;
      }
      _setError('Failed to fetch user info: ${response.error}');
      return false;
    } catch (e) {
      _setError('Exception fetching user info: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Categories and Contractors
  Future<void> _fetchPublicData() async {
    await Future.wait([fetchCategories(), fetchBestContractors()]);
  }

  Future<void> fetchCategories() async {
    _setLoading(true);
    try {
      final response = await UserApi.getCategories();
      if (response.success && response.data != null) {
        _categories
          ..clear()
          ..addAll(response.data!);
        debugPrint('Categories fetched: ${_categories.length}');
        notifyListeners();
      } else {
        _setError('Failed to fetch categories: ${response.error}');
      }
    } catch (e) {
      _setError('Exception fetching categories: $e');
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
        debugPrint('Best contractors fetched: ${_bestContractors.length}');
        notifyListeners();
      } else {
        _setError('Failed to fetch contractors: ${response.error}');
      }
    } catch (e) {
      _setError('Exception fetching contractors: $e');
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
        _setError('Failed to fetch contractors by service: ${response.error}');
      }
    } catch (e) {
      _setError('Exception fetching contractors by service: $e');
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

  // Booking Logic
  static String _computeNextAvailableTime() {
    final now = DateTime.now();
    final nextHour = now.hour + 1 >= 24 ? 6 : now.hour + 1;
    return '${nextHour.toString().padLeft(2, '0')}:00';
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _updateEndTime();
      notifyListeners();
    }
  }

  void setTaskDuration(int hours) {
    if (_availableDurations.contains(hours)) {
      _taskDurationHours = hours;
      _updateEndTime();
      notifyListeners();
    }
  }

  void selectTime(String time) {
    if (_timeSlots.contains(time)) {
      _selectedTime = time;
      _updateEndTime();
      notifyListeners();
    }
  }

  bool isValidBookingSelection({bool debug = false}) {
    final now = DateTime.now();
    final startDateTime = _buildDateTime(_selectedDay, _selectedTime);
    final endDateTime = calculateEndTime();

    if (debug) {
      debugPrint('Now: $now');
      debugPrint('Start: $startDateTime');
      debugPrint('End: $endDateTime');
    }

    if (!startDateTime.isAfter(now)) {
      if (debug) debugPrint('Invalid: Start time is not in the future');
      return false;
    }
    if (endDateTime.day != startDateTime.day) {
      if (debug) debugPrint('Invalid: End time spans to next day');
      return false;
    }
    if (endDateTime.hour > 22 || endDateTime.hour < 6) {
      if (debug) debugPrint('Invalid: End time outside 6:00-22:00');
      return false;
    }
    if (debug) debugPrint('Booking selection is valid');
    return true;
  }

  List<String> getAvailableTimeSlots() {
    final now = DateTime.now();
    return _timeSlots.where((slot) {
      final hour = int.parse(slot.split(':')[0]);
      final endHour = hour + _taskDurationHours;
      final startDateTime = _buildDateTime(_selectedDay, slot);
      return endHour <= 22 && startDateTime.isAfter(now);
    }).toList();
  }

  bool isTimeSlotAvailable(String timeSlot) {
    final hour = int.parse(timeSlot.split(':')[0]);
    final endHour = hour + _taskDurationHours;
    return endHour <= 22;
  }

  void resetBookingData() {
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedTime = _computeNextAvailableTime();
    _taskDurationHours = 1;
    _taskEndTime = null;
    notifyListeners();
  }

  DateTime calculateEndTime() {
    final startHour = int.parse(_selectedTime.split(':')[0]);
    return DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      startHour + _taskDurationHours,
      0,
    );
  }

  // Location Logic
  Future<void> getCurrentLocation(BuildContext context) async {
    _setLocationLoading(true);
    try {
      if (!await _ensureLocationServiceEnabled(context)) return;
      if (!await _ensureLocationPermissionGranted(context)) return;

      final position = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(newLocation, 16.0);
      await _reverseGeocode(newLocation);
    } catch (e) {
      _showSnackBar(context, 'Error getting location: $e');
    } finally {
      _setLocationLoading(false);
    }
  }

  Future<void> searchLocation(BuildContext context) async {
    if (_locationSearchController.text.isEmpty) return;
    _setLocationLoading(true);
    try {
      final locations =
          await locationFromAddress(_locationSearchController.text);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLocation = LatLng(location.latitude, location.longitude);
        _mapController.move(newLocation, 13.0);
      } else {
        _showSnackBar(context, 'Location not found');
      }
    } catch (e) {
      _showSnackBar(context, 'Error searching location: $e');
    } finally {
      _setLocationLoading(false);
    }
  }

  Future<void> confirmMapLocation() async {
    final mapCenter = _mapController.camera.center;
    _isLocationSelected = true;
    await _reverseGeocode(mapCenter);
    setLocation(mapCenter, _locationAddress);
  }

  // Public Location Methods
  void setLocation(LatLng location, String address) {
    _selectedLocation = location;
    _locationAddress = address;
    _isLocationSelected = true;
    notifyListeners();
  }

  void clearLocationSelection() {
    _isLocationSelected = false;
    notifyListeners();
  }

  // Private Helpers
  Future<bool> _ensureLocationServiceEnabled(BuildContext context) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _showSnackBar(context, 'Location services are disabled');
    }
    return enabled;
  }

  Future<bool> _ensureLocationPermissionGranted(BuildContext context) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar(context, 'Location permissions denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(context, 'Location permissions permanently denied');
      return false;
    }
    return true;
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _locationAddress = [
          place.locality,
          place.administrativeArea,
          place.country
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        _locationSearchController.text = _locationAddress;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
    }
  }

  void _setLocationLoading(bool loading) {
    _isLocationScreenLoading = loading;
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _updateEndTime() {
    _taskEndTime = calculateEndTime();
  }

  DateTime _buildDateTime(DateTime day, String time) {
    final hour = int.parse(time.split(':')[0]);
    return DateTime(day.year, day.month, day.day, hour, 0);
  }

  String _formatBookingDateTime() {
    final formatter = DateFormat('MMM dd, yyyy');
    final endTime = calculateEndTime();
    return '${formatter.format(_selectedDay)} from $_selectedTime to ${DateFormat('HH:mm').format(endTime)} ($_taskDurationHours ${_taskDurationHours == 1 ? 'hour' : 'hours'})';
  }

  int _getTimestamp(DateTime day, String time, [int duration = 0]) {
    final hour = int.parse(time.split(':')[0]) + duration;
    return DateTime(day.year, day.month, day.day, hour, 0)
            .millisecondsSinceEpoch ~/
        1000;
  }
}

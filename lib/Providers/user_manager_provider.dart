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

class UserManagerProvider extends ChangeNotifier {
  String? _token;
  UserInfo? _userInfo;
  String _searchQuery = '';
  String _contractorsByServiceSearch = '';
  String? _error;
  int _currentIndex = 0;
  bool _isLoading = false;

  //------ LOCATION SCREEN VARIABLES ------//
  // Map controller
  final MapController _mapController = MapController();
  final TextEditingController _locationSearchController =
      TextEditingController();
  bool _locationScreenIsLoading = false;
  bool _locationSelected = false;

  // Location data
  LatLng? _selectedLocation;
  String _locationAddress = '';
  bool _hasSelectedLocation = false;

  //------ DATE AND TIME SELECTION PROPERTIES ------//
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedTime = '09:00';

  // Cached time slots
  final List<String> _cachedTimeSlots = List.generate(
    24,
    (index) => '${index.toString().padLeft(2, '0')}:00',
  );

  //------ CATEGORIES AND CONTRACTORS LISTS ------//
  List<ServiceCategory> _categories = [];
  List<Contractor> _bestContractors = [];
  List<Contractor> _contractorsbyService = [];

  //------ GENERAL GETTERS ------//
  String? get token => _token;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  UserInfo? get userInfo => _userInfo;
  bool get isAuthenticated => _token != null && _userInfo != null;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;

  //------ LOCATION SCREEN GETTERS ------//
  MapController get mapController => _mapController;
  TextEditingController get locationSearchController =>
      _locationSearchController;
  bool get locationScreenIsLoading => _locationScreenIsLoading;
  bool get locationSelected => _locationSelected;
  LatLng? get selectedLocation => _selectedLocation;
  String get locationAddress => _locationAddress;
  bool get hasSelectedLocation => _hasSelectedLocation;

  //------ DATE AND TIME GETTERS ------//
  String get selectedTime => _selectedTime;
  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  List<String> get timeSlots => _cachedTimeSlots;

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

  //------ CONTRACTOR AND CATEGORY GETTERS ------//
  List<ServiceCategory> get categories => _categories;
  List<Contractor> get bestContractors => _bestContractors;
  List<Contractor> get contractorsbyService => _contractorsbyService;

  //------ CONSTRUCTOR ------//
  UserManagerProvider() {
    _initializeProvider();
  }

  //------ GENERAL METHODS ------//
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> _initializeProvider() async {
    await _loadUserData();
    _initializeLocationController();
  }

  void _initializeLocationController() {
    if (hasSelectedLocation && locationAddress.isNotEmpty) {
      _locationSearchController.text = locationAddress;
    }
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

  Future<void> clearAuthData() async {
    _token = null;
    _userInfo = null;
    await StorageManager.remove(StorageKeys.tokenKey);
    await StorageManager.remove(StorageKeys.accountTypeKey);
    await TokenManager.instance.clearToken();
    setCurrentIndex(0);
    notifyListeners();
  }

  //------ USER INFO METHODS ------//
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

  //------ CATEGORY METHODS ------//
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

  //------ CONTRACTOR METHODS ------//
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
    return contractor.fullName!.toLowerCase().contains(query) ||
        contractor.service!.toLowerCase().contains(query);
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
            contractor.fullName!.toLowerCase().contains(query) ||
            contractor.service!.toLowerCase().contains(query))
        .toList();
  }

  //------ DATE AND TIME SELECTION METHODS ------//
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

  //------ LOCATION SCREEN METHODS ------//
  // Set location selection state
  void setLocationSelectedState(bool selected) {
    _locationSelected = selected;
    notifyListeners();
  }

  // Set location loading state
  void setLocationScreenLoading(bool loading) {
    _locationScreenIsLoading = loading;
    notifyListeners();
  }

  // Set location
  void setLocation(LatLng location, String address) {
    _selectedLocation = location;
    _locationAddress = address;
    _hasSelectedLocation = true;
    notifyListeners();
  }

  void clearLocation() {
    _selectedLocation = null;
    _locationAddress = '';
    _hasSelectedLocation = false;
    notifyListeners();
  }

  // For formatted display of location
  String get formattedLocation {
    if (!_hasSelectedLocation || _selectedLocation == null) {
      return 'No location selected';
    }

    if (_locationAddress.isNotEmpty) {
      return _locationAddress;
    }

    return '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}';
  }

  // Get current location from GPS
  Future<void> getCurrentLocation(BuildContext context) async {
    setLocationScreenLoading(true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location services are disabled')));
        setLocationScreenLoading(false);
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Location permissions are denied')));
          setLocationScreenLoading(false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
        setLocationScreenLoading(false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition();
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      // Update map and state
      _mapController.move(newLocation, 16.0);
      setLocationScreenLoading(false);

      // Try to get address for the coordinates
      reverseGeocode(newLocation);
    } catch (e) {
      setLocationScreenLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')));
    }
  }

  // Search location method
  Future<void> searchLocation(BuildContext context) async {
    if (_locationSearchController.text.isEmpty) return;

    setLocationScreenLoading(true);

    try {
      List<Location> locations =
          await locationFromAddress(_locationSearchController.text);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newLocation = LatLng(location.latitude, location.longitude);

        // Update map and state
        _mapController.move(
            newLocation, 13.0); // Zoom out a bit to show the area
        setLocationScreenLoading(false);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Location not found')));
        setLocationScreenLoading(false);
      }
    } catch (e) {
      setLocationScreenLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching location: ${e.toString()}')));
    }
  }

  // Reverse geocode method
  Future<void> reverseGeocode(LatLng point) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '';

        if (place.locality != null && place.locality!.isNotEmpty) {
          address += place.locality!;
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        if (address.isNotEmpty) {
          _locationSearchController.text = address;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error in reverse geocoding: ${e.toString()}');
    }
  }

  // Confirm current map location
  void confirmMapLocation() {
    LatLng mapCenter = _mapController.camera.center;
    setLocationSelectedState(true);
    reverseGeocode(mapCenter);
  }
}

// class UserManagerProvider extends ChangeNotifier {
//   String? _token;
//   UserInfo? _userInfo;
//   String _searchQuery = '';
//   String _contractorsByServiceSearch = '';
//   String? _error;
//   int _currentIndex = 0;
//   bool _isLoading = false;

//   //------ LOCATION SCREEN VARIABLES ------//
//   // Map controller
//   final MapController _mapController = MapController();
//   TextEditingController _locationSearchController = TextEditingController();
//   bool _locationScreenIsLoading = false;
//   bool _locationSelected = false;

//   // Location data
//   LatLng? _selectedLocation;
//   String _locationAddress = '';
//   bool _hasSelectedLocation = false;

//   //------ DATE AND TIME SELECTION PROPERTIES ------//
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now();
//   String _selectedTime = '09:00';

//   // Cached time slots
//   final List<String> _cachedTimeSlots = List.generate(
//     24,
//     (index) => '${index.toString().padLeft(2, '0')}:00',
//   );

//   //------ CATEGORIES AND CONTRACTORS LISTS ------//
//   List<ServiceCategory> _categories = [];
//   List<Contractor> _bestContractors = [];
//   List<Contractor> _contractorsbyService = [];

//   //------ GENERAL GETTERS ------//
//   String? get token => _token;
//   String? get error => _error;
//   String get searchQuery => _searchQuery;
//   UserInfo? get userInfo => _userInfo;
//   bool get isAuthenticated => _token != null && _userInfo != null;
//   bool get isLoading => _isLoading;
//   int get currentIndex => _currentIndex;

//   //------ LOCATION SCREEN GETTERS ------//
//   MapController get mapController => _mapController;
//   TextEditingController get locationSearchController =>
//       _locationSearchController;
//   bool get locationScreenIsLoading => _locationScreenIsLoading;
//   bool get locationSelected => _locationSelected;
//   LatLng? get selectedLocation => _selectedLocation;
//   String get locationAddress => _locationAddress;
//   bool get hasSelectedLocation => _hasSelectedLocation;

//   //------ DATE AND TIME GETTERS ------//
//   String get selectedTime => _selectedTime;
//   DateTime get selectedDay => _selectedDay;
//   DateTime get focusedDay => _focusedDay;
//   List<String> get timeSlots => _cachedTimeSlots;

//   String get formattedDateTime {
//     final formatter = DateFormat('MMM dd, yyyy');
//     return '${formatter.format(_selectedDay)} at $_selectedTime';
//   }

//   int get bookingTimestamp {
//     final dateTime = DateTime(
//       _selectedDay.year,
//       _selectedDay.month,
//       _selectedDay.day,
//       int.parse(_selectedTime.split(':')[0]),
//       0,
//     );
//     return dateTime.millisecondsSinceEpoch ~/ 1000;
//   }

//   //------ CONTRACTOR AND CATEGORY GETTERS ------//
//   List<ServiceCategory> get categories => _categories;
//   List<Contractor> get bestContractors => _bestContractors;
//   List<Contractor> get contractorsbyService => _contractorsbyService;

//   //------ CONSTRUCTOR ------//
//   UserManagerProvider() {
//     _initializeProvider();
//   }

//   // Navigation
//   void setCurrentIndex(int index) {
//     _currentIndex = index;
//     notifyListeners();
//   }

//   // Location setters
//   void setLocation(LatLng location, String address) {
//     _selectedLocation = location;
//     _locationAddress = address;
//     _hasSelectedLocation = true;
//     notifyListeners();
//   }

//   Future<void> _initializeProvider() async {
//     await _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       _token = StorageManager.getString(StorageKeys.tokenKey);
//       debugPrint('Loaded token: $_token');

//       if (_token != null) {
//         // Try to get user info with current token
//         final userInfoSuccess = await fetchUserInfo();

//         // If user info fails, try token refresh
//         if (!userInfoSuccess && _token != null) {
//           final refreshed = await TokenManager.instance.refreshToken();
//           if (refreshed) {
//             // Update token and try user info again
//             _token = TokenManager.instance.token;
//             await fetchUserInfo();
//           } else {
//             // If refresh fails, clear authentication
//             await clearAuthData();
//           }
//         }
//       }

//       // Always fetch public data
//       await _fetchPublicData();
//     } catch (e) {
//       _setError('Error loading user data: $e');
//     }
//   }

//   // Initialize data
//   Future<void> initialize() async {
//     try {
//       _setError(null);
//       if (_token != null) {
//         await Future.wait([
//           _fetchPublicData(),
//           fetchUserInfo(),
//         ]);
//       } else {
//         await _fetchPublicData();
//       }
//     } catch (e) {
//       _setError('Initialization error: $e');
//     }
//   }

//   // Fetch public data method
//   Future<void> _fetchPublicData() {
//     return Future.wait([
//       fetchCategories(),
//       fetchBestContractors(),
//     ]);
//   }

//   // Update token
//   Future<void> updateToken(String newToken) async {
//     _token = newToken;
//     await StorageManager.setString(StorageKeys.tokenKey, newToken);
//     await _loadUserData();
//   }

//   // Clear data on logout
//   Future<void> clearData() async {
//     await clearAuthData();
//     // Reinitialize public data
//     await _fetchPublicData();
//   }

//   // Fetch user info
//   Future<bool> fetchUserInfo() async {
//     if (_token == null) return false;

//     try {
//       _setLoading(true);
//       final response = await UserApi.getUserInfo(token: _token);

//       if (response.success && response.data != null) {
//         _userInfo = response.data;
//         debugPrint('User info fetched successfully: ${_userInfo?.fullName}');
//         notifyListeners();
//         return true;
//       } else {
//         _setError('Error fetching user info: ${response.error}');
//         return false;
//       }
//     } catch (e) {
//       _setError('Exception fetching user info: $e');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> clearAuthData() async {
//     _token = null;
//     _userInfo = null;
//     await StorageManager.remove(StorageKeys.tokenKey);
//     await StorageManager.remove(StorageKeys.accountTypeKey);
//     await TokenManager.instance.clearToken();
//     setCurrentIndex(0);
//     notifyListeners();
//   }

//   // Fetch categories
//   Future<void> fetchCategories() async {
//     try {
//       _setLoading(true);
//       final response = await UserApi.getCategories();

//       if (response.success && response.data != null) {
//         _categories = response.data!;
//         debugPrint('Categories fetched: ${_categories.length}');
//         notifyListeners();
//       } else {
//         _setError('Error fetching categories: ${response.error}');
//       }
//     } catch (e) {
//       _setError('Exception fetching categories: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Fetch best contractors
//   Future<void> fetchBestContractors() async {
//     try {
//       _setLoading(true);
//       final response = await UserApi.getBestContractors();

//       if (response.success && response.data != null) {
//         _bestContractors = response.data!;
//         debugPrint('Contractors fetched: ${_bestContractors.length}');
//         notifyListeners();
//       } else {
//         _setError('Error fetching contractors: ${response.error}');
//       }
//     } catch (e) {
//       _setError('Exception fetching contractors: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   void _setError(String? errorMessage) {
//     _error = errorMessage;
//     if (errorMessage != null) {
//       debugPrint(errorMessage);
//     }
//     notifyListeners();
//   }

//   // Search functionality
//   void updateSearchQuery(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }

//   // Best contractors
//   List<Contractor> get getBestContractors {
//     if (_searchQuery.isEmpty) return _bestContractors;
//     return _bestContractors.where(_matchesSearchQuery).toList();
//   }

//   bool _matchesSearchQuery(Contractor contractor) {
//     final query = _searchQuery.toLowerCase();
//     return contractor.fullName!.toLowerCase().contains(query) ||
//         contractor.service!.toLowerCase().contains(query);
//   }

//   // Fetch contractors by service
//   Future<void> fetchContractorsByService(int? id) async {
//     try {
//       _setLoading(true);
//       final response = await UserApi.getContractorsByService(id: id);

//       if (response.success && response.data != null) {
//         _contractorsbyService = response.data!;
//         debugPrint('Contractors fetched: ${_contractorsbyService.length}');
//         notifyListeners();
//       } else {
//         _setError('Error fetching contractors by service: ${response.error}');
//       }
//     } catch (e) {
//       _setError('Exception fetching contractors by service: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   void updateContractorsByServiceSearch(String query) {
//     _contractorsByServiceSearch = query;
//     notifyListeners();
//   }

//   void clearContractorsByServiceSearch() {
//     _contractorsByServiceSearch = '';
//     notifyListeners();
//   }

//   List<Contractor> get getContractorsByService {
//     if (_contractorsByServiceSearch.isEmpty) return _contractorsbyService;
//     final query = _contractorsByServiceSearch.toLowerCase();
//     return _contractorsbyService
//         .where((contractor) =>
//             contractor.fullName!.toLowerCase().contains(query) ||
//             contractor.service!.toLowerCase().contains(query))
//         .toList();
//   }

//   void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       _selectedDay = selectedDay;
//       _focusedDay = focusedDay;
//       notifyListeners();
//     }
//   }

//   void selectTime(String time) {
//     _selectedTime = time;
//     notifyListeners();
//   }

//   bool isValidBookingSelection() {
//     final now = DateTime.now();
//     final selectedDateTime = DateTime(
//       _selectedDay.year,
//       _selectedDay.month,
//       _selectedDay.day,
//       int.parse(_selectedTime.split(':')[0]),
//       0,
//     );
//     return selectedDateTime.isAfter(now);
//   }

//   void clearLocation() {
//     _selectedLocation = null;
//     _locationAddress = '';
//     _hasSelectedLocation = false;
//     notifyListeners();
//   }

//   // For formatted display of location
//   String get formattedLocation {
//     if (!_hasSelectedLocation || _selectedLocation == null) {
//       return 'No location selected';
//     }

//     if (_locationAddress.isNotEmpty) {
//       return _locationAddress;
//     }

//     return '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}';
//   }

//   void resetBookingData() {
//     _selectedDay = DateTime.now();
//     _focusedDay = DateTime.now();
//     _selectedTime = '09:00';
//     notifyListeners();
//   }
// }

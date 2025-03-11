import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/presentation/resources/app_strings.dart';
import '../Core/Utils/storage_keys.dart';
import '../Core/infrastructure/storage/storage_manager.dart';
import '../Features/User/models/booking.dart';
import '../Features/User/models/order_model.dart';
import '../Features/User/services/user_api.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Manages all booking-related state and operations, including location selection.
class BookingManagerProvider with ChangeNotifier {
  // Core State
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  // Booking Form State
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedTime = _computeNextAvailableTime();
  int _taskDurationHours = 1;
  DateTime? _taskEndTime;

  // Location State
  final MapController _mapController = MapController();
  final TextEditingController _locationSearchController =
      TextEditingController();
  LatLng? _selectedLocation;
  String _locationAddress = '';
  bool _isLocationScreenLoading = false;
  bool _isLocationSelected = false;

  // Payment and Coupon State
  String? _appliedCoupon;
  double? _discountPercentage;
  bool _isPaymentProcessing = false;

  // BookingScreen-Specific State
  String? _token;
  bool _isInitializing = true;
  TabController? _tabController;

  // Getters
  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  String get selectedTime => _selectedTime;
  int get taskDurationHours => _taskDurationHours;
  MapController get mapController => _mapController;
  TextEditingController get locationSearchController =>
      _locationSearchController;
  LatLng? get selectedLocation => _selectedLocation;
  String get locationAddress => _locationAddress;
  bool get isLocationScreenLoading => _isLocationScreenLoading;
  bool get isLocationSelected => _isLocationSelected;
  String get formattedDateTime => _formatBookingDateTime();
  List<String> get availableTimeSlots => AppStrings.timeSlots;
  List<int> get availableDurations => AppStrings.availableDurations;
  String? get appliedCoupon => _appliedCoupon;
  double? get discountPercentage => _discountPercentage;
  bool get isPaymentProcessing => _isPaymentProcessing;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _token != null;
  TabController? get tabController => _tabController;

  /// Calculates the effective total price based on contractor cost and discount.
  double effectiveTotalPrice(double contractorCost) {
    return (1 - (_discountPercentage ?? 0.0)) *
        _taskDurationHours *
        contractorCost;
  }

  BookingManagerProvider() {
    _initialize();
  }

  /// Initializes provider state.
  Future<void> _initialize() async {
    print('Starting initialization');
    _isLoading = true;
    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);

      notifyListeners();
      print('Token fetched: $_token');
      if (_token != null) {
        print('Calling fetchBookings from initialize');

        await fetchBookings();
      } else {
        print('No token, skipping fetchBookings');
      }
    } catch (e) {
      print('Initialization error: $e');
      _error = 'Initialization failed: $e';
    } finally {
      print('Finalizing initialization');
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets up the tab controller for BookingScreen.
  void setupTabController(TickerProvider vsync) {
    _tabController = TabController(length: 3, vsync: vsync, initialIndex: 0);
    notifyListeners();
  }

  /// Fetches user's bookings with error handling.
  Future<void> fetchBookings() async {
    _isLoading = true;
    _error = null;
    _bookings = []; // Clear existing bookings to avoid stale data
    notifyListeners();
    try {
      final response = await UserApi.getBookings();
      print('FetchBookings Response: ${response.data}');
      if (response.success && response.data != null) {
        _bookings = response.data!;
        print(
            'Bookings updated: ${_bookings.map((b) => "id: ${b.id}, status: ${b.status}").toList()}');
      } else {
        _error =
            'Failed to fetch bookings: ${response.error ?? "Unknown error"}';
      }
    } catch (e) {
      print('FetchBookings error: $e');
      _error = 'Error fetching bookings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new order with payment processing, requiring a location.
  Future<bool> createOrder(
    BuildContext context,
    int serviceId,
    double contractorCost,
  ) async {
    print(
        'Starting order creation with serviceId: $serviceId, cost: $contractorCost');
    _setPaymentProcessing(true);
    try {
      final amount =
          (effectiveTotalPrice(contractorCost) * 100).toInt().toString();
      print('Calculated amount for payment: $amount cents');
      final paymentResponse =
          await UserApi.createPaymentIntent(amount: amount, currency: 'CAD');
      print('Payment Intent Response: ${paymentResponse.data}');

      if (!paymentResponse.success || paymentResponse.data == null) {
        throw Exception(
            paymentResponse.error ?? 'Payment intent creation failed');
      }

      await _initializePayment(paymentResponse.data!['client_secret']);
      await _presentPaymentSheet();

      final orderRequest = OrderRequest(
        serviceId: serviceId,
        location: _locationAddress,
        startAt: getTimestamp(_selectedDay, _selectedTime),
        totalHours: _taskDurationHours,
        coupon: _appliedCoupon,
      );
      print('Order request: ${orderRequest.toJson()}');

      final response = await UserApi.createOrder(orderRequest);
      print('Order creation response: ${response.data}');
      if (response.success) {
        resetBookingData();
        _showSnackBar(context, 'Order created successfully');
        return true;
      }
      throw Exception(response.error ?? 'Order creation failed');
    } on StripeException catch (e) {
      print('Stripe exception: $e');
      _setError('Payment failed: ${e.error}');
      _showSnackBar(context, 'Payment failed: ${e.error}');
      return false;
    } catch (e) {
      print('General exception: $e');
      _setError('Order creation failed: $e');
      _showSnackBar(context, 'Failed to create order: $e');
      return false;
    } finally {
      _setPaymentProcessing(false);
      print('Order creation process completed');
    }
  }

  /// Applies a coupon code.
  Future<void> applyCoupon(String couponCode, BuildContext context) async {
    if (couponCode.isEmpty) {
      _setError('Coupon code is required');
      return;
    }
    _setLoading(true);
    try {
      final response = await UserApi.checkCoupon(coupon: couponCode);

      if (response.success && response.data != null) {
        _appliedCoupon = couponCode;
        _discountPercentage = response.data!.percentage.toDouble() / 100;

        _setError(null);
      } else {
        _appliedCoupon = null;
        _discountPercentage = null;
        if (context.mounted) {
          _setError(
              response.error ?? AppLocalizations.of(context)!.invalidCoupon);
        }
      }
    } catch (e) {
      _appliedCoupon = null;
      _discountPercentage = null;
      _setError('Error applying coupon: $e');
      _showSnackBar(context, AppLocalizations.of(context)!.invalidCoupon);
    } finally {
      _setLoading(false);
    }
  }

  /// Marks an order as received.
  Future<void> receiveOrder(BuildContext context, int orderId) async {
    _setLoading(true);
    try {
      final orderRequest = OrderEditRequest(orderId: orderId);
      final response =
          await UserApi.receiveOrder(orderRequest); // 2 = completed
      if (response.success) {
        await fetchBookings();
        _showSnackBar(context, 'Order marked as received');
      } else {
        throw Exception(response.error ?? 'Failed to receive order');
      }
    } catch (e) {
      _setError('Error receiving order: $e');
      _showSnackBar(context, 'Failed to receive order: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cancels an order with a reason.
  Future<void> cancelOrder(
      BuildContext context, int orderId, String reason) async {
    if (reason.isEmpty) {
      _setError('Cancellation reason is required');
      return;
    }
    _setLoading(true);
    try {
      final orderRequest = OrderEditRequest(orderId: orderId, note: reason);
      final response = await UserApi.cancelOrder(orderRequest);
      if (response.success) {
        await fetchBookings();
        _showSnackBar(context, 'Order canceled successfully');
      } else {
        throw Exception(response.error ?? 'Failed to cancel order');
      }
    } catch (e) {
      _setError('Error canceling order: $e');
      _showSnackBar(context, 'Failed to cancel order: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Modifies an order, handling additional payment if required.
  Future<bool> modifyOrder(
      BuildContext context, int orderId, OrderEditRequest request) async {
    _setLoading(true);
    try {
      final response = await UserApi.updateOrder(request);
      if (response.success) {
        await fetchBookings();
        _showSnackBar(context, 'Order modified successfully');
        return true;
      }
      throw Exception(response.error ?? 'Failed to modify order');
    } catch (e) {
      _setError('Error modifying order: $e');
      _showSnackBar(context, 'Failed to modify order: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Modifies an order with additional payment.
  Future<bool> modifyOrderWithPayment(BuildContext context, int orderId,
      OrderEditRequest request, double additionalCost) async {
    _setPaymentProcessing(true);
    try {
      final amount = (additionalCost * 100).toInt().toString();
      final paymentResponse =
          await UserApi.createPaymentIntent(amount: amount, currency: 'CAD');
      if (!paymentResponse.success || paymentResponse.data == null) {
        throw Exception(
            paymentResponse.error ?? 'Payment intent creation failed');
      }

      await _initializePayment(paymentResponse.data!['client_secret']);
      await _presentPaymentSheet();

      return await modifyOrder(context, orderId, request);
    } catch (e) {
      _setError('Payment for modification failed: $e');
      _showSnackBar(context, 'Payment failed: $e');
      return false;
    } finally {
      _setPaymentProcessing(false);
    }
  }

  // Booking Form Methods
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    _updateEndTime();
    notifyListeners();
  }

  void selectTime(String time) {
    if (AppStrings.timeSlots.contains(time)) {
      _selectedTime = time;
      _updateEndTime();
      notifyListeners();
    }
  }

  void setTaskDuration(int hours) {
    if (AppStrings.availableDurations.contains(hours)) {
      _taskDurationHours = hours;
      _updateEndTime();
      notifyListeners();
    }
  }

  // Location Management Methods
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
      _setError('Error getting location: $e');
      _showSnackBar(context, 'Error getting location: $e');
    } finally {
      _setLocationLoading(false);
    }
  }

  Future<void> searchLocation(BuildContext context) async {
    if (_locationSearchController.text.isEmpty) {
      _setError('Please enter a location to search.');
      return;
    }
    _setLocationLoading(true);
    try {
      final locations =
          await locationFromAddress(_locationSearchController.text);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLocation = LatLng(location.latitude, location.longitude);
        _mapController.move(newLocation, 13.0);
        await _reverseGeocode(newLocation);
      } else {
        _setError('Location not found.');
        _showSnackBar(context, 'Location not found');
      }
    } catch (e) {
      _setError('Error searching location: $e');
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

  void setLocation(LatLng location, String address) {
    if (location.latitude < -90 ||
        location.latitude > 90 ||
        location.longitude < -180 ||
        location.longitude > 180) {
      _setError('Invalid location coordinates.');
      return;
    }
    if (address.isEmpty) {
      _setError('Location address cannot be empty.');
      return;
    }
    _selectedLocation = location;
    _locationAddress = address;
    _isLocationSelected = true;
    notifyListeners();
  }

  void clearLocationSelection() {
    _selectedLocation = null;
    _locationAddress = '';
    _isLocationSelected = false;
    _locationSearchController.clear();
    notifyListeners();
  }

  /// Checks if the selected time and duration are valid without requiring location.
  bool isValidTimeSelection() {
    final now = DateTime.now();
    final start = _buildDateTime(_selectedDay, _selectedTime);
    final end = start.add(Duration(hours: _taskDurationHours));
    final isTimeValid = start.isAfter(now) && end.hour <= 24 && end.hour >= 0;

    return isTimeValid;
  }

  bool isTimeSlotAvailable(String timeSlot) {
    final now = DateTime.now();
    final hour = int.parse(timeSlot.split(':')[0]);
    final slotDateTime =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day, hour);
    return slotDateTime.isAfter(now);
  }

  void resetBookingData() {
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _selectedTime = _computeNextAvailableTime();
    _taskDurationHours = 1;
    _taskEndTime = null;
    _locationAddress = '';
    _selectedLocation = null;
    _isLocationSelected = false;
    _appliedCoupon = null;
    _discountPercentage = null;
    notifyListeners();
  }

  // Private Helpers
  static String _computeNextAvailableTime() {
    final now = DateTime.now();
    final nextHour = now.hour + 1 >= 24 ? 6 : now.hour + 1;
    return '${nextHour.toString().padLeft(2, '0')}:00';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    debugPrint('BookingManager Error: $message');
    notifyListeners();
  }

  void _setPaymentProcessing(bool value) {
    _isPaymentProcessing = value;
    notifyListeners();
  }

  void _setLocationLoading(bool loading) {
    _isLocationScreenLoading = loading;
    notifyListeners();
  }

  void _updateEndTime() {
    _taskEndTime = _buildDateTime(_selectedDay, _selectedTime)
        .add(Duration(hours: _taskDurationHours));
  }

  DateTime _buildDateTime(DateTime day, String time) {
    final hour = int.parse(time.split(':')[0]);
    return DateTime(day.year, day.month, day.day, hour, 0);
  }

  String _formatBookingDateTime() {
    final formatter = DateFormat('MMM dd, yyyy');
    final endTime = _taskEndTime ?? _buildDateTime(_selectedDay, _selectedTime);
    return '${formatter.format(_selectedDay)} from $_selectedTime to ${DateFormat('HH:mm').format(endTime)}';
  }

  int getTimestamp(DateTime day, String time, [int additionalHours = 0]) {
    final baseTime = _buildDateTime(day, time);
    return baseTime
            .add(Duration(hours: additionalHours))
            .millisecondsSinceEpoch ~/
        1000;
  }

  Future<void> _initializePayment(String clientSecret) async {
    print('Initializing payment sheet with client secret: $clientSecret');
    print('Current publishable key: ${Stripe.publishableKey}');
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customerId: AppStrings.stripeAccountId,
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Good One App',
          style: ThemeMode.system,
        ),
      );
      print('Payment sheet initialized successfully');
    } catch (e) {
      print('Payment sheet initialization error: $e');
      throw Exception('Failed to initialize payment sheet: $e');
    }
  }

  Future<void> _presentPaymentSheet() async {
    print('Presenting payment sheet');
    try {
      await Stripe.instance.presentPaymentSheet();
      print('Payment sheet presented successfully');
    } catch (e) {
      print('Payment sheet presentation error: $e');
      if (e is PlatformException && e.code == 'canceled') {
        throw Exception('Payment canceled by user');
      }
      throw Exception('Failed to present payment sheet: $e');
    }
  }

  // void _syncLocationController() {
  //   if (_selectedLocation != null && _locationAddress.isNotEmpty) {
  //     _locationSearchController.text = _locationAddress;
  //   }
  // }

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
          place.street,
          place.locality,
          place.administrativeArea,
          place.country
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        _locationSearchController.text = _locationAddress;
        notifyListeners();
      } else {
        _setError('No address found for this location.');
      }
    } catch (e) {
      _setError('Reverse geocoding failed: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

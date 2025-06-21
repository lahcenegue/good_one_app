import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Features/Both/Models/tax_model.dart';
import 'package:good_one_app/Features/Both/Services/both_api.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Presentation/Widgets/success_dialog.dart';
import 'package:good_one_app/Features/User/Models/booking.dart';
import 'package:good_one_app/Features/User/Models/order_model.dart';
import 'package:good_one_app/Features/User/Models/rate_model.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/service_evaluation_screen.dart';
import 'package:good_one_app/Features/User/Services/user_api.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Manages all booking-related state and operations, including location selection.
class BookingManagerProvider with ChangeNotifier {
  // Core State
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;
  String? _couponError;

  // Booking Form State
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String _selectedTime = _computeNextAvailableTime();
  int _taskDurationHours = 1;
  DateTime? _taskEndTime;

  // Duration Selection State
  String _durationType = 'hours'; // 'hours', 'days', 'task'
  double _durationValue = 1.0;
  final TextEditingController _durationController =
      TextEditingController(text: '1');

  // Location State
  final MapController _mapController = MapController();
  final TextEditingController _locationSearchController =
      TextEditingController();
  LatLng? _selectedLocation;
  String _locationAddress = '';
  String? _region;
  bool _isLocationScreenLoading = false;
  bool _isLocationSelected = false;

  // Tax State
  TaxModel? _taxInfo;
  bool _isTaxLoading = false;
  String? _taxError;

  // Payment and Coupon State
  String? _appliedCoupon;
  double? _discountPercentage;
  bool _isPaymentProcessing = false;

  // BookingScreen-Specific State
  String? _token;
  bool _isInitializing = true;
  TabController? _tabController;

  //Rating State
  final TextEditingController commentController = TextEditingController();
  double _rating = 0;
  bool _isRatingSubmitting = false;
  String? _ratingError;

  // Getters
  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get couponError => _couponError;
  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;
  String get selectedTime => _selectedTime;
  int get taskDurationHours => _taskDurationHours;
  String get durationType => _durationType;
  double get durationValue => _durationValue;
  TextEditingController get durationController => _durationController;
  bool get hasValidDuration => _durationValue > 0;
  MapController get mapController => _mapController;
  TextEditingController get locationSearchController =>
      _locationSearchController;
  LatLng? get selectedLocation => _selectedLocation;
  String get locationAddress => _locationAddress;
  String? get region => _region;
  TaxModel? get taxInfo => _taxInfo;
  bool get isTaxLoading => _isTaxLoading;
  String? get taxError => _taxError;
  bool get isLocationScreenLoading => _isLocationScreenLoading;
  bool get isLocationSelected => _isLocationSelected;
  String get formattedDateTime => _formatBookingDateTime();
  List<String> get availableTimeSlots => AppConfig.timeSlots;
  List<int> get availableDurations => AppConfig.availableDurations;
  String? get appliedCoupon => _appliedCoupon;
  double? get discountPercentage => _discountPercentage;
  bool get isPaymentProcessing => _isPaymentProcessing;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _token != null;
  TabController? get tabController => _tabController;
  bool get isRatingSubmitting => _isRatingSubmitting;
  String? get ratingError => _ratingError;
  double get rating => _rating;

  /// Calculates the effective price after applying the discount.
  double effectivePrice(double contractorCost) {
    return (1 - (_discountPercentage ?? 0.0)) * basePrice(contractorCost);
  }

  /// Calculates the final price including taxes and fees.
  double finalPrice(double contractorCost) {
    if (_taxInfo == null) return effectivePrice(contractorCost);

    double price = effectivePrice(contractorCost);

    // Add region taxes (as a percentage of the effective price)
    final taxAmount = price * (_taxInfo!.regionTaxes / 100);
    price += taxAmount;

    // Add platform fees percentage (if not 0)
    if (_taxInfo!.platformFeesPercentage != 0) {
      final platformFeePercentage =
          price * (_taxInfo!.platformFeesPercentage / 100);
      price += platformFeePercentage;
    }

    // Add platform fees (if not 0)
    if (_taxInfo!.platformFees != 0) {
      price += _taxInfo!.platformFees;
    }

    return price;
  }

  BookingManagerProvider() {
    initialize();
  }

  /// Initializes provider state.
  Future<void> initialize() async {
    _isLoading = true;
    try {
      _token = await StorageManager.getString(StorageKeys.tokenKey);

      notifyListeners();

      if (_token != null) {
        await fetchBookings();
      } else {}
    } catch (e) {
      _error = 'Initialization failed: $e';
    } finally {
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets the duration type (hours, days, or task-based)
  void setDurationType(String type) {
    if (_durationType != type) {
      _durationType = type;

      // Reset values when changing type
      switch (type) {
        case 'hours':
          _durationValue = 1.0;
          _durationController.text = '1';
          break;
        case 'days':
          _durationValue = 1.0;
          _durationController.text = '1';
          break;
        case 'task':
          // For task-based, set to 1 hour (fixed)
          _durationValue = 1.0;
          _durationController.clear(); // No input needed
          break;
      }

      _updateTaskDurationFromType();
      notifyListeners();
    }
  }

  /// Sets the duration value and updates the controller
  void setDurationValue(double value) {
    _durationValue = value;
    _durationController.text =
        value == value.toInt() ? value.toInt().toString() : value.toString();
    _updateTaskDurationFromType();
    notifyListeners();
  }

  /// Updates duration from text input
  void updateDurationInput(String value) {
    final parsedValue = double.tryParse(value);
    if (parsedValue != null && parsedValue >= 0) {
      _durationValue = parsedValue;
      _updateTaskDurationFromType();
      notifyListeners();
    }
  }

  /// Updates the task duration hours based on the selected type and value
  void _updateTaskDurationFromType() {
    switch (_durationType) {
      case 'hours':
        _taskDurationHours = _durationValue.ceil();
        break;
      case 'days':
        _taskDurationHours = _durationValue.ceil();
        break;
      case 'task':
        // For task-based pricing, it's always 1 unit
        _taskDurationHours = 1;
        break;
    }
    _updateEndTime();
  }

  /// basePrice method to handle different pricing models
  double basePrice(double contractorCost) {
    switch (_durationType) {
      case 'hours':
        return _durationValue * contractorCost;
      case 'days':
        // For daily pricing, multiply days by daily rate (not converted to hours)
        return _durationValue * contractorCost;
      case 'task':
        // For task-based pricing, it's fixed at the service rate
        return contractorCost;
      default:
        return _durationValue * contractorCost;
    }
  }

  /// Fetches taxes based on the region.
  Future<void> fetchTaxes(String region) async {
    _isTaxLoading = true;
    _taxError = null;
    notifyListeners();
    try {
      final response = await BothApi.fetchTaxes(region);

      if (response.success && response.data != null) {
        _taxInfo = response.data;
      } else {
        _taxError =
            'Failed to fetch taxes: ${response.error ?? "Unknown error"}';
      }
    } catch (e) {
      _taxError = 'Error fetching taxes: $e';
    } finally {
      _isTaxLoading = false;
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

      if (response.success && response.data != null) {
        _bookings = response.data!;
        _error = null;
        notifyListeners();
      } else {
        _error =
            'Failed to fetch bookings: ${response.error ?? "Unknown error"}';
      }
    } catch (e) {
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
    _setPaymentProcessing(true);
    try {
      if (_region == null) {
        throw Exception('Region not determined. Please select a location.');
      }

      final amount = (finalPrice(contractorCost) * 100).toInt().toString();

      final paymentResponse =
          await UserApi.createPaymentIntent(amount: amount, currency: 'CAD');

      if (!paymentResponse.success || paymentResponse.data == null) {
        throw Exception(
            paymentResponse.error ?? 'Payment intent creation failed');
      }

      await _initializePayment(paymentResponse.data!['client_secret']);
      await _presentPaymentSheet();

      final orderRequest = OrderRequest(
        serviceId: serviceId,
        location: _locationAddress,
        region: _region!,
        startAt: getTimestamp(_selectedDay, _selectedTime),
        durationValue:
            _durationValue, // Send the actual duration value the user entered
        coupon: _appliedCoupon,
      );

      final response = await UserApi.createOrder(orderRequest);

      if (response.success) {
        resetBookingData();
        await fetchBookings();
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => SuccessDialog(
              title: AppLocalizations.of(context)!.orderSuccessTitle,
              description:
                  AppLocalizations.of(context)!.orderSuccessDescription,
              confirmText: AppLocalizations.of(context)!.confirm,
              onConfirm: () {
                Navigator.of(context).pop();

                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.userMain,
                  (Route<dynamic> route) => false,
                  arguments: 1,
                );
              },
            ),
          );
        }

        return true;
      }
      throw Exception(response.error ?? 'Order creation failed');
    } on StripeException catch (e) {
      _setError('Payment failed: ${e.error}');
      if (context.mounted) {
        _showSnackBar(context, 'Payment failed: ${e.error}');
      }
      return false;
    } catch (e) {
      _setError('Order creation failed: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to create order: $e');
      }
      return false;
    } finally {
      _setPaymentProcessing(false);
    }
  }

  /// Applies a coupon code.
  Future<void> applyCoupon(String couponCode, BuildContext context) async {
    if (couponCode.isEmpty) {
      _couponError = 'Coupon code is required';
      notifyListeners();
      return;
    }
    _setLoading(true);
    try {
      final response = await UserApi.checkCoupon(coupon: couponCode);

      if (response.success && response.data != null) {
        _appliedCoupon = couponCode;
        _discountPercentage = response.data!.percentage.toDouble() / 100;

        _couponError = null;
        notifyListeners();
      } else {
        _appliedCoupon = null;
        _discountPercentage = null;
        if (context.mounted) {
          _couponError =
              response.error ?? AppLocalizations.of(context)!.invalidCoupon;
        }
        notifyListeners();
      }
    } catch (e) {
      _appliedCoupon = null;
      _discountPercentage = null;
      _couponError = 'Error applying coupon';
      if (context.mounted) {
        _showSnackBar(context, AppLocalizations.of(context)!.invalidCoupon);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Marks an order as received.
  Future<bool> receiveOrder(
    BuildContext context,
    BuildContext dialogContext,
    int orderId,
  ) async {
    _setLoading(true);
    try {
      final orderRequest = OrderEditRequest(orderId: orderId);
      final response = await UserApi.receiveOrder(orderRequest);
      if (response.success) {
        await fetchBookings();
        if (dialogContext.mounted) {
          await Navigator.of(dialogContext).push(
            MaterialPageRoute(
              builder: (context) => ServiceEvaluationScreen(
                serviceId: getServiceIdFromBookingId(orderId),
              ),
            ),
          );
        }

        return true;
      } else {
        throw Exception(response.error ?? 'Failed to receive order');
      }
    } catch (e) {
      _setError('Error receiving order: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to receive order: $e');
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  int getServiceIdFromBookingId(int bookingId) {
    final booking = _bookings.firstWhere(
      (booking) => booking.id == bookingId,
      orElse: () => throw Exception(
          'Booking with ID $bookingId not found'), // Handle case where booking is not found
    );
    return booking.service.id; // Returns the nested service.id
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
        if (context.mounted) {
          _showSnackBar(context, 'Order canceled successfully');
        }
      } else {
        throw Exception(response.error ?? 'Failed to cancel order');
      }
    } catch (e) {
      _setError('Error canceling order: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to cancel order: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Modifies an order, handling additional payment if required.
  Future<bool> modifyOrder(
    BuildContext context,
    int orderId,
    OrderEditRequest request,
  ) async {
    _setLoading(true);
    try {
      final response = await UserApi.updateOrder(request);
      if (response.success) {
        await fetchBookings();
        if (context.mounted) {
          _showSnackBar(context, 'Order modified successfully');
        }
        return true;
      }
      throw Exception(response.error ?? 'Failed to modify order');
    } catch (e) {
      _setError('Error modifying order: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to modify order: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Modifies an order with additional payment.
  Future<bool> modifyOrderWithPayment(
    BuildContext context,
    int orderId,
    OrderEditRequest request,
    double additionalCost,
  ) async {
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
      if (context.mounted) {
        _showSnackBar(context, 'Payment failed: $e');
      }
      return false;
    } finally {
      _setPaymentProcessing(false);
    }
  }

  /// Get the appropriate service cost based on pricing type
  double getServiceCost(dynamic service) {
    final type = service!.pricingType ?? 'hourly';

    switch (type) {
      case 'hourly':
        return service.costPerHour?.toDouble() ?? 0.0;
      case 'daily':
        return service.costPerDay?.toDouble() ?? 0.0;
      case 'fixed':
        return service.fixedPrice?.toDouble() ?? 0.0;
      default:
        return service.costPerHour?.toDouble() ?? 0.0;
    }
  }

  //Rate Service
  Future<bool> rateService(
    BuildContext context,
    int serviceId,
    int rate,
  ) async {
    _isRatingSubmitting = true;
    _ratingError = null;
    notifyListeners();
    try {
      final request = RateServiceRequest(
        serviceId: serviceId,
        rate: rate,
        message: commentController.text.trim(),
      );

      final response = await UserApi.rateService(request);
      if (response.success && response.data != null) {
        await fetchBookings();
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) => SuccessDialog(
              title: AppLocalizations.of(context)!.feedbackSuccessTitle,
              description:
                  AppLocalizations.of(context)!.feedbackSuccessDescription,
              confirmText: AppLocalizations.of(context)!.back,
              onConfirm: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.userMain,
                  (Route<dynamic> route) => false,
                  arguments: 1,
                );
              },
            ),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          _ratingError =
              response.error ?? AppLocalizations.of(context)!.submissionFailed;
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        _ratingError = '${AppLocalizations.of(context)!.submissionFailed}: $e';
      }
      return false;
    } finally {
      _isRatingSubmitting = false;
      notifyListeners();
    }
  }

  // Setters for Rating and Comment
  void setRating(double value) {
    _rating = value;
    notifyListeners();
  }

  // Booking Form Methods
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    _updateEndTime();
    notifyListeners();
  }

  void selectTime(String time) {
    if (AppConfig.timeSlots.contains(time)) {
      _selectedTime = time;
      _updateEndTime();
      notifyListeners();
    }
  }

  void setTaskDuration(int hours) {
    if (AppConfig.availableDurations.contains(hours)) {
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
      if (context.mounted) {
        if (!await _ensureLocationPermissionGranted(context)) return;
      }

      final position = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(newLocation, 16.0);
      await _reverseGeocode(newLocation);
    } catch (e) {
      _setError('Error getting location: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Error getting location: $e');
      }
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
        if (context.mounted) {
          _showSnackBar(context, 'Location not found');
        }
      }
    } catch (e) {
      _setError('Error searching location: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Error searching location: $e');
      }
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
    _region = null;
    _taxInfo = null;

    _durationType = 'hours';
    _durationValue = 1.0;
    _durationController.text = '1';
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

    return '${formatter.format(_selectedDay)} , $_selectedTime';
  }

  int getTimestamp(DateTime day, String time, [int additionalHours = 0]) {
    final baseTime = _buildDateTime(day, time);
    return baseTime
            .add(Duration(hours: additionalHours))
            .millisecondsSinceEpoch ~/
        1000;
  }

  Future<void> _initializePayment(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customerId: AppConfig.stripeAccountId,
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Good One App',
          style: ThemeMode.system,
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize payment sheet: $e');
    }
  }

  Future<void> _presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      if (e is PlatformException && e.code == 'canceled') {
        throw Exception('Payment canceled by user');
      }
      throw Exception('Failed to present payment sheet: $e');
    }
  }

  Future<bool> _ensureLocationServiceEnabled(BuildContext context) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      if (context.mounted) {
        _showSnackBar(context, 'Location services are disabled');
      }
    }
    return enabled;
  }

  Future<bool> _ensureLocationPermissionGranted(BuildContext context) async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          _showSnackBar(context, 'Location permissions denied');
        }

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showSnackBar(context, 'Location permissions permanently denied');
      }

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
        final administrativeArea = place.administrativeArea ?? '';
        _region = administrativeArea;

        // Fetch taxes for the determined region
        if (_region != null && _region!.isNotEmpty) {
          await fetchTaxes(_region!);
        }

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

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}

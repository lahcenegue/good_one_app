import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Features/User/Models/order_model.dart';

import 'package:good_one_app/Features/Worker/Models/my_order_model.dart';
import 'package:good_one_app/Features/Worker/Services/worker_api.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrdersManagerProvider extends ChangeNotifier {
  String? _error;
  bool _isOrdersLoading = false;
  Map<String, List<MyOrderModel>> _orders = {};
  List<String> _dates = [];
  TabController? _tabController;

  LatLng? _customerLatLng;
  final MapController _mapController = MapController();

  // Getters
  bool get isOrdersLoading => _isOrdersLoading;
  Map<String, List<MyOrderModel>> get orders => _orders;
  String? get error => _error;
  TabController? get tabController => _tabController;
  List<String> get dates => _dates;

  MapController get mapController => _mapController;
  LatLng? get customerLatLng => _customerLatLng;

  OrdersManagerProvider() {
    initialize();
  }

  Future<void> initialize() async {
    print('initialize orders manager =====');
    await fetchOrders();
  }

  // Initialize TabController
  void initializeTabController(TickerProvider vsync) {
    if (_dates.isNotEmpty) {
      _tabController =
          TabController(length: _dates.length, vsync: vsync, initialIndex: 0);
    }
    notifyListeners();
  }

  // Update TabController when dates change
  void updateTabController(TickerProvider vsync) {
    initializeTabController(vsync);
  }

  // Orders Management
  Future<void> fetchOrders() async {
    setError(null);
    _setOrdersLoading(true);
    try {
      final response = await WorkerApi.fetchOrders();
      if (response.success && response.data != null) {
        _orders = response.data!;
        _dates = orders.keys.toList();
        notifyListeners();
      } else {
        setError(response.error ?? 'Failed to fetch orders');
      }
    } catch (e) {
      setError('Exception fetching orders: $e');
    } finally {
      setError(null);
      _setOrdersLoading(false);
    }
  }

  // Helper methods for summary data
  int get totalOrders {
    return _orders.values.fold(0, (sum, orders) => sum + orders.length);
  }

  int get pendingOrders {
    return _orders.values.fold(0, (sum, orders) {
      return sum + orders.where((order) => order.status == 1).length;
    });
  }

  void _setOrdersLoading(bool value) {
    _isOrdersLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    print('error ========== $message');
    _error = message;
    if (message != null) print(message);
    notifyListeners();
  }

  // Geocode the customer's address to get latitude and longitude
  Future<void> geocodeAddress(MyOrderModel order) async {
    try {
      final locations = await locationFromAddress(order.location);
      if (locations.isNotEmpty) {
        _customerLatLng =
            LatLng(locations.first.latitude, locations.first.longitude);
        _setOrdersLoading(false);
        notifyListeners();
      } else {
        setError('Could not find location for the provided address.');

        _setOrdersLoading(false);
        notifyListeners();
      }
    } catch (e) {
      setError('Error geocoding address');
      _setOrdersLoading(false);

      notifyListeners();
    }
  }

  // Format timestamp to readable date and time
  String formatTimestamp(dynamic timestamp) {
    DateTime dateTime;
    if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } else {
      dateTime = DateTime.parse(timestamp).toLocal();
    }

    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  Future<void> cancelOrder(
      BuildContext context, int orderId, String reason) async {
    if (reason.isEmpty) {
      setError('Cancellation reason is required');
      return;
    }
    _setOrdersLoading(true);
    try {
      final orderRequest = OrderEditRequest(
        orderId: orderId,
        note: reason,
      );
      final response = await WorkerApi.cancelOrder(orderRequest);
      if (response.success) {
        await fetchOrders();
        await NavigationService.navigateToAndReplace(
          AppRoutes.workerMain,
          arguments: 2,
        );
      } else {
        throw Exception(response.error ?? 'Failed to cancel order');
      }
    } catch (e) {
      setError('Error canceling order: $e');
    } finally {
      _setOrdersLoading(false);
    }
  }

  Future<void> completeOrder(
    BuildContext context,
    int orderId,
  ) async {
    _setOrdersLoading(true);
    try {
      final orderRequest = OrderEditRequest(orderId: orderId);
      final response = await WorkerApi.completeOrder(orderRequest);
      if (response.success) {
        await fetchOrders();
        await NavigationService.navigateToAndReplace(
          AppRoutes.workerMain,
          arguments: 2,
        );
      }
    } catch (e) {
      setError('Error complete order: $e');
    } finally {
      _setOrdersLoading(false);
    }
  }

  // Helper to get status text
  String getStatusText(BuildContext context, int status) {
    switch (status) {
      case 1:
        return AppLocalizations.of(context)!.pending;
      case 2:
        return AppLocalizations.of(context)!.completed;
      case 3:
        return AppLocalizations.of(context)!.canceled;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }

  // Helper to get status color
  Color getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      case 3:
        return Colors.grey;

      default:
        return Colors.grey;
    }
  }
}

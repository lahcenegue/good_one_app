import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/User/Models/order_model.dart';
import 'package:good_one_app/Features/Worker/Models/chart_models.dart';

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
  int get totalOrders =>
      _orders.values.fold(0, (sum, list) => sum + list.length);
  int get pendingOrders => _orders.values
      .fold(0, (sum, list) => sum + list.where((o) => o.status == 1).length);

  MapController get mapController => _mapController;
  LatLng? get customerLatLng => _customerLatLng;

  int get totalIncompleteOrders => _orders.values
      .fold(0, (sum, list) => sum + list.where((o) => o.status == 1).length);

  OrdersManagerProvider() {
    initialize();
  }

  Future<void> initialize() async {
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
        // Sort orders to prioritize pending ones
        _orders = _sortOrdersByPriority(response.data!);
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

  int getIncompleteOrdersCount(String date) {
    final dateOrders = _orders[date] ?? [];
    return dateOrders.where((order) => order.status == 1).length;
  }

  // This sorts orders to show incomplete (pending) orders first
  Map<String, List<MyOrderModel>> _sortOrdersByPriority(
      Map<String, List<MyOrderModel>> orders) {
    Map<String, List<MyOrderModel>> sortedOrders = {};

    for (String date in orders.keys) {
      List<MyOrderModel> dateOrders = List.from(orders[date] ?? []);

      // Sort orders: status 1 (pending) first, then others
      dateOrders.sort((a, b) {
        // Pending orders (status 1) come first
        if (a.status == 1 && b.status != 1) return -1;
        if (a.status != 1 && b.status == 1) return 1;

        // Among non-pending orders, sort by creation time (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });

      sortedOrders[date] = dateOrders;
    }

    return sortedOrders;
  }

  // Helper methods for summary data
  List<ChartData> getRequestStatusChartData(BuildContext context) {
    final completedOrders = totalOrders - pendingOrders;
    return [
      ChartData(AppLocalizations.of(context)!.pending, pendingOrders,
          AppColors.chartPending),
      ChartData(AppLocalizations.of(context)!.completed, completedOrders,
          AppColors.chartCompleted),
    ].where((item) => item.value > 0).toList();
  }

  void _setOrdersLoading(bool value) {
    _isOrdersLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _error = message;
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
    int orderId, {
    VoidCallback? onBalanceRefreshNeeded,
  }) async {
    _setOrdersLoading(true);
    try {
      final orderRequest = OrderEditRequest(orderId: orderId);
      final response = await WorkerApi.completeOrder(orderRequest);
      if (response.success) {
        await fetchOrders();

        // Call the callback to refresh balance
        onBalanceRefreshNeeded?.call();

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
        return AppColors.errorColor;
      case 2:
        return AppColors.successColor;
      case 3:
        return AppColors.chartInactive;

      default:
        return AppColors.chartInactive;
    }
  }
}

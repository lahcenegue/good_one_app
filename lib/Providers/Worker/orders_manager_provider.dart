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
import 'package:good_one_app/l10n/app_localizations.dart';

class OrdersManagerProvider extends ChangeNotifier {
  String? _error;
  bool _isOrdersLoading = false;
  Map<String, List<MyOrderModel>> _orders = {};
  List<String> _dates = [];
  TabController? _tabController;
  TickerProvider? _vsync;

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

  // Initialize TabController with proper cleanup
  void initializeTabController(TickerProvider vsync) {
    // Store the vsync for future use
    _vsync = vsync;

    // Dispose existing controller if it exists
    _tabController?.dispose();

    if (_dates.isNotEmpty) {
      _tabController =
          TabController(length: _dates.length, vsync: vsync, initialIndex: 0);

      // Add listener for tab changes
      _tabController?.addListener(_onTabChanged);
    } else {
      _tabController = null;
    }
    notifyListeners();
  }

  void _onTabChanged() {
    // Force rebuild when tab changes
    if (_tabController != null && !_tabController!.indexIsChanging) {
      notifyListeners();
    }
  }

  // Update TabController when dates change
  void updateTabController() {
    if (_vsync != null) {
      initializeTabController(_vsync!);
    }
  }

  // Orders Management
  Future<void> fetchOrders() async {
    setError(null);
    _setOrdersLoading(true);

    try {
      final response = await WorkerApi.fetchOrders();

      if (response.success) {
        final oldDatesLength = _dates.length;

        // The response.data should be Map<String, List<MyOrderModel>>
        final ordersMap = response.data ?? <String, List<MyOrderModel>>{};

        // Sort orders to prioritize pending ones
        _orders = _sortOrdersByPriority(ordersMap);
        _dates = _orders.keys.toList();

        // Update TabController if dates changed and we have a vsync
        if (_dates.length != oldDatesLength && _vsync != null) {
          updateTabController();
        }

        notifyListeners();
      } else {
        setError(response.error ?? 'Failed to fetch orders');
      }
    } catch (e) {
      setError('Exception fetching orders: $e');
    } finally {
      _setOrdersLoading(false);
    }
  }

  int getIncompleteOrdersCount(String date) {
    final dateOrders = _orders[date] ?? [];
    return dateOrders.where((order) => order.status == 1).length;
  }

  // This sorts orders to show incomplete (pending) orders first
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
        // Parse createdAt strings to DateTime for comparison
        try {
          final aCreatedAt = DateTime.parse(a.createdAt);
          final bCreatedAt = DateTime.parse(b.createdAt);
          return bCreatedAt.compareTo(aCreatedAt);
        } catch (e) {
          // If date parsing fails, maintain original order
          return 0;
        }
      });

      sortedOrders[date] = dateOrders;
    }

    return sortedOrders;
  }

  // Helper methods for summary data
  List<ChartData> getRequestStatusChartData(BuildContext context) {
    // Handle empty orders case gracefully
    if (_orders.isEmpty) {
      return [
        ChartData(
            AppLocalizations.of(context)!.pending, 0, AppColors.chartPending),
        ChartData(AppLocalizations.of(context)!.completed, 0,
            AppColors.chartCompleted),
      ];
    }

    final completedOrders = totalOrders - pendingOrders;
    final chartData = [
      ChartData(AppLocalizations.of(context)!.pending, pendingOrders,
          AppColors.chartPending),
      ChartData(AppLocalizations.of(context)!.completed, completedOrders,
          AppColors.chartCompleted),
    ];

    // Return all data points for charts, even if they're zero
    // This prevents empty chart issues
    return chartData;
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

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }
}

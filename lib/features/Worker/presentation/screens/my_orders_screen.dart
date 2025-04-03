import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/general_box.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Models/my_order_model.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/order_details_page.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Providers/Worker/orders_manager_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersManagerProvider>(
      builder: (context, orderManager, _) {
        if (orderManager.isOrdersLoading) {
          return Scaffold(
            body: LoadingIndicator(),
          );
        }

        if (orderManager.error != null) {
          return Scaffold(
            body: _buildErrorState(context, orderManager),
          );
        }

        if (orderManager.tabController == null) {
          return OrdersContentInitializer();
        }
        return Scaffold(
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            child: OrdersContent(tabController: orderManager.tabController!),
            onRefresh: () => orderManager.fetchOrders(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        AppLocalizations.of(context)!.myOrders,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

// Error State
  Widget _buildErrorState(
      BuildContext context, OrdersManagerProvider ordersManager) {
    return AppErrorWidget(
      message: AppLocalizations.of(context)!.somethingWentWrong,
      onRetry: () async {
        await ordersManager.fetchOrders();
      },
    );
  }
}

class OrdersContentInitializer extends StatefulWidget {
  const OrdersContentInitializer({super.key});

  @override
  State<OrdersContentInitializer> createState() =>
      _OrdersContentInitializerState();
}

class _OrdersContentInitializerState extends State<OrdersContentInitializer>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrdersManagerProvider>().initializeTabController(this);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class OrdersContent extends StatefulWidget {
  final TabController tabController;

  const OrdersContent({
    super.key,
    required this.tabController,
  });

  @override
  State<OrdersContent> createState() => _OrdersContentState();
}

class _OrdersContentState extends State<OrdersContent> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersManager = context.watch<OrdersManagerProvider>();
    return Column(
      children: [
        _buildTabBar(context, ordersManager),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              print('Refresh triggered'); // Debug log
              await ordersManager.fetchOrders();
            },
            child: TabBarView(
              controller: widget.tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: ordersManager.dates.map((date) {
                return _buildOrdersList(
                    context, ordersManager.orders[date] ?? []);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    OrdersManagerProvider ordersManager,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.getAdaptiveSize(10)),
      color: AppColors.dimGray,
      child: TabBar(
        controller: ordersManager.tabController,
        isScrollable: true,
        indicatorWeight: 0,
        indicator: BoxDecoration(),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        tabs: ordersManager.dates.map((date) {
          final dateTime = DateTime.parse(date);
          final dayOfWeek = DateFormat('EEE').format(dateTime).toUpperCase();
          final dayOfMonth = DateFormat('d').format(dateTime);

          return Tab(
            child: Builder(
              builder: (BuildContext context) {
                final isSelected = ordersManager.tabController!.index ==
                    ordersManager.dates.indexOf(date);

                return Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.getAdaptiveSize(4),
                    vertical: context.getAdaptiveSize(2),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                    borderRadius:
                        BorderRadius.circular(context.getAdaptiveSize(5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayOfWeek,
                      ),
                      Text(
                        dayOfMonth,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrdersList(
    BuildContext context,
    List<MyOrderModel> orders,
  ) {
    final ordersManager = context.read<OrdersManagerProvider>();
    return RefreshIndicator(
      onRefresh: () => ordersManager.fetchOrders(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(context.getAdaptiveSize(16)),
          child: Column(
            children: [
              if (orders.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.noOrdersForThisDate,
                      style: AppTextStyles.subTitle(context)
                          .copyWith(color: AppColors.hintColor),
                    ),
                  ),
                )
              else
                ...orders.asMap().entries.map((entry) {
                  final index = entry.key;
                  final order = entry.value;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(order: order),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: index < orders.length - 1
                            ? context.getHeight(16)
                            : 0,
                      ),
                      child: _orderBox(context, ordersManager, order),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderBox(BuildContext context, OrdersManagerProvider orderManager,
      MyOrderModel order) {
    return GeneralBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          UserAvatar(
            picture: order.user.picture,
            size: context.getAdaptiveSize(50),
          ),
          SizedBox(width: context.getWidth(10)),

          // Order Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.user.fullName,
                  style: AppTextStyles.title2(context),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order.service,
                      style: AppTextStyles.subTitle(context),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.getWidth(8),
                        vertical: context.getHeight(4),
                      ),
                      decoration: BoxDecoration(
                        color: orderManager
                            .getStatusColor(order.status)
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(context.getAdaptiveSize(12)),
                      ),
                      child: Text(
                        orderManager.getStatusText(context, order.status),
                        style: AppTextStyles.text(context).copyWith(
                          color: orderManager.getStatusColor(order.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.getHeight(4)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.location,
                      style: AppTextStyles.subTitle(context),
                    ),
                    SizedBox(
                      width: context.getWidth(120),
                      child: Text(
                        order.location,
                        style: AppTextStyles.text(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.getHeight(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.startTime,
                      style: AppTextStyles.subTitle(context),
                    ),
                    Text(
                      _formatTimestamp(order.startAt),
                      style: AppTextStyles.text(context)
                          .copyWith(color: AppColors.hintColor),
                    ),
                  ],
                ),
                SizedBox(height: context.getHeight(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.totalAmount}:',
                      style: AppTextStyles.title2(context),
                    ),
                    Text(
                      ' \$${order.totalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.title2(context)
                          .copyWith(color: AppColors.primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    DateTime dateTime;
    if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    } else {
      dateTime = DateTime.parse(timestamp).toLocal();
    }
    return DateFormat('MMM dd, HH:mm').format(dateTime);
  }
}

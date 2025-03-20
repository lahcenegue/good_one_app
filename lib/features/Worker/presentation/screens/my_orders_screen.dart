import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Infrastructure/api/api_endpoints.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Models/my_order_model.dart';
import 'package:good_one_app/Providers/worker_maganer_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<String> _dates = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workerManager =
          Provider.of<WorkerManagerProvider>(context, listen: false);
      workerManager.fetchOrders().then((_) {
        setState(() {
          _dates = workerManager.orders.keys.toList();
          debugPrint('Dates fetched: $_dates');
          if (_dates.isEmpty) {
            debugPrint('No dates found in orders');
          } else {
            debugPrint('Orders per date:');
            for (var date in _dates) {
              debugPrint(
                  '$date: ${workerManager.orders[date]?.length ?? 0} orders');
            }
          }
          _tabController = TabController(length: _dates.length, vsync: this);
        });
      }).catchError((e) {
        debugPrint('Error fetching orders in MyOrdersScreen: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch orders: $e')),
        );
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerManagerProvider>(
      builder: (context, workerManager, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: workerManager.isOrdersLoading
              ? const Center(child: CircularProgressIndicator())
              : workerManager.error != null
                  ? _buildErrorState(context, workerManager)
                  : _dates.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.noOrdersAvailable,
                            style: AppTextStyles.subTitle(context),
                          ),
                        )
                      : Column(
                          children: [
                            _buildTabBar(context),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: _dates.map((date) {
                                  return _buildOrdersList(context,
                                      workerManager.orders[date] ?? []);
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppLocalizations.of(context)!.myOrders,
        style: AppTextStyles.appBarTitle(context)
            .copyWith(color: AppColors.primaryColor),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildErrorState(
      BuildContext context, WorkerManagerProvider workerManager) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: context.getAdaptiveSize(60),
            height: context.getAdaptiveSize(60),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
          SizedBox(height: context.getHeight(16)),
          Text(
            AppLocalizations.of(context)!.somethingWentWrong,
            style: AppTextStyles.subTitle(context),
          ),
          SizedBox(height: context.getHeight(16)),
          PrimaryButton(
            text: AppLocalizations.of(context)!.retry,
            onPressed: workerManager.fetchOrders,
            width: context.getWidth(150),
            height: context.getHeight(50),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: context.getAdaptiveSize(8)),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.primaryColor,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.hintColor,
        labelStyle: AppTextStyles.subTitle(context)
            .copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AppTextStyles.subTitle(context),
        tabs: _dates.map((date) {
          final dateTime = DateTime.parse(date);
          final dayOfWeek = DateFormat('EEE').format(dateTime).toUpperCase();
          final dayOfMonth = DateFormat('d').format(dateTime);
          return Tab(
            child: Column(
              children: [
                Text(dayOfWeek),
                Text(dayOfMonth),
                if (_tabController?.index == _dates.indexOf(date))
                  Container(
                    width: context.getAdaptiveSize(8),
                    height: context.getAdaptiveSize(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<MyOrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noOrdersForThisDate,
          style: AppTextStyles.subTitle(context),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      itemCount: orders.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: context.getHeight(16)),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.getAdaptiveSize(12)),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.getAdaptiveSize(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.service,
                      style: AppTextStyles.subTitle(context),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to order details screen (to be implemented)
                      },
                      child: Text(
                        AppLocalizations.of(context)!.seeAll,
                        style: AppTextStyles.text(context).copyWith(
                          color: AppColors.primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.getHeight(4)),
                Text(
                  order.service,
                  style: AppTextStyles.title(context).copyWith(fontSize: 18),
                ),
                SizedBox(height: context.getHeight(8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.servicePrice,
                          style: AppTextStyles.subTitle(context),
                        ),
                        SizedBox(height: context.getHeight(4)),
                        Text(
                          '\$${order.costPerHour}/hr',
                          style: AppTextStyles.text(context)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.totalAmount,
                          style: AppTextStyles.subTitle(context),
                        ),
                        SizedBox(height: context.getHeight(4)),
                        Text(
                          '\$${order.totalPrice}',
                          style: AppTextStyles.text(context)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: context.getHeight(16)),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(context.getAdaptiveSize(20)),
                      child: Image.network(
                        '${ApiEndpoints.imageBaseUrl}/${order.user.picture}',
                        width: context.getAdaptiveSize(40),
                        height: context.getAdaptiveSize(40),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: context.getAdaptiveSize(40),
                          color: AppColors.hintColor,
                        ),
                      ),
                    ),
                    SizedBox(width: context.getWidth(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.client,
                            style: AppTextStyles.subTitle(context),
                          ),
                          SizedBox(height: context.getHeight(4)),
                          Text(
                            order.user.fullName,
                            style: AppTextStyles.text(context)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: context.getHeight(4)),
                          Text(
                            order.location,
                            style: AppTextStyles.text(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.getAdaptiveSize(12),
                        vertical: context.getAdaptiveSize(6),
                      ),
                      decoration: BoxDecoration(
                        color: order.status == 1
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(context.getAdaptiveSize(8)),
                      ),
                      child: Text(
                        order.status == 1
                            ? AppLocalizations.of(context)!.canceled
                            : AppLocalizations.of(context)!.confirmed,
                        style: AppTextStyles.text(context).copyWith(
                          color: order.status == 1 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

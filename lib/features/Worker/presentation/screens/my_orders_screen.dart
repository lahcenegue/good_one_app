import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Infrastructure/api/api_endpoints.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Error/error_widget.dart';
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
                  ? AppErrorWidget(
                      message: AppLocalizations.of(context)!.somethingWentWrong,
                      onRetry: workerManager.fetchOrders,
                    )
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
      automaticallyImplyLeading: false,
      title: Text(
        AppLocalizations.of(context)!.myOrders,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.getAdaptiveSize(8)),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.primaryColor,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.hintColor,
        labelStyle: AppTextStyles.subTitle(context),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.service,
                          style: AppTextStyles.subTitle(context),
                        ),
                        SizedBox(height: context.getHeight(4)),
                        Text(
                          AppLocalizations.of(context)!.servicePrice,
                          style: AppTextStyles.subTitle(context),
                        ),
                        SizedBox(height: context.getHeight(4)),
                        Text(
                          AppLocalizations.of(context)!.totalAmount,
                          style: AppTextStyles.title(context).copyWith(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.service,
                          style: AppTextStyles.subTitle(context),
                        ),
                        SizedBox(height: context.getHeight(4)),
                        Text(
                          '\$${order.costPerHour}',
                          style: AppTextStyles.subTitle(context),
                        ),
                        SizedBox(height: context.getHeight(4)),
                        Text(
                          '\$${order.totalPrice}',
                          style: AppTextStyles.price(context),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: context.getHeight(16)),
                Text(
                  AppLocalizations.of(context)!.client,
                  style: AppTextStyles.title2(context),
                ),
                SizedBox(height: context.getHeight(8)),
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
                  ],
                ),
                SizedBox(height: context.getHeight(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmallSecondaryButton(
                      text: 'details',
                      onPressed: () {},
                    ),
                    SmallPrimaryButton(
                      text: AppLocalizations.of(context)!.canceled,
                      onPressed: () {},
                    )
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

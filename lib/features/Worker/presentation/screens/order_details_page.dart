import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:good_one_app/Providers/Worker/orders_manager_provider.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_assets.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Features/Chat/Presentation/Screens/chat_screen.dart';
import 'package:good_one_app/Features/Worker/Models/my_order_model.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrderDetailsPage extends StatefulWidget {
  final MyOrderModel order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final orderManager =
          Provider.of<OrdersManagerProvider>(context, listen: false);
      await orderManager.geocodeAddress(widget.order);
    });
  }

  // Launch Google Maps with the customer's address for navigation
  Future<void> _launchGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(widget.order.location)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.notLaunchGoogleMaps)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersManagerProvider>(
      builder: (context, orderManager, _) {
        return Scaffold(
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(context.getAdaptiveSize(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Order ID
                  _buildHeader(orderManager),
                  SizedBox(height: context.getHeight(16)),

                  // Order Summary Section
                  _buildOrderSummarySection(orderManager),
                  SizedBox(height: context.getHeight(24)),

                  // Customer Info Section
                  _buildChatWithCustomerSection(),

                  _buildNoteSection(),
                  SizedBox(height: context.getHeight(24)),

                  // Map Section
                  _buildMapSection(orderManager),
                  SizedBox(height: context.getHeight(24)),

                  // Action Buttons
                  widget.order.status == 3 || widget.order.status == 2
                      ? SizedBox.shrink()
                      : _buildActionButtons(orderManager),
                  SizedBox(height: context.getHeight(16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.ordersDetails,
        style: AppTextStyles.appBarTitle(context),
      ),
    );
  }

  Widget _buildHeader(OrdersManagerProvider orderManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${AppLocalizations.of(context)!.order} #${widget.order.id}',
          style: AppTextStyles.title(context).copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.getWidth(12),
            vertical: context.getHeight(6),
          ),
          decoration: BoxDecoration(
            color: orderManager
                .getStatusColor(widget.order.status)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            orderManager.getStatusText(context, widget.order.status),
            style: AppTextStyles.subTitle(context).copyWith(
              color: orderManager.getStatusColor(widget.order.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Order Summary Section
  Widget _buildOrderSummarySection(OrdersManagerProvider orderManager) {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.hintColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.orderSummary,
            style: AppTextStyles.title2(context),
          ),
          SizedBox(height: context.getHeight(12)),
          _buildInfoRow(
              AppLocalizations.of(context)!.service, widget.order.service),
          _buildInfoRow(AppLocalizations.of(context)!.createdAt,
              orderManager.formatTimestamp(widget.order.createdAt)),
          _buildInfoRow(AppLocalizations.of(context)!.startTime,
              orderManager.formatTimestamp(widget.order.startAt)),

          //
          // NEW: Show pricing information based on pricing type
          if (widget.order.pricingType == 'hourly') ...[
            _buildInfoRow(
              AppLocalizations.of(context)!.totalHours,
              '${widget.order.totalHours} ${AppLocalizations.of(context)!.hours}',
            ),
            _buildInfoRow(
              AppLocalizations.of(context)!.costPerHour,
              '\$${widget.order.costPerHour?.toStringAsFixed(2) ?? '0'}',
            ),
          ] else if (widget.order.pricingType == 'daily') ...[
            _buildInfoRow(
              AppLocalizations.of(context)!.totalDays,
              '${(widget.order.totalHours / 8).ceil()} ${AppLocalizations.of(context)!.days}',
            ), // Assuming 8 hours per day
            _buildInfoRow(
              AppLocalizations.of(context)!.costPerDay,
              '\$${widget.order.costPerDay?.toStringAsFixed(2) ?? '0'}',
            ),
          ] else if (widget.order.pricingType == 'fixed') ...[
            _buildInfoRow(
              AppLocalizations.of(context)!.serviceType,
              AppLocalizations.of(context)!.fixedPriceService,
            ),
            _buildInfoRow(
              AppLocalizations.of(context)!.fixedRate,
              '\$${widget.order.fixedPrice?.toStringAsFixed(2) ?? '0'}',
            ),
          ] else ...[
            // Fallback for legacy orders
            _buildInfoRow(
              AppLocalizations.of(context)!.totalHours,
              '${widget.order.totalHours} ${AppLocalizations.of(context)!.hours}',
            ),
            _buildInfoRow(
              AppLocalizations.of(context)!.costPerHour,
              '\$${widget.order.costPerHour?.toStringAsFixed(2) ?? '0'}',
            ),
          ],

          //
          _buildInfoRow(
            AppLocalizations.of(context)!.totalHours,
            '${widget.order.totalHours} ${AppLocalizations.of(context)!.hours}',
          ),

          _buildInfoRow(
            AppLocalizations.of(context)!.totalAmount,
            '\$${widget.order.totalPrice.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  // Customer Info Section
  Widget _buildChatWithCustomerSection() {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hintColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.chatWithCustomer,
            style: AppTextStyles.title2(context),
          ),
          SizedBox(height: context.getHeight(12)),
          Row(
            children: [
              UserAvatar(
                picture: widget.order.user.picture,
                size: context.getAdaptiveSize(50),
              ),
              SizedBox(width: context.getWidth(12)),
              Expanded(
                child: Text(
                  widget.order.user.fullName,
                  style: AppTextStyles.title2(context),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        otherUserId: widget.order.user.id.toString(),
                        otherUserName: widget.order.user.fullName,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(context.getAdaptiveSize(10)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    AppAssets.message,
                    width: context.getAdaptiveSize(24),
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    if (widget.order.note.isNotEmpty) {
      return Column(
        children: [
          SizedBox(height: context.getHeight(12)),
          Container(
            padding: EdgeInsets.all(context.getAdaptiveSize(16)),
            width: context.screenWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.note,
                  style: AppTextStyles.title2(context),
                ),
                SizedBox(height: context.getHeight(12)),
                Text(
                  widget.order.note,
                  style: AppTextStyles.text(context),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  // Map Section
  Widget _buildMapSection(OrdersManagerProvider orderManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: context.screenWidth - context.getAdaptiveSize(120),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.deliveryLocation,
                    style: AppTextStyles.title2(context),
                  ),
                  SizedBox(height: context.getHeight(5)),
                  Text(
                    widget.order.location,
                    style: AppTextStyles.text(context),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _launchGoogleMaps,
              child: Container(
                padding: EdgeInsets.all(context.getAdaptiveSize(10)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mode_of_travel_sharp,
                  color: AppColors.primaryColor,
                  size: context.getAdaptiveSize(24),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(12)),
        Container(
          height: context.getHeight(250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: AppColors.hintColor.withValues(alpha: 0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildMapWidget(orderManager),
          ),
        ),
      ],
    );
  }

  // Helper to build info rows
  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.getAdaptiveSize(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.subTitle(context),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.text(context),
            ),
          ),
        ],
      ),
    );
  }

  // Map Section with loading and error states
  Widget _buildMapWidget(OrdersManagerProvider orderManager) {
    if (orderManager.isOrdersLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (orderManager.error != null) {
      return Center(child: Text(orderManager.error!));
    }
    if (orderManager.customerLatLng == null) {
      return Center(child: Text(AppLocalizations.of(context)!.unableLoadMap));
    }

    return FlutterMap(
      mapController: orderManager.mapController,
      options: MapOptions(
        initialCenter: orderManager.customerLatLng!,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: orderManager.customerLatLng!,
              child: Icon(
                Icons.location_pin,
                color: AppColors.primaryColor,
                size: context.getAdaptiveSize(50),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Action Buttons
  Widget _buildActionButtons(OrdersManagerProvider orderManager) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SmallSecondaryButton(
          text: AppLocalizations.of(context)!.cancel,
          onPressed: () {
            _showCancelOrderDialog(orderManager);
          },
        ),
        SmallPrimaryButton(
          text: AppLocalizations.of(context)!.complete,
          onPressed: () {
            _showCompleteOrderDialog(orderManager);
          },
        )
      ],
    );
  }

  void _showCancelOrderDialog(OrdersManagerProvider orderManager) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppColors.errorColor),
              SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.cancelOrder,
                style: AppTextStyles.title2(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.reasonForCancellation,
                style: AppTextStyles.text(context),
              ),
              SizedBox(height: context.getHeight(8)),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterReason,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.getWidth(12),
                    vertical: context.getHeight(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.close,
                style: AppTextStyles.text(context).copyWith(color: Colors.grey),
              ),
            ),
            Consumer<OrdersManagerProvider>(
              builder: (context, orderManager, child) {
                return ElevatedButton(
                  onPressed: orderManager.isOrdersLoading
                      ? null
                      : () async {
                          final reason = reasonController.text.trim();
                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!
                                    .reasonRequired),
                                backgroundColor: AppColors.errorColor,
                              ),
                            );
                            return;
                          }

                          await orderManager.cancelOrder(
                              context, widget.order.id, reason);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  child: orderManager.isOrdersLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.submit),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showCompleteOrderDialog(OrdersManagerProvider orderManager) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.completed,
            style: AppTextStyles.title2(context),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.successColor,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.hasServiceBeenReceived,
                style: AppTextStyles.text(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.notYet,
                style: AppTextStyles.text(context).copyWith(color: Colors.grey),
              ),
            ),
            Consumer<OrdersManagerProvider>(
              builder: (context, orderManager, child) {
                return ElevatedButton(
                  onPressed: orderManager.isOrdersLoading
                      ? null
                      : () async {
                          // Get WorkerManagerProvider before any async operations
                          final workerProvider =
                              Provider.of<WorkerManagerProvider>(context,
                                  listen: false);

                          // Complete the order with callback for balance refresh
                          await orderManager.completeOrder(
                            context,
                            widget.order.id,
                            onBalanceRefreshNeeded: () async {
                              try {
                                await workerProvider.getMyBalance();
                              } catch (e) {
                                print('Could not refresh balance: $e');
                              }
                            },
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    foregroundColor: Colors.white,
                  ),
                  child: orderManager.isOrdersLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.confirm),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

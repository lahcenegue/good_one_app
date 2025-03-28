import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:good_one_app/Providers/Worker/orders_manager_provider.dart';
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

// Main StatefulWidget for the Order Details page
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Google Maps.')),
      );
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
                  _buildHeader(),
                  SizedBox(height: context.getHeight(16)),

                  // Order Summary Section
                  _buildOrderSummarySection(orderManager),
                  SizedBox(height: context.getHeight(24)),

                  // Customer Info Section
                  _buildCustomerInfoSection(),

                  _buildNoteSection(),
                  SizedBox(height: context.getHeight(24)),

                  // Map Section
                  _buildMapSection(orderManager),
                  SizedBox(height: context.getHeight(24)),

                  // Action Buttons
                  _buildActionButtons(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order #${widget.order.id}',
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
            color: _getStatusColor(widget.order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(widget.order.status),
            style: AppTextStyles.subTitle(context).copyWith(
              color: _getStatusColor(widget.order.status),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hintColor.withOpacity(0.2)),
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
          _buildInfoRow(AppLocalizations.of(context)!.totalHours,
              '${widget.order.totalHours} hrs'),
          _buildInfoRow(AppLocalizations.of(context)!.costPerHour,
              '\$${widget.order.costPerHour.toStringAsFixed(2)}'),
          _buildInfoRow(
            AppLocalizations.of(context)!.totalPrice,
            '\$${widget.order.totalPrice.toStringAsFixed(2)}',
            isBold: true,
            valueColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  // Customer Info Section
  Widget _buildCustomerInfoSection() {
    return Container(
      padding: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hintColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.customerInformation,
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
                    color: AppColors.primaryColor.withOpacity(0.1),
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
                color: AppColors.primaryColor.withOpacity(0.5),
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
            Text(
              AppLocalizations.of(context)!.deliveryLocation,
              style: AppTextStyles.title2(context),
            ),
            GestureDetector(
              onTap: _launchGoogleMaps,
              child: Container(
                padding: EdgeInsets.all(context.getAdaptiveSize(10)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
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
            border: Border.all(color: AppColors.hintColor.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildMapWidget(orderManager),
          ),
        ),
        SizedBox(height: context.getHeight(12)),
        Text(
          widget.order.location,
          style:
              AppTextStyles.text(context).copyWith(color: AppColors.hintColor),
        ),
      ],
    );
  }

  // Action Buttons
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SmallSecondaryButton(
          text: AppLocalizations.of(context)!.cancel,
          onPressed: () {},
        ),
        SmallPrimaryButton(
          text: AppLocalizations.of(context)!.complete,
          onPressed: () {},
        )
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
      return const Center(child: Text('Unable to load map.'));
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

  // Helper to get status text
  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return AppLocalizations.of(context)!.canceled;
      case 1:
        return AppLocalizations.of(context)!.pending;
      case 2:
        return AppLocalizations.of(context)!.completed;
      default:
        return AppLocalizations.of(context)!.unknown;
    }
  }

  // Helper to get status color
  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

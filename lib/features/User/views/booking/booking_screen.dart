import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/user_avatar.dart';
import 'package:provider/provider.dart';

import '../../../../Core/presentation/Widgets/Buttons/primary_button.dart';
import '../../../../Providers/user_manager_provider.dart';
import '../../models/booking.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/contractor.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        Provider.of<UserManagerProvider>(context, listen: false)
            .setCurrentBookingTab(_tabController.index + 1);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserManagerProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context)!.booking,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: context.getHeight(8),
                    horizontal: context.getWidth(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black45,
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.completed),
                    Tab(text: AppLocalizations.of(context)!.inProgress),
                    Tab(text: AppLocalizations.of(context)!.canceled),
                  ],
                ),
              ),
              Expanded(
                child: userManager.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : userManager.bookings.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)!.noBookings,
                              style: AppTextStyles.text(context),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(context.getWidth(16)),
                            itemCount: userManager.bookings.length,
                            itemBuilder: (context, index) {
                              final booking = userManager.bookings[index];
                              return _buildBookingCard(
                                  context, booking, userManager);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    Booking booking,
    UserManagerProvider userManager,
  ) {
    // Assuming the contractor is fetched or stored elsewhere; for now, use placeholder data
    final contractor = userManager.bestContractors.firstWhere(
      (c) => c.id == booking.userId, // Adjust based on how contractor is linked
      orElse: () => Contractor(
        id: booking.userId,
        email: null,
        phone: null,
        fullName: 'Honey Bee',
        picture: 'https://example.com/honey_bee.jpg', // Placeholder image URL
        location: null,
        costPerHour:
            booking.price.toInt(), // Convert double to int for costPerHour
        service: 'Plumber',
        yearsOfExperience: null,
        about: null,
        securityCheck: null,
        verifiedLiscence: null,
        rating: Rating(rating: 0, timesRated: 0), // Default rating
        ratings: [], // Empty ratings list
        orders: 0, // Default orders
        gallery: [], // Empty gallery
        city: null,
        country: null,
        subcategory: null,
        isFavorite: false,
      ),
    );

    Color statusColor;
    String statusText;
    switch (booking.status) {
      case 1: // Completed
        statusColor = Colors.green;
        statusText = AppLocalizations.of(context)!.completed;
        break;
      case 2: // In Progress
        statusColor = Colors.orange;
        statusText = AppLocalizations.of(context)!.inProgress;
        break;
      case 3: // Canceled
        statusColor = Colors.red;
        statusText = AppLocalizations.of(context)!.canceled;
        break;
      default:
        statusColor = Colors.grey;
        statusText = AppLocalizations.of(context)!.unknownStatus;
    }

    return Container(
      margin: EdgeInsets.only(bottom: context.getHeight(12)),
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.service,
                style: AppTextStyles.text(context),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: context.getWidth(8),
                    vertical: context.getHeight(4)),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.service,
                style: AppTextStyles.text(context),
              ),
              Text(
                contractor.service ??
                    AppLocalizations.of(context)!.unknownService,
                style: AppTextStyles.text(context),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.servicePrice,
                style: AppTextStyles.text(context),
              ),
              Text(
                '\$${booking.price.toStringAsFixed(2)}',
                style: AppTextStyles.text(context),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.totalAmount,
                style: AppTextStyles.text(context),
              ),
              Text(
                '\$${(booking.price * 0.8).toStringAsFixed(2)}', // 80% of service price as in the image
                style: AppTextStyles.text(context),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(16)),
          Row(
            children: [
              UserAvatar(
                picture: contractor.picture,
                size: context.getWidth(40),
              ),
              SizedBox(width: context.getWidth(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contractor.fullName ??
                        AppLocalizations.of(context)!.unknownProvider,
                    style: AppTextStyles.text(context),
                  ),
                  Text(
                    contractor.service ??
                        AppLocalizations.of(context)!.unknownService,
                    style: AppTextStyles.text(context)
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          if (booking.status == 2) // In Progress
            SizedBox(height: context.getHeight(12)),
          if (booking.status == 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PrimaryButton(
                  text: AppLocalizations.of(context)!.receive,
                  onPressed: () {
                    // TODO: Implement receive action
                  },
                  height: context.getHeight(40),
                  width: context.getWidth(120),
                ),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Implement cancel action
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(
                        horizontal: context.getWidth(16),
                        vertical: context.getHeight(8)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.canceled,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

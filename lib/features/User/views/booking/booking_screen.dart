import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Features/User/models/booking.dart';
import 'package:good_one_app/Providers/user_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../Core/presentation/Widgets/user_avatar.dart';

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
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookings();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabController.index + 1;
      });
    }
  }

  void _fetchBookings() {
    Provider.of<UserStateProvider>(context, listen: false).fetchBookings();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserStateProvider>();
    return userManager.token == null
        ? _buildLoginPrompt(context)
        : _buildBookingContent(context);
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.all(constraints.maxWidth * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.pleaseLogin,
                    style: AppTextStyles.title(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.04),
                  Text(
                    AppLocalizations.of(context)!.loginToViewBookings,
                    style: AppTextStyles.text(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.06),
                  PrimaryButton(
                    text: AppLocalizations.of(context)!.login,
                    onPressed: () => NavigationService.navigateTo(
                        AppRoutes.accountSelection),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.booking,
          style: AppTextStyles.appBarTitle(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<UserStateProvider>().fetchBookings(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildMainContent(context),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final userManager = context.watch<UserStateProvider>();
    if (userManager.isBookingLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userManager.bookingError != null) {
      return _buildErrorState(context, userManager.bookingError!);
    }
    return Column(
      children: [
        _buildTabBar(context),
        Expanded(child: _buildBookingList(context)),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.getHeight(8),
        horizontal: context.getWidth(16),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.dimGray,
            blurRadius: 4,
          )
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: AppTextStyles.subTitle(context),
        unselectedLabelStyle: AppTextStyles.text(context),
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.hintColor,
        tabs: [
          Tab(text: AppLocalizations.of(context)!.inProgress),
          Tab(text: AppLocalizations.of(context)!.completed),
          Tab(text: AppLocalizations.of(context)!.canceled),
        ],
      ),
    );
  }

  Widget _buildBookingList(BuildContext context) {
    final userManager = context.watch<UserStateProvider>();
    final currentTabIndex = _tabController.index + 1;
    final filteredBookings = userManager.bookings
        .where((booking) => booking.status == currentTabIndex)
        .toList();

    return filteredBookings.isEmpty
        ? _buildEmptyState(context)
        : ListView.builder(
            padding: EdgeInsets.all(context.getWidth(16)),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) => BookingCard(
              booking: filteredBookings[index],
            ),
          );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(16)),
        child: Text(
          AppLocalizations.of(context)!.noBookings,
          style: AppTextStyles.text(context),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: AppTextStyles.text(context).copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(16)),
            PrimaryButton(
              text: AppLocalizations.of(context)!.retry,
              onPressed: () =>
                  context.read<UserStateProvider>().fetchBookings(),
              width: context.getWidth(150),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusText) = _getStatusDetails(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(12)),
      ),
      margin: EdgeInsets.only(bottom: context.getHeight(16)),
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(context, statusColor, statusText),
            SizedBox(height: context.getHeight(12)),
            _buildDetailsSection(context),
            SizedBox(height: context.getHeight(16)),
            _buildContractorInfo(context),
            if (booking.status == 1) ...[
              SizedBox(height: context.getHeight(16)),
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  (Color, String) _getStatusDetails(BuildContext context) {
    switch (booking.status) {
      case 1:
        return (Colors.orange, AppLocalizations.of(context)!.inProgress);
      case 2:
        return (Colors.green, AppLocalizations.of(context)!.completed);
      case 3:
        return (Colors.red, AppLocalizations.of(context)!.canceled);
      default:
        return (Colors.grey, AppLocalizations.of(context)!.unknownStatus);
    }
  }

  Widget _buildStatusRow(
    BuildContext context,
    Color statusColor,
    String statusText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context)!.status,
            style: AppTextStyles.subTitle(context)),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.getWidth(8),
                vertical: context.getHeight(4),
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: AppTextStyles.text(context).copyWith(color: statusColor),
              ),
            ),
            if (booking.status == 1)
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: AppColors.primaryColor,
                  size: context.getWidth(20),
                ),
                onPressed: () {},
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildDetailRow(context, AppLocalizations.of(context)!.service,
        //     booking.service.service),
        // SizedBox(height: context.getHeight(8)),
        _buildDetailRow(context, AppLocalizations.of(context)!.service,
            booking.service.subcategory.name),
        SizedBox(height: context.getHeight(8)),
        _buildDetailRow(context, AppLocalizations.of(context)!.date,
            booking.formattedStartDate),
        SizedBox(height: context.getHeight(8)),
        _buildDetailRow(context, AppLocalizations.of(context)!.time,
            booking.formattedStartTime),
        SizedBox(height: context.getHeight(8)),
        _buildDetailRow(
            context, AppLocalizations.of(context)!.location, booking.location),
        SizedBox(height: context.getHeight(8)),
        _buildDetailRow(context, AppLocalizations.of(context)!.price,
            '\$${booking.service.costPerHour.toStringAsFixed(2)}/${AppLocalizations.of(context)!.hour}'),
        SizedBox(height: context.getHeight(8)),
        _buildDetailRow(context, AppLocalizations.of(context)!.total,
            '\$${booking.price.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: AppTextStyles.text(context),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: AppTextStyles.text(context)
                .copyWith(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildContractorInfo(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
            picture: booking.service.picture, size: context.getWidth(50)),
        SizedBox(width: context.getWidth(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.service.fullName,
                  style: AppTextStyles.subTitle(context)),
              Text(booking.service.service,
                  style:
                      AppTextStyles.text(context).copyWith(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SmallPrimaryButton(
          text: AppLocalizations.of(context)!.receive,
          onPressed: () => _showReceiveConfirmationDialog(context),
        ),
        SmallSecondaryButton(
          text: AppLocalizations.of(context)!.cancel,
          onPressed: () => _showCancelConfirmationDialog(context),
        ),
      ],
    );
  }

  void _showReceiveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.confirmService,
            style: AppTextStyles.title2(context),
          ),
          content: Text(
            AppLocalizations.of(context)!.hasServiceBeenReceived,
            style: AppTextStyles.text(context),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Optionally, show a message indicating the user selected "Not Yet"
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.markedAsNotReceived),
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context)!.notYet,
                style: AppTextStyles.text(context).copyWith(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Update the booking status to "Completed" (status: 2)
              },
              child: Text(
                AppLocalizations.of(context)!.received,
                style: AppTextStyles.text(context)
                    .copyWith(color: AppColors.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.cancelBooking,
            style: AppTextStyles.title2(context),
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
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: Text(
                AppLocalizations.of(context)!.close,
                style: AppTextStyles.text(context).copyWith(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.reasonRequired),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: Text(
                AppLocalizations.of(context)!.submit,
                style: AppTextStyles.text(context)
                    .copyWith(color: AppColors.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

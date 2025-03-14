import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Core/presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Features/User/models/booking.dart';
import 'package:good_one_app/Features/User/models/order_model.dart';
import 'package:good_one_app/Features/User/presentation/views/service_evaluation_screen.dart';
import 'package:good_one_app/Providers/booking_manager_provider.dart';
import 'package:good_one_app/Providers/user_manager_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Displays and manages the user's bookings.

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManagerProvider>();

    return Consumer<BookingManagerProvider>(
      builder: (context, bookingManager, child) {
        if (bookingManager.isInitializing) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!userManager.isAuthenticated) {
          return _LoginPrompt();
        }
        if (bookingManager.tabController == null) {
          return _BookingContentInitializer();
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context)!.booking,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async => bookingManager.fetchBookings(),
            child:
                _BookingContent(tabController: bookingManager.tabController!),
          ),
        );
      },
    );
  }
}

class _BookingContentInitializer extends StatefulWidget {
  @override
  State<_BookingContentInitializer> createState() =>
      _BookingContentInitializerState();
}

class _BookingContentInitializerState extends State<_BookingContentInitializer>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookingManagerProvider>().setupTabController(this);
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

class _LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: EdgeInsets.all(constraints.maxWidth * 0.04),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.loginToContinue,
                  style: AppTextStyles.title(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: constraints.maxHeight * 0.04),
                Text(
                  AppLocalizations.of(context)!.loginToContinue,
                  style: AppTextStyles.text(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: constraints.maxHeight * 0.06),
                PrimaryButton(
                  text: AppLocalizations.of(context)!.login,
                  onPressed: () =>
                      NavigationService.navigateTo(AppRoutes.accountSelection),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingContent extends StatefulWidget {
  final TabController tabController;

  const _BookingContent({required this.tabController});

  @override
  State<_BookingContent> createState() => _BookingContentState();
}

class _BookingContentState extends State<_BookingContent> {
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
    widget.tabController.removeListener(_handleTabChange); // Clean up listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingManager = context.watch<BookingManagerProvider>();
    return Column(
      children: [
        _TabBarSection(tabController: widget.tabController),
        Expanded(
          child: bookingManager.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : bookingManager.error != null
                  ? _ErrorState(error: bookingManager.error!)
                  : _BookingList(tabController: widget.tabController),
        ),
      ],
    );
  }
}

class _TabBarSection extends StatelessWidget {
  final TabController tabController;

  const _TabBarSection({required this.tabController});

  @override
  Widget build(BuildContext context) {
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
        controller: tabController,
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
}

class _BookingList extends StatelessWidget {
  final TabController tabController;

  const _BookingList({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final bookingManager = context.watch<BookingManagerProvider>();
    final currentTabIndex =
        tabController.index + 1; // 1=In Progress, 2=Completed, 3=Canceled
    final filteredBookings = bookingManager.bookings
        .where((booking) => booking.status == currentTabIndex)
        .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(16)),
        child: Column(
          verticalDirection: VerticalDirection.up,
          children: filteredBookings.isEmpty
              ? [const _EmptyState()]
              : filteredBookings
                  .map((booking) => BookingCard(booking: booking))
                  .toList(),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: AppTextStyles.text(context)
                  .copyWith(color: AppColors.oxblood),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(16)),
            PrimaryButton(
              text: AppLocalizations.of(context)!.retry,
              onPressed: () =>
                  context.read<BookingManagerProvider>().fetchBookings(),
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

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final bookingManager = context.read<BookingManagerProvider>();
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
            _StatusRow(
              booking: booking,
              statusColor: statusColor,
              statusText: statusText,
              onEdit: () => _showModifyBookingDialog(context, bookingManager),
            ),
            SizedBox(height: context.getHeight(12)),
            _DetailsSection(booking: booking),
            SizedBox(height: context.getHeight(16)),
            _ContractorInfo(booking: booking),
            if (booking.status == 1) ...[
              SizedBox(height: context.getHeight(16)),
              _ActionButtons(
                booking: booking,
                onReceive: () => _showReceiveConfirmationDialog(
                    context, bookingManager, booking.id),
                onCancel: () =>
                    _showCancelConfirmationDialog(context, bookingManager),
              ),
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

  void _showModifyBookingDialog(
      BuildContext context, BookingManagerProvider bookingManager) {
    showDialog(
      context: context,
      builder: (_) => _ModifyBookingDialog(
          booking: booking, bookingManager: bookingManager),
    );
  }

  void _showReceiveConfirmationDialog(
    BuildContext context,
    BookingManagerProvider bookingManager,
    int bookingId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppLocalizations.of(context)!.notYet,
              style: AppTextStyles.text(context).copyWith(
                color: AppColors.hintColor,
              ),
            ),
          ),

          // Recive order
          TextButton(
            onPressed: () async {
              await bookingManager.receiveOrder(
                  context, dialogContext, bookingId);
              Navigator.of(dialogContext)
                  .pop(); // Close the dialog after success
            },
            child: Text(
              AppLocalizations.of(context)!.confirmComplete,
              style: AppTextStyles.text(context)
                  .copyWith(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmationDialog(
      BuildContext context, BookingManagerProvider bookingManager) {
    showDialog(
      context: context,
      builder: (_) => _CancelConfirmationDialog(
          booking: booking, bookingManager: bookingManager),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final Booking booking;
  final Color statusColor;
  final String statusText;
  final VoidCallback onEdit;

  const _StatusRow({
    required this.booking,
    required this.statusColor,
    required this.statusText,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
                  vertical: context.getHeight(4)),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(statusText,
                  style:
                      AppTextStyles.text(context).copyWith(color: statusColor)),
            ),
            if (booking.status == 1)
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: AppColors.primaryColor,
                  size: context.getWidth(20),
                ),
                onPressed: onEdit,
              ),
            if (booking.status == 2)
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ServiceEvaluationScreen(
                            serviceId: booking.service.id),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.rate_review,
                    color: AppColors.rating,
                    size: context.getWidth(20),
                  ))
          ],
        ),
      ],
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final Booking booking;

  const _DetailsSection({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(
            label: AppLocalizations.of(context)!.service,
            value: booking.service.subcategory.name),
        SizedBox(height: context.getHeight(8)),
        _DetailRow(
            label: AppLocalizations.of(context)!.location,
            value: booking.location),
        SizedBox(height: context.getHeight(8)),
        _DetailRow(
            label: AppLocalizations.of(context)!.time,
            value:
                '${booking.formattedStartDate}, ${booking.formattedStartTime}'),
        SizedBox(height: context.getHeight(8)),
        _DetailRow(
            label: AppLocalizations.of(context)!.price,
            value:
                '\$${booking.service.costPerHour.toStringAsFixed(2)}/${AppLocalizations.of(context)!.hour}'),
        SizedBox(height: context.getHeight(8)),
        _DetailRow(
            label: AppLocalizations.of(context)!.total,
            value: '\$${booking.price.toStringAsFixed(2)}'),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 1,
            child: Text(label,
                style: AppTextStyles.subTitle(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1)),
        Expanded(
            flex: 2,
            child: Text(value,
                style: AppTextStyles.text(context)
                    .copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.end)),
      ],
    );
  }
}

class _ContractorInfo extends StatelessWidget {
  final Booking booking;

  const _ContractorInfo({required this.booking});

  @override
  Widget build(BuildContext context) {
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
}

class _ActionButtons extends StatelessWidget {
  final Booking booking;
  final VoidCallback onReceive;
  final VoidCallback onCancel;

  const _ActionButtons({
    required this.booking,
    required this.onReceive,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: context.getWidth(150),
          child: SmallPrimaryButton(
            text: AppLocalizations.of(context)!.completed,
            onPressed: onReceive,
          ),
        ),
        SizedBox(
          width: context.getWidth(150),
          child: SmallSecondaryButton(
            text: AppLocalizations.of(context)!.cancel,
            onPressed: onCancel,
          ),
        ),
      ],
    );
  }
}

class _CancelConfirmationDialog extends StatelessWidget {
  final Booking booking;
  final BookingManagerProvider bookingManager;

  const _CancelConfirmationDialog(
      {required this.booking, required this.bookingManager});

  @override
  Widget build(BuildContext context) {
    final reasonController = TextEditingController();

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.cancelBooking,
          style: AppTextStyles.title2(context)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.reasonForCancellation,
              style: AppTextStyles.text(context)),
          SizedBox(height: context.getHeight(8)),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.enterReason,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(12),
                  vertical: context.getHeight(8)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.close,
              style: AppTextStyles.text(context).copyWith(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () async {
            final reason = reasonController.text.trim();
            if (reason.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.reasonRequired)));
              return;
            }
            await bookingManager.cancelOrder(context, booking.id, reason);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.submit,
              style: AppTextStyles.text(context)
                  .copyWith(color: AppColors.primaryColor)),
        ),
      ],
    );
  }
}

class _ModifyBookingDialog extends StatefulWidget {
  final Booking booking;
  final BookingManagerProvider bookingManager;

  const _ModifyBookingDialog(
      {required this.booking, required this.bookingManager});

  @override
  State<_ModifyBookingDialog> createState() => _ModifyBookingDialogState();
}

class _ModifyBookingDialogState extends State<_ModifyBookingDialog> {
  late TextEditingController locationController;
  late TextEditingController noteController;
  late DateTime selectedDay;
  late String selectedTime;
  late int taskDurationHours;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    locationController = TextEditingController(text: widget.booking.location);
    noteController = TextEditingController();
    selectedDay =
        DateTime.fromMillisecondsSinceEpoch(widget.booking.startAt * 1000);
    selectedTime = DateFormat('HH:mm').format(
        DateTime.fromMillisecondsSinceEpoch(widget.booking.startAt * 1000));
    taskDurationHours = widget.booking.totalHours;
  }

  @override
  void dispose() {
    locationController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priceDifference = taskDurationHours > widget.booking.totalHours
        ? (taskDurationHours - widget.booking.totalHours) *
            widget.booking.service.costPerHour
        : 0.0;
    final firstDate = DateTime.now();
    final initialDate =
        selectedDay.isBefore(firstDate) ? firstDate : selectedDay;

    return AlertDialog(
      title: Text('Modify Booking', style: AppTextStyles.title2(context)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.location,
                style: AppTextStyles.text(context)),
            SizedBox(height: context.getHeight(8)),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.location,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            SizedBox(height: context.getHeight(16)),
            Text(AppLocalizations.of(context)!.startDate,
                style: AppTextStyles.text(context)),
            SizedBox(height: context.getHeight(8)),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null && pickedDate != selectedDay) {
                  setState(() => selectedDay = pickedDate);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                child: Text(DateFormat('MMM dd, yyyy').format(selectedDay),
                    style: AppTextStyles.text(context)),
              ),
            ),
            SizedBox(height: context.getHeight(16)),
            Text(AppLocalizations.of(context)!.startTime,
                style: AppTextStyles.text(context)),
            SizedBox(height: context.getHeight(8)),
            DropdownButtonFormField<String>(
              value: selectedTime,
              items: widget.bookingManager.availableTimeSlots
                  .map((time) =>
                      DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (newValue) => setState(() => selectedTime = newValue!),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            SizedBox(height: context.getHeight(16)),
            Text(AppLocalizations.of(context)!.duration,
                style: AppTextStyles.text(context)),
            SizedBox(height: context.getHeight(8)),
            DropdownButtonFormField<int>(
              value: taskDurationHours,
              items: widget.bookingManager.availableDurations
                  .where((hours) => hours >= widget.booking.totalHours)
                  .map((hours) => DropdownMenuItem(
                        value: hours,
                        child: Text(
                            '$hours ${hours == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}'),
                      ))
                  .toList(),
              onChanged: (newValue) =>
                  setState(() => taskDurationHours = newValue!),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            SizedBox(height: context.getHeight(16)),
            Text(AppLocalizations.of(context)!.reasonForCancellation,
                style: AppTextStyles.text(context)),
            SizedBox(height: context.getHeight(8)),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterReason,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            if (priceDifference > 0) ...[
              SizedBox(height: context.getHeight(16)),
              Text(AppLocalizations.of(context)!.additionalPaymentRequired,
                  style: AppTextStyles.text(context)
                      .copyWith(color: AppColors.primaryColor)),
              SizedBox(height: context.getHeight(8)),
              Text(
                  AppLocalizations.of(context)!.additionalHours(
                      (taskDurationHours - widget.booking.totalHours)
                          .toString()),
                  style: AppTextStyles.text(context)),
              Text(
                  AppLocalizations.of(context)!
                      .additionalCost(priceDifference.toStringAsFixed(2)),
                  style: AppTextStyles.text(context)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.close,
              style: AppTextStyles.text(context).copyWith(color: Colors.grey)),
        ),
        TextButton(
          onPressed: isSubmitting
              ? null
              : () async {
                  setState(() => isSubmitting = true);
                  final now = DateTime.now();
                  final startDateTime = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                      int.parse(selectedTime.split(':')[0]),
                      0);
                  final endDateTime =
                      startDateTime.add(Duration(hours: taskDurationHours));

                  if (!startDateTime.isAfter(now)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Start time must be in the future')));
                    setState(() => isSubmitting = false);
                    return;
                  }
                  if (endDateTime.hour > 22 || endDateTime.hour < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('End time must be between 6:00 and 22:00')));
                    setState(() => isSubmitting = false);
                    return;
                  }

                  final newTimestamp = widget.bookingManager
                      .getTimestamp(selectedDay, selectedTime);
                  final orderEditRequest = OrderEditRequest(
                    orderId: widget.booking.id,
                    location: locationController.text.isNotEmpty
                        ? locationController.text
                        : null,
                    startAt: newTimestamp,
                    totalHours: taskDurationHours,
                    note: noteController.text.isNotEmpty
                        ? noteController.text
                        : null,
                  );

                  final success = taskDurationHours > widget.booking.totalHours
                      ? await widget.bookingManager.modifyOrderWithPayment(
                          context,
                          widget.booking.id,
                          orderEditRequest,
                          priceDifference)
                      : await widget.bookingManager.modifyOrder(
                          context, widget.booking.id, orderEditRequest);

                  if (success) Navigator.of(context).pop();
                  setState(() => isSubmitting = false);
                },
          child: isSubmitting
              ? const CircularProgressIndicator()
              : Text(AppLocalizations.of(context)!.submit,
                  style: AppTextStyles.text(context)
                      .copyWith(color: AppColors.primaryColor)),
        ),
      ],
    );
  }
}

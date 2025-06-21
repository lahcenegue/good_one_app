import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Features/User/Models/booking.dart';
import 'package:good_one_app/Features/User/Models/order_model.dart';
import 'package:good_one_app/Features/User/Presentation/Screens/service_evaluation_screen.dart';
import 'package:good_one_app/Providers/User/booking_manager_provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Modern, professional booking screen with beautiful design
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManagerProvider>();

    return Consumer<BookingManagerProvider>(
      builder: (context, bookingManager, child) {
        if (bookingManager.isInitializing) {
          return Scaffold(
            body: LoadingIndicator(),
          );
        }
        if (!userManager.isAuthenticated) {
          return _LoginPrompt();
        }
        if (bookingManager.tabController == null) {
          return _BookingContentInitializer();
        }
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: _buildModernAppBar(context),
          body: RefreshIndicator(
            onRefresh: () async => bookingManager.fetchBookings(),
            color: AppColors.primaryColor,
            backgroundColor: Colors.white,
            child:
                _BookingContent(tabController: bookingManager.tabController!),
          ),
        );
      },
    );
  }

  /// App bar
  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Text(
        AppLocalizations.of(context)!.booking,
        style: AppTextStyles.appBarTitle(context),
      ),
      centerTitle: true,
    );
  }
}

/// Login prompt with beautiful design
class _LoginPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(context.getWidth(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(context.getWidth(24)),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: context.getWidth(60),
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.getHeight(32)),
              Text(
                AppLocalizations.of(context)!.welcomeToYourBookings,
                style: AppTextStyles.title(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.getHeight(16)),
              Text(
                AppLocalizations.of(context)!.loginToContinue,
                style: AppTextStyles.text(context).copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.getHeight(40)),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: PrimaryButton(
                  text: AppLocalizations.of(context)!.login,
                  onPressed: () =>
                      NavigationService.navigateTo(AppRoutes.accountSelection),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Content initializer (unchanged)
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
    return Scaffold(
      body: LoadingIndicator(),
    );
  }
}

/// Booking content with enhanced design
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bookingManager =
          Provider.of<BookingManagerProvider>(context, listen: false);
      await bookingManager.initialize();
    });
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
    final bookingManager = context.watch<BookingManagerProvider>();
    return Column(
      children: [
        _TabBarSection(tabController: widget.tabController),
        Expanded(
          child: bookingManager.isLoading
              ? LoadingIndicator()
              : bookingManager.error != null
                  ? _ErrorState(error: bookingManager.error!)
                  : _BookingList(tabController: widget.tabController),
        ),
      ],
    );
  }
}

/// Modern tab bar with enhanced styling
class _TabBarSection extends StatelessWidget {
  final TabController tabController;

  const _TabBarSection({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.getAdaptiveSize(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(context.getAdaptiveSize(20)),
        ),
        dividerHeight: 0,
        labelStyle: AppTextStyles.subTitle(context),
        unselectedLabelStyle: AppTextStyles.text(context),
        labelColor: Colors.white,
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

/// Booking list with enhanced cards
class _BookingList extends StatelessWidget {
  final TabController tabController;

  const _BookingList({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final bookingManager = context.watch<BookingManagerProvider>();
    final currentTabIndex = tabController.index + 1;
    final filteredBookings = bookingManager.bookings
        .where((booking) => booking.status == currentTabIndex)
        .toList();

    return filteredBookings.isEmpty
        ? _ModernEmptyState(tabIndex: currentTabIndex)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.getWidth(16)),
            itemCount: filteredBookings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: context.getHeight(16)),
                child: ModernBookingCard(
                  booking: filteredBookings[index],
                  animationDelay: index * 100,
                ),
              );
            },
          );
  }
}

/// Modern empty state with beautiful illustration
class _ModernEmptyState extends StatelessWidget {
  final int tabIndex;

  const _ModernEmptyState({required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = _getEmptyStateContent(context, tabIndex);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.getWidth(24)),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                size: context.getWidth(80),
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: context.getHeight(24)),
            Text(
              title,
              style: AppTextStyles.title2(context).copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(12)),
            Text(
              subtitle,
              style: AppTextStyles.text(context).copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  (IconData, String, String) _getEmptyStateContent(
      BuildContext context, int tabIndex) {
    switch (tabIndex) {
      case 1: // In Progress
        return (
          Icons.schedule_rounded,
          AppLocalizations.of(context)!.noActiveBookings,
          AppLocalizations.of(context)!.noActiveBookingsMessage
        );
      case 2: // Completed
        return (
          Icons.check_circle_rounded,
          AppLocalizations.of(context)!.noCompletedBookings,
          AppLocalizations.of(context)!.noCanceledBookingsMessage
        );
      case 3: // Canceled
        return (
          Icons.cancel_rounded,
          AppLocalizations.of(context)!.noCanceledBookings,
          AppLocalizations.of(context)!.noCanceledBookingsMessage
        );
      default:
        return (
          Icons.calendar_today_rounded,
          AppLocalizations.of(context)!.noBookings,
          AppLocalizations.of(context)!.startBookingPrompt
        );
    }
  }
}

/// Modern error state
class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.getWidth(24)),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: context.getWidth(60),
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: context.getHeight(24)),
            Text(
              AppLocalizations.of(context)!.oopsSomethingWentWrong,
              style: AppTextStyles.title2(context).copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(12)),
            Text(
              error,
              style: AppTextStyles.text(context).copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(24)),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: AppLocalizations.of(context)!.retry,
                onPressed: () =>
                    context.read<BookingManagerProvider>().fetchBookings(),
                width: context.getWidth(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern booking card with enhanced design
class ModernBookingCard extends StatefulWidget {
  final Booking booking;
  final int animationDelay;

  const ModernBookingCard({
    super.key,
    required this.booking,
    this.animationDelay = 0,
  });

  @override
  State<ModernBookingCard> createState() => _ModernBookingCardState();
}

class _ModernBookingCardState extends State<ModernBookingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation with delay
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingManager = context.read<BookingManagerProvider>();
    final (statusColor, statusText, statusIcon) = _getStatusDetails(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // Status header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(context.getWidth(16)),
                  decoration: BoxDecoration(
                    color: statusColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusIcon,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: context.getWidth(8)),
                      Text(
                        statusText,
                        style: AppTextStyles.subTitle(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      if (widget.booking.status == 1)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon:
                                Icon(Icons.edit, color: Colors.white, size: 18),
                            onPressed: () => _showModifyBookingDialog(
                                context, bookingManager),
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(),
                          ),
                        ),
                      if (widget.booking.status == 2)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.rate_review,
                                color: Colors.white, size: 18),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ServiceEvaluationScreen(
                                      serviceId: widget.booking.service.id),
                                ),
                              );
                            },
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(),
                          ),
                        ),
                    ],
                  ),
                ),

                // Main content
                Padding(
                  padding: EdgeInsets.all(context.getWidth(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service and contractor info
                      _ModernContractorInfo(booking: widget.booking),
                      SizedBox(height: context.getHeight(20)),

                      // Details grid
                      _ModernDetailsGrid(booking: widget.booking),

                      // Action buttons for in-progress orders
                      if (widget.booking.status == 1) ...[
                        SizedBox(height: context.getHeight(24)),
                        _ModernActionButtons(
                          booking: widget.booking,
                          onReceive: () => _showReceiveConfirmationDialog(
                              context, bookingManager, widget.booking.id),
                          onCancel: () => _showCancelConfirmationDialog(
                              context, bookingManager),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, String, IconData) _getStatusDetails(BuildContext context) {
    switch (widget.booking.status) {
      case 1:
        return (
          Colors.orange,
          AppLocalizations.of(context)!.inProgress,
          Icons.access_time
        );
      case 2:
        return (
          Colors.green,
          AppLocalizations.of(context)!.completed,
          Icons.check_circle
        );
      case 3:
        return (
          Colors.red,
          AppLocalizations.of(context)!.canceled,
          Icons.cancel
        );
      default:
        return (
          Colors.grey,
          AppLocalizations.of(context)!.unknownStatus,
          Icons.help
        );
    }
  }

  // ... (continue with dialog methods - same as before)
  void _showModifyBookingDialog(
      BuildContext context, BookingManagerProvider bookingManager) {
    showDialog(
      context: context,
      builder: (_) => _ModifyBookingDialog(
          booking: widget.booking, bookingManager: bookingManager),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              style: AppTextStyles.text(context).copyWith(color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () async {
                await bookingManager.receiveOrder(
                    context, dialogContext, bookingId);
                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                AppLocalizations.of(context)!.confirm,
                style:
                    AppTextStyles.text(context).copyWith(color: Colors.white),
              ),
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
          booking: widget.booking, bookingManager: bookingManager),
    );
  }
}

/// Modern contractor info section
class _ModernContractorInfo extends StatelessWidget {
  final Booking booking;

  const _ModernContractorInfo({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          picture: booking.service.picture,
          size: context.getWidth(60),
        ),
        SizedBox(width: context.getWidth(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.service.fullName,
                style: AppTextStyles.title2(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.getHeight(4)),
              Text(
                booking.service.subcategory.name,
                style: AppTextStyles.text(context).copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.getHeight(4)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(8),
                  vertical: context.getHeight(4),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.service.service,
                  style: AppTextStyles.text(context).copyWith(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Modern details grid
class _ModernDetailsGrid extends StatelessWidget {
  final Booking booking;

  const _ModernDetailsGrid({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ModernDetailItem(
                icon: Icons.location_on_rounded,
                label: AppLocalizations.of(context)!.location,
                value: booking.location,
                color: Colors.red,
              ),
            ),
            SizedBox(width: context.getWidth(12)),
            Expanded(
              child: _ModernDetailItem(
                icon: Icons.schedule_rounded,
                label: AppLocalizations.of(context)!.time,
                value:
                    '${booking.formattedStartDate}\n${booking.formattedStartTime}',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(12)),
        Row(
          children: [
            Expanded(
              child: _ModernDetailItem(
                icon: Icons.timer_rounded,
                label: AppLocalizations.of(context)!.duration,
                value: booking.getFormattedDuration(context),
                color: Colors.orange,
              ),
            ),
            SizedBox(width: context.getWidth(12)),
            Expanded(
              child: _ModernDetailItem(
                icon: Icons.attach_money_rounded,
                label: AppLocalizations.of(context)!.price,
                value: booking.getServiceRateDisplay(context),
                color: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(12)),
        _ModernDetailItem(
          icon: Icons.receipt_rounded,
          label: AppLocalizations.of(context)!.total,
          value: '\$${booking.price.toStringAsFixed(2)}',
          color: AppColors.primaryColor,
          isHighlighted: true,
        ),
        // Show pricing type for new orders
        if (booking.service.pricingType != null) ...[
          SizedBox(height: context.getHeight(12)),
          _ModernDetailItem(
            icon: _getPricingIcon(booking.service.pricingType!),
            label: AppLocalizations.of(context)!.pricingType,
            value:
                _getPricingTypeDisplay(context, booking.service.pricingType!),
            color: Colors.purple,
          ),
        ],
      ],
    );
  }

  IconData _getPricingIcon(String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return Icons.access_time_rounded;
      case 'daily':
        return Icons.calendar_today_rounded;
      case 'fixed':
        return Icons.local_offer_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getPricingTypeDisplay(BuildContext context, String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return AppLocalizations.of(context)!.hourly;
      case 'daily':
        return AppLocalizations.of(context)!.daily;
      case 'fixed':
        return AppLocalizations.of(context)!.fixed;
      default:
        return pricingType;
    }
  }
}

/// Modern detail item with icon and styling
class _ModernDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isHighlighted;

  const _ModernDetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(12)),
      decoration: BoxDecoration(
        color:
            isHighlighted ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              SizedBox(width: context.getWidth(8)),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.text(context).copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(8)),
          Text(
            value,
            style: AppTextStyles.text(context).copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: isHighlighted ? color : Colors.grey.shade800,
              fontSize: isHighlighted ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern action buttons with enhanced styling
class _ModernActionButtons extends StatelessWidget {
  final Booking booking;
  final VoidCallback onReceive;
  final VoidCallback onCancel;

  const _ModernActionButtons({
    required this.booking,
    required this.onReceive,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onReceive,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: context.getHeight(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: context.getWidth(8)),
                      Text(
                        AppLocalizations.of(context)!.completed,
                        style: AppTextStyles.text(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: context.getWidth(12)),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onCancel,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: context.getHeight(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_rounded, color: Colors.red, size: 18),
                      SizedBox(width: context.getWidth(8)),
                      Text(
                        AppLocalizations.of(context)!.cancel,
                        style: AppTextStyles.text(context).copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern cancel confirmation dialog
class _CancelConfirmationDialog extends StatelessWidget {
  final Booking booking;
  final BookingManagerProvider bookingManager;

  const _CancelConfirmationDialog({
    required this.booking,
    required this.bookingManager,
  });

  @override
  Widget build(BuildContext context) {
    final reasonController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(context.getWidth(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Container(
              padding: EdgeInsets.all(context.getWidth(16)),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.warning_rounded,
                size: context.getWidth(40),
                color: Colors.red,
              ),
            ),
            SizedBox(height: context.getHeight(20)),

            Text(
              AppLocalizations.of(context)!.cancelBooking,
              style: AppTextStyles.title2(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.getHeight(16)),

            Text(
              AppLocalizations.of(context)!.reasonForCancellation,
              style: AppTextStyles.text(context).copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: context.getHeight(16)),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade50,
              ),
              child: TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.enterReason,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(context.getWidth(16)),
                ),
              ),
            ),
            SizedBox(height: context.getHeight(24)),

            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        AppLocalizations.of(context)!.close,
                        style: AppTextStyles.text(context).copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.getWidth(12)),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final reason = reasonController.text.trim();
                        if (reason.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  AppLocalizations.of(context)!.reasonRequired),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        await bookingManager.cancelOrder(
                            context, booking.id, reason);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.submit,
                        style: AppTextStyles.text(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Use the existing _ModifyBookingDialog from previous implementation
class _ModifyBookingDialog extends StatefulWidget {
  final Booking booking;
  final BookingManagerProvider bookingManager;

  const _ModifyBookingDialog({
    required this.booking,
    required this.bookingManager,
  });

  @override
  State<_ModifyBookingDialog> createState() => _ModifyBookingDialogState();
}

class _ModifyBookingDialogState extends State<_ModifyBookingDialog> {
  late TextEditingController locationController;
  late TextEditingController noteController;
  late TextEditingController durationController;
  late DateTime selectedDay;
  late String selectedTime;
  late double durationValue;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    locationController = TextEditingController(text: widget.booking.location);
    noteController = TextEditingController();

    durationValue =
        widget.booking.durationValue ?? widget.booking.totalHours.toDouble();
    durationController = TextEditingController(
        text: durationValue == durationValue.toInt()
            ? durationValue.toInt().toString()
            : durationValue.toString());

    selectedDay =
        DateTime.fromMillisecondsSinceEpoch(widget.booking.startAt * 1000);
    selectedTime = DateFormat('HH:mm').format(
        DateTime.fromMillisecondsSinceEpoch(widget.booking.startAt * 1000));
  }

  @override
  void dispose() {
    locationController.dispose();
    noteController.dispose();
    durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicePricingType = widget.booking.service.pricingType ??
        widget.booking.pricingType ??
        'hourly';

    // Calculate price difference for additional payment
    double priceDifference = 0.0;
    if (servicePricingType != 'fixed') {
      final originalDuration =
          widget.booking.durationValue ?? widget.booking.totalHours.toDouble();
      if (durationValue > originalDuration) {
        final additionalDuration = durationValue - originalDuration;
        final ratePerUnit = _getServiceRate(servicePricingType);
        priceDifference = additionalDuration * ratePerUnit;
      }
    }

    final firstDate = DateTime.now();
    final initialDate =
        selectedDay.isBefore(firstDate) ? firstDate : selectedDay;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(maxHeight: context.getHeight(600)),
        padding: EdgeInsets.all(context.getWidth(24)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: context.getWidth(12)),
                  Text(
                    AppLocalizations.of(context)!.modifyBooking,
                    style: AppTextStyles.title2(context),
                  ),
                ],
              ),
              SizedBox(height: context.getHeight(16)),
              // Location
              Text(AppLocalizations.of(context)!.location,
                  style: AppTextStyles.text(context)),
              SizedBox(height: context.getHeight(5)),
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
              SizedBox(height: context.getHeight(12)),
              // Start Date
              Text(AppLocalizations.of(context)!.startDate,
                  style: AppTextStyles.text(context)),
              SizedBox(height: context.getHeight(5)),
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
              SizedBox(height: context.getHeight(12)),

              // Start Time
              Text(AppLocalizations.of(context)!.startTime,
                  style: AppTextStyles.text(context)),
              SizedBox(height: context.getHeight(5)),
              DropdownButtonFormField<String>(
                value: selectedTime,
                items: widget.bookingManager.availableTimeSlots
                    .map((time) =>
                        DropdownMenuItem(value: time, child: Text(time)))
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => selectedTime = newValue!),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              SizedBox(height: context.getHeight(12)),

              // Duration (only for non-fixed pricing)
              if (servicePricingType != 'fixed') ...[
                Text(_getDurationLabel(context, servicePricingType),
                    style: AppTextStyles.text(context)),
                SizedBox(height: context.getHeight(5)),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: _getDurationHint(context, servicePricingType),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    suffixText: _getDurationUnit(context, servicePricingType),
                  ),
                  onChanged: (value) {
                    final parsedValue = double.tryParse(value);
                    if (parsedValue != null && parsedValue >= 0) {
                      setState(() => durationValue = parsedValue);
                    }
                  },
                ),
                SizedBox(height: context.getHeight(12)),
              ],

              // Note
              Text(AppLocalizations.of(context)!.note,
                  style: AppTextStyles.text(context)),
              SizedBox(height: context.getHeight(5)),
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

              // Additional payment info
              if (priceDifference > 0) ...[
                SizedBox(height: context.getHeight(16)),
                Container(
                  padding: EdgeInsets.all(context.getWidth(12)),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payment, color: Colors.orange, size: 20),
                          SizedBox(width: context.getWidth(8)),
                          Text(
                            AppLocalizations.of(context)!
                                .additionalPaymentRequired,
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.getHeight(8)),
                      Text(
                        '${AppLocalizations.of(context)!.additional} ${_getDurationUnit(context, servicePricingType)}: ${(durationValue - (widget.booking.durationValue ?? widget.booking.totalHours.toDouble())).toStringAsFixed(servicePricingType == 'hourly' ? 1 : 0)}',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                      Text(
                        '${AppLocalizations.of(context)!.additionalCostLabel} \$${priceDifference.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: context.getHeight(16)),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          AppLocalizations.of(context)!.close,
                          style: AppTextStyles.text(context).copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.getWidth(12)),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: isSubmitting
                            ? null
                            : () => _submitModification(
                                context, servicePricingType, priceDifference),
                        child: isSubmitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                AppLocalizations.of(context)!.submit,
                                style: AppTextStyles.text(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getServiceRate(String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return widget.booking.service.costPerHour;
      case 'daily':
        return widget.booking.service.costPerDay ?? 0.0;
      case 'fixed':
        return widget.booking.service.fixedPrice ?? 0.0;
      default:
        return widget.booking.service.costPerHour;
    }
  }

  String _getDurationLabel(BuildContext context, String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return AppLocalizations.of(context)!.enterHours;
      case 'daily':
        return AppLocalizations.of(context)!.enterDays;
      default:
        return AppLocalizations.of(context)!.duration;
    }
  }

  String _getDurationHint(BuildContext context, String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return 'e.g. 2.5';
      case 'daily':
        return 'e.g. 3';
      default:
        return '';
    }
  }

  String _getDurationUnit(BuildContext context, String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return AppLocalizations.of(context)!.hours;
      case 'daily':
        return AppLocalizations.of(context)!.days;
      default:
        return '';
    }
  }

  Future<void> _submitModification(BuildContext context,
      String servicePricingType, double priceDifference) async {
    setState(() => isSubmitting = true);

    final now = DateTime.now();
    final startDateTime = DateTime(selectedDay.year, selectedDay.month,
        selectedDay.day, int.parse(selectedTime.split(':')[0]), 0);

    // Validation
    if (!startDateTime.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.startTimeFuture)));
      setState(() => isSubmitting = false);
      return;
    }

    // Calculate total hours for time validation
    int totalHours = 1;
    switch (servicePricingType) {
      case 'hourly':
        totalHours = durationValue.ceil();
        break;
      case 'daily':
        totalHours = (durationValue * 8).ceil(); // 8 hours per day
        break;
      case 'fixed':
        totalHours = 1;
        break;
    }

    final endDateTime = startDateTime.add(Duration(hours: totalHours));
    if (endDateTime.hour > 22 || endDateTime.hour < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.endTimeBetween)));
      setState(() => isSubmitting = false);
      return;
    }

    final newTimestamp =
        widget.bookingManager.getTimestamp(selectedDay, selectedTime);
    final orderEditRequest = OrderEditRequest(
      orderId: widget.booking.id,
      location:
          locationController.text.isNotEmpty ? locationController.text : null,
      startAt: newTimestamp,
      durationValue: servicePricingType != 'fixed'
          ? durationValue
          : null, // Use durationValue instead of totalHours
      note: noteController.text.isNotEmpty ? noteController.text : null,
    );

    final success = priceDifference > 0
        ? await widget.bookingManager.modifyOrderWithPayment(
            context, widget.booking.id, orderEditRequest, priceDifference)
        : await widget.bookingManager
            .modifyOrder(context, widget.booking.id, orderEditRequest);

    if (success && mounted) {
      Navigator.of(context).pop();
    }

    if (mounted) {
      setState(() => isSubmitting = false);
    }
  }
}

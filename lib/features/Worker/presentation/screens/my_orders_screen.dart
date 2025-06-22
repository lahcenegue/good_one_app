import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Features/Worker/Models/my_order_model.dart';
import 'package:good_one_app/Features/Worker/Presentation/Screens/order_details_page.dart';
import 'package:good_one_app/Providers/Worker/orders_manager_provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersManagerProvider>(
      builder: (context, orderManager, _) {
        if (orderManager.isOrdersLoading) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: LoadingIndicator(),
          );
        }

        if (orderManager.error != null) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: _buildAppBar(context),
            body: _buildErrorState(context, orderManager),
          );
        }

        if (orderManager.tabController == null) {
          return ModernOrdersContentInitializer();
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: _buildAppBar(context),
          body: RefreshIndicator(
            onRefresh: () => orderManager.fetchOrders(),
            color: AppColors.primaryColor,
            backgroundColor: Colors.white,
            child:
                ModernOrdersContent(tabController: orderManager.tabController!),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        AppLocalizations.of(context)!.myOrders,
        style: AppTextStyles.appBarTitle(context).copyWith(),
      ),
      centerTitle: true,
    );
  }

  Widget _buildErrorState(
      BuildContext context, OrdersManagerProvider ordersManager) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(context.getAdaptiveSize(32)),
        margin: EdgeInsets.all(context.getAdaptiveSize(24)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.getAdaptiveSize(16)),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: context.getAdaptiveSize(48),
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: context.getHeight(20)),
            Text(
              AppLocalizations.of(context)!.oopsSomethingWentWrong,
              style: AppTextStyles.title2(context).copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(12)),
            Text(
              AppLocalizations.of(context)!.somethingWentWrong,
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
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ordersManager.fetchOrders();
                },
                icon: Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context)!.tryAgain,
                  style: AppTextStyles.subTitle(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.getWidth(24),
                    vertical: context.getHeight(12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernOrdersContentInitializer extends StatefulWidget {
  const ModernOrdersContentInitializer({super.key});

  @override
  State<ModernOrdersContentInitializer> createState() =>
      _ModernOrdersContentInitializerState();
}

class _ModernOrdersContentInitializerState
    extends State<ModernOrdersContentInitializer>
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)!.myOrders,
          style: AppTextStyles.appBarTitle(context).copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildModernEmptyState(context),
    );
  }

  Widget _buildModernEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(context.getAdaptiveSize(32)),
        margin: EdgeInsets.all(context.getAdaptiveSize(24)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.getAdaptiveSize(20)),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: context.getAdaptiveSize(64),
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: context.getHeight(24)),
            Text(
              AppLocalizations.of(context)!.noOrdersYet,
              style: AppTextStyles.title2(context).copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: context.getHeight(12)),
            Text(
              AppLocalizations.of(context)!.noOrdersAvailable,
              style: AppTextStyles.text(context).copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.getHeight(8)),
            Text(
              AppLocalizations.of(context)!.ordersFromCustomersWillAppear,
              style: AppTextStyles.text(context).copyWith(
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ModernOrdersContent extends StatefulWidget {
  final TabController tabController;

  const ModernOrdersContent({
    super.key,
    required this.tabController,
  });

  @override
  State<ModernOrdersContent> createState() => _ModernOrdersContentState();
}

class _ModernOrdersContentState extends State<ModernOrdersContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_handleTabChange);

    // Initialize animations
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
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation
    _animationController.forward();
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersManager = context.watch<OrdersManagerProvider>();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildModernTabBar(context, ordersManager),
          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: TabBarView(
                controller: widget.tabController,
                physics: const BouncingScrollPhysics(),
                children: ordersManager.dates.map((date) {
                  return _buildModernOrdersList(
                      context, ordersManager.orders[date] ?? [], date);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTabBar(
    BuildContext context,
    OrdersManagerProvider ordersManager,
  ) {
    return Container(
      margin: EdgeInsets.all(context.getAdaptiveSize(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: context.getHeight(50),
        child: TabBar(
          controller: ordersManager.tabController,
          isScrollable: true,
          indicatorWeight: 0,
          indicator: BoxDecoration(),
          dividerColor: Colors.transparent,
          labelPadding: EdgeInsets.symmetric(horizontal: context.getWidth(4)),
          tabs: ordersManager.dates.map((date) {
            final dateTime = DateTime.parse(date);
            final dayOfWeek = DateFormat('EEE').format(dateTime);
            final dayOfMonth = DateFormat('d').format(dateTime);

            // Only show count for incomplete orders (status 1)
            final incompleteCount =
                ordersManager.getIncompleteOrdersCount(date);

            return Tab(
              height: context.getHeight(45),
              child: Builder(
                builder: (BuildContext context) {
                  final isSelected = ordersManager.tabController!.index ==
                      ordersManager.dates.indexOf(date);

                  return Container(
                    width: context.getWidth(60),
                    height: context.getHeight(40),
                    margin:
                        EdgeInsets.symmetric(horizontal: context.getWidth(2)),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                AppColors.primaryColor,
                                AppColors.primaryColor.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade200),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Main content
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dayOfWeek,
                                style: AppTextStyles.withColor(
                                  AppTextStyles.captionMedium(context),
                                  isSelected
                                      ? AppColors.whiteText
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                dayOfMonth,
                                style: AppTextStyles.withColor(
                                  AppTextStyles.bodyTextBold(context),
                                  isSelected
                                      ? AppColors.whiteText
                                      : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Only show badge for incomplete orders
                        if (incompleteCount > 0)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(7),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primaryColor, width: 1)
                                    : null,
                              ),
                              child: Text(
                                '$incompleteCount',
                                style: AppTextStyles.withColor(
                                  AppTextStyles.withSize(
                                      AppTextStyles.captionMedium(context), 8),
                                  isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.whiteText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModernOrdersList(
    BuildContext context,
    List<MyOrderModel> orders,
    String date,
  ) {
    final ordersManager = context.read<OrdersManagerProvider>();

    if (orders.isEmpty) {
      return _buildEmptyDateState(context, date);
    }

    return RefreshIndicator(
      onRefresh: () => ordersManager.fetchOrders(),
      color: AppColors.primaryColor,
      backgroundColor: Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(context.getAdaptiveSize(16)),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: context.getHeight(16)),
            child: ModernOrderCard(
              order: orders[index],
              animationDelay: index * 100,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderDetailsPage(order: orders[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyDateState(BuildContext context, String date) {
    final dateTime = DateTime.parse(date);
    final formattedDate = DateFormat('EEEE, MMM d').format(dateTime);

    return Center(
      child: Container(
        padding: EdgeInsets.all(context.getAdaptiveSize(32)),
        margin: EdgeInsets.all(context.getAdaptiveSize(24)),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.getAdaptiveSize(16)),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: context.getAdaptiveSize(48),
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: context.getHeight(20)),
            Text(
              AppLocalizations.of(context)!.noOrders,
              style: AppTextStyles.title2(context).copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: context.getHeight(8)),
            Text(
              '${AppLocalizations.of(context)!.noOrdersScheduledFor} $formattedDate',
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
}

class ModernOrderCard extends StatefulWidget {
  final MyOrderModel order;
  final int animationDelay;
  final VoidCallback onTap;

  const ModernOrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<ModernOrderCard> createState() => _ModernOrderCardState();
}

class _ModernOrderCardState extends State<ModernOrderCard>
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
    final ordersManager = context.read<OrdersManagerProvider>();
    final (statusColor, statusText, statusIcon) =
        _getStatusDetails(context, ordersManager);

    // Check if this is an incomplete order for priority styling
    final isIncomplete = widget.order.status == 1;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isIncomplete
                  ? Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isIncomplete
                      ? AppColors.primaryColor.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  blurRadius: isIncomplete ? 20 : 15,
                  offset: Offset(0, isIncomplete ? 12 : 8),
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
                      ],
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: EdgeInsets.all(context.getWidth(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer info
                        _ModernCustomerInfo(order: widget.order),
                        SizedBox(height: context.getHeight(20)),

                        // Order details grid
                        _ModernOrderDetailsGrid(order: widget.order),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, String, IconData) _getStatusDetails(
      BuildContext context, OrdersManagerProvider ordersManager) {
    final statusColor = ordersManager.getStatusColor(widget.order.status);
    final statusText =
        ordersManager.getStatusText(context, widget.order.status);

    IconData statusIcon;
    switch (widget.order.status) {
      case 1: // In Progress
        statusIcon = Icons.access_time;
        break;
      case 2: // Completed
        statusIcon = Icons.check_circle;
        break;
      case 3: // Cancelled
        statusIcon = Icons.cancel;
        break;
      default:
        statusIcon = Icons.help;
        break;
    }

    return (statusColor, statusText, statusIcon);
  }
}

/// Modern customer info section
class _ModernCustomerInfo extends StatelessWidget {
  final MyOrderModel order;

  const _ModernCustomerInfo({required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          picture: order.user.picture,
          size: context.getWidth(60),
        ),
        SizedBox(width: context.getWidth(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.user.fullName,
                style: AppTextStyles.title2(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.getHeight(4)),
              Text(
                order.service,
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
                  color: _getPricingTypeColor(order.pricingType)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getPricingTypeColor(order.pricingType)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  order.getPriceDisplay(),
                  style: AppTextStyles.text(context).copyWith(
                    color: _getPricingTypeColor(order.pricingType),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getPricingTypeColor(String? pricingType) {
    switch (pricingType) {
      case 'hourly':
        return Colors.blue;
      case 'daily':
        return Colors.green;
      case 'fixed':
        return Colors.orange;
      default:
        return AppColors.primaryColor;
    }
  }
}

/// Modern order details grid
class _ModernOrderDetailsGrid extends StatelessWidget {
  final MyOrderModel order;

  const _ModernOrderDetailsGrid({required this.order});

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
                value: order.location,
                color: Colors.red,
              ),
            ),
            SizedBox(width: context.getWidth(12)),
            Expanded(
              child: _ModernDetailItem(
                icon: Icons.schedule_rounded,
                label: AppLocalizations.of(context)!.startTime,
                value: _formatTimestamp(order.startAt),
                color: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(12)),
        _ModernDetailItem(
          icon: Icons.receipt_rounded,
          label: AppLocalizations.of(context)!.totalAmount,
          value: '\$${order.totalPrice.toStringAsFixed(2)}',
          color: AppColors.primaryColor,
          isHighlighted: true,
        ),
      ],
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

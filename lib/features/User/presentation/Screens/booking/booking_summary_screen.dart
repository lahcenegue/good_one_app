import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Providers/User/booking_manager_provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserManagerProvider, BookingManagerProvider>(
      builder: (context, userManager, bookingManager, _) {
        if (userManager.selectedContractor == null) {
          return _buildNoContractorSelected(context);
        }

        final service = userManager.selectedContractor!;
        final servicePricingType = service.pricingType ?? 'hourly';

        // Get the appropriate cost based on pricing type
        double serviceCost = bookingManager.getServiceCost(service);

        final basePrice = bookingManager.basePrice(serviceCost);
        final effectivePrice = bookingManager.effectivePrice(serviceCost);
        final finalPrice = bookingManager.finalPrice(serviceCost);

        return Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(
            context,
            bookingManager,
            service,
            servicePricingType,
            basePrice,
            effectivePrice,
            finalPrice,
          ),
        );
      },
    );
  }

  /// Builds the app bar with a localized title.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        AppLocalizations.of(context)!.bookingSummary,
        style: AppTextStyles.appBarTitle(context),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  /// Displays a message when no contractor is selected.
  Widget _buildNoContractorSelected(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Text(AppLocalizations.of(context)!.noContractorSelected),
      ),
    );
  }

  /// Builds the main content of the screen.
  Widget _buildBody(
    BuildContext context,
    BookingManagerProvider bookingManager,
    dynamic service,
    String servicePricingType,
    double basePrice,
    double effectivePrice,
    double finalPrice,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContractorInfo(context, service),
            SizedBox(height: context.getHeight(24)),
            _buildBookingDetails(context, bookingManager, servicePricingType),
            SizedBox(height: context.getHeight(24)),
            _buildLocationDetails(context, bookingManager),
            SizedBox(height: context.getHeight(24)),
            _buildOffersSection(context, bookingManager),
            SizedBox(height: context.getHeight(24)),
            _buildPricingSummary(
              context,
              bookingManager,
              service,
              servicePricingType,
              basePrice,
              effectivePrice,
              finalPrice,
            ),
            SizedBox(height: context.getHeight(32)),
            _buildConfirmButton(context, bookingManager, service),
          ],
        ),
      ),
    );
  }

  /// Displays contractor information with modern design
  Widget _buildContractorInfo(
    BuildContext context,
    dynamic service,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(20)),
        child: Row(
          children: [
            UserAvatar(
              picture: service.picture,
              size: context.getWidth(70),
            ),
            SizedBox(width: context.getWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.fullName ?? 'Service Provider',
                    style: AppTextStyles.title2(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.getHeight(4)),
                  Text(
                    service.service ?? 'Service',
                    style: AppTextStyles.text(context),
                  ),
                  Text(
                    service.subcategory.name ?? 'Service',
                    style: AppTextStyles.text(context).copyWith(
                      fontSize: context.getAdaptiveSize(13),
                    ),
                  ),
                  SizedBox(height: context.getHeight(8)),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: context.getWidth(16),
                      ),
                      SizedBox(width: context.getWidth(4)),
                      Text(
                        service.rating?.rating?.toStringAsFixed(1) ?? '0.0',
                        style: AppTextStyles.text(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: context.getWidth(8)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.getWidth(8),
                          vertical: context.getHeight(2),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service.displayPrice?.displayText,
                          style: AppTextStyles.withColor(
                            AppTextStyles.withSize(
                                AppTextStyles.bodyTextMedium(context),
                                context.getAdaptiveSize(14)),
                            AppColors.whiteText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays booking details with pricing type awareness
  Widget _buildBookingDetails(
    BuildContext context,
    BookingManagerProvider bookingManager,
    String servicePricingType,
  ) {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: context.getWidth(12)),
                Text(
                  AppLocalizations.of(context)!.bookingDetails,
                  style: AppTextStyles.title2(context),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(16)),
            _buildDetailRow(
              context,
              Icons.calendar_today,
              AppLocalizations.of(context)!.date,
              bookingManager.formattedDateTime,
            ),
            SizedBox(height: context.getHeight(12)),
            _buildDetailRow(
              context,
              Icons.access_time,
              AppLocalizations.of(context)!.startTime,
              bookingManager.selectedTime,
            ),
            // Show duration only for non-fixed pricing
            if (servicePricingType != 'fixed') ...[
              SizedBox(height: context.getHeight(12)),
              _buildDetailRow(
                context,
                Icons.timer,
                AppLocalizations.of(context)!.duration,
                _formatDuration(context, bookingManager, servicePricingType),
              ),
            ],
            // Show service type
            SizedBox(height: context.getHeight(12)),
            _buildDetailRow(
              context,
              _getPricingIcon(servicePricingType),
              AppLocalizations.of(context)!.pricingType,
              _getPricingTypeDisplay(context, servicePricingType),
            ),
          ],
        ),
      ),
    );
  }

  /// Format duration based on pricing type
  String _formatDuration(BuildContext context,
      BookingManagerProvider bookingManager, String pricingType) {
    final value = bookingManager.durationValue;
    switch (pricingType) {
      case 'hourly':
        return '${value == value.toInt() ? value.toInt() : value} ${value == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}';
      case 'daily':
        return '${value == value.toInt() ? value.toInt() : value} ${value == 1 ? AppLocalizations.of(context)!.day : AppLocalizations.of(context)!.days}';
      case 'fixed':
        return AppLocalizations.of(context)!.fixedPrice;
      default:
        return '${bookingManager.taskDurationHours} ${bookingManager.taskDurationHours == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}';
    }
  }

  /// Get pricing type display text
  String _getPricingTypeDisplay(BuildContext context, String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return AppLocalizations.of(context)!.hourly;
      case 'daily':
        return AppLocalizations.of(context)!.daily;
      case 'fixed':
        return AppLocalizations.of(context)!.fixed;
      default:
        return AppLocalizations.of(context)!.hourly;
    }
  }

  /// Get pricing icon
  IconData _getPricingIcon(String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return Icons.access_time;
      case 'daily':
        return Icons.calendar_today;
      case 'fixed':
        return Icons.attach_money;
      default:
        return Icons.info;
    }
  }

  /// Displays location details with modern design
  Widget _buildLocationDetails(
    BuildContext context,
    BookingManagerProvider bookingManager,
  ) {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: context.getWidth(12)),
                Text(
                  AppLocalizations.of(context)!.location,
                  style: AppTextStyles.title2(context),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(12)),
            Text(
              bookingManager.locationAddress.isNotEmpty
                  ? bookingManager.locationAddress
                  : AppLocalizations.of(context)!.noLocationSpecified,
              style: AppTextStyles.text(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles coupon application UI with modern design
  Widget _buildOffersSection(
    BuildContext context,
    BookingManagerProvider bookingManager,
  ) {
    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: context.getWidth(12)),
                Text(
                  AppLocalizations.of(context)!.couponsAndOffers,
                  style: AppTextStyles.title2(context),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(16)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3)),
                      color: Colors.grey.shade50,
                    ),
                    child: TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.typeCouponCodeHere,
                        hintStyle: AppTextStyles.hintText(context),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: context.getWidth(16),
                          vertical: context.getHeight(14),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.getWidth(12)),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withValues(alpha: 0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: bookingManager.isLoading
                          ? null
                          : () => _applyCoupon(context, bookingManager),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.getWidth(20),
                          vertical: context.getHeight(14),
                        ),
                        child: bookingManager.isLoading
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
                                AppLocalizations.of(context)!.apply,
                                style: AppTextStyles.buttonTextMedium(context),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (bookingManager.couponError != null)
              Padding(
                padding: EdgeInsets.only(top: context.getHeight(12)),
                child: Container(
                  padding: EdgeInsets.all(context.getWidth(12)),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 18),
                      SizedBox(width: context.getWidth(8)),
                      Expanded(
                        child: Text(
                          bookingManager.couponError!,
                          style: TextStyle(
                              color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (bookingManager.appliedCoupon != null)
              Padding(
                padding: EdgeInsets.only(top: context.getHeight(12)),
                child: Container(
                  padding: EdgeInsets.all(context.getWidth(12)),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.successColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: AppColors.successColor, size: 18),
                      SizedBox(width: context.getWidth(8)),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.couponApplied(
                              bookingManager.appliedCoupon!,
                              (bookingManager.discountPercentage! * 100)
                                  .toStringAsFixed(0)),
                          style: AppTextStyles.withColor(
                            AppTextStyles.withSize(
                                AppTextStyles.bodyText(context), 13),
                            AppColors.successDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Applies a coupon using the provider.
  void _applyCoupon(
      BuildContext context, BookingManagerProvider bookingManager) {
    final couponCode = _couponController.text.trim();
    bookingManager.applyCoupon(couponCode, context);
  }

  /// Displays the pricing summary with support for all pricing types
  Widget _buildPricingSummary(
    BuildContext context,
    BookingManagerProvider bookingManager,
    dynamic service,
    String servicePricingType,
    double basePrice,
    double effectivePrice,
    double finalPrice,
  ) {
    final taxInfo = bookingManager.taxInfo;

    // Calculate individual components for display
    final discountAmount = bookingManager.discountPercentage != null
        ? basePrice * bookingManager.discountPercentage!
        : 0.0;
    final taxAmount =
        taxInfo != null ? effectivePrice * (taxInfo.regionTaxes / 100) : 0.0;
    final platformFeePercentageAmount =
        taxInfo != null && taxInfo.platformFeesPercentage != 0
            ? effectivePrice * (taxInfo.platformFeesPercentage / 100)
            : 0.0;
    final platformFeeFixed = taxInfo?.platformFees ?? 0.0;

    return Container(
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
      child: Padding(
        padding: EdgeInsets.all(context.getWidth(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: context.getWidth(12)),
                Text(
                  AppLocalizations.of(context)!.priceSummary,
                  style: AppTextStyles.title2(context),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(16)),

            // Service rate based on pricing type
            _buildPriceRow(
              context,
              _getServiceRateLabel(context, servicePricingType),
              _getServiceRateValue(context, service, servicePricingType),
            ),

            // Duration (only for non-fixed pricing)
            if (servicePricingType != 'fixed') ...[
              SizedBox(height: context.getHeight(8)),
              _buildPriceRow(
                context,
                AppLocalizations.of(context)!.duration,
                _formatDuration(context, bookingManager, servicePricingType),
              ),
            ],

            SizedBox(height: context.getHeight(8)),
            _buildPriceRow(
              context,
              AppLocalizations.of(context)!.subtotal,
              '\$${basePrice.toStringAsFixed(2)}',
            ),

            if (bookingManager.discountPercentage != null) ...[
              SizedBox(height: context.getHeight(8)),
              _buildPriceRow(
                context,
                AppLocalizations.of(context)!.discount,
                '-\$${discountAmount.toStringAsFixed(2)} (${(bookingManager.discountPercentage! * 100).toStringAsFixed(0)}%)',
                textColor: Colors.green,
              ),
            ],

            if (taxInfo != null) ...[
              SizedBox(height: context.getHeight(8)),
              _buildPriceRow(
                context,
                '${AppLocalizations.of(context)!.regionTaxes} (${taxInfo.regionTaxes}%)',
                '\$${taxAmount.toStringAsFixed(2)}',
              ),
              if (taxInfo.platformFeesPercentage != 0) ...[
                SizedBox(height: context.getHeight(8)),
                _buildPriceRow(
                  context,
                  '${AppLocalizations.of(context)!.platformFee} (${taxInfo.platformFeesPercentage}%)',
                  '\$${platformFeePercentageAmount.toStringAsFixed(2)}',
                ),
              ],
              if (taxInfo.platformFees != 0) ...[
                SizedBox(height: context.getHeight(8)),
                _buildPriceRow(
                  context,
                  AppLocalizations.of(context)!.platformFee,
                  '\$${platformFeeFixed.toStringAsFixed(2)}',
                ),
              ],
            ],

            Padding(
              padding: EdgeInsets.symmetric(vertical: context.getHeight(12)),
              child: Divider(color: Colors.grey.shade300),
            ),

            _buildPriceRow(
              context,
              AppLocalizations.of(context)!.totalAmount,
              '\$${finalPrice.toStringAsFixed(2)}',
              titleStyle: AppTextStyles.title2(context)
                  .copyWith(fontWeight: FontWeight.bold),
              valueStyle: AppTextStyles.title2(context).copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get service rate label based on pricing type
  String _getServiceRateLabel(BuildContext context, String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return AppLocalizations.of(context)!.hourlyRate;
      case 'daily':
        return '${AppLocalizations.of(context)!.daily} ${AppLocalizations.of(context)!.serviceRate}';
      case 'fixed':
        return AppLocalizations.of(context)!.fixedPrice;
      default:
        return AppLocalizations.of(context)!.serviceRate;
    }
  }

  /// Get service rate value based on pricing type
  String _getServiceRateValue(
      BuildContext context, dynamic service, String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return '\$${service.costPerHour}/${AppLocalizations.of(context)!.hour}';
      case 'daily':
        return '\$${service.costPerDay}/${AppLocalizations.of(context)!.day}';
      case 'fixed':
        return '\$${service.fixedPrice}';
      default:
        return '\$${service.costPerHour ?? 0}/${AppLocalizations.of(context)!.hour}';
    }
  }

  /// Reusable price row widget with modern styling
  Widget _buildPriceRow(
    BuildContext context,
    String title,
    String value, {
    TextStyle? titleStyle,
    TextStyle? valueStyle,
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: titleStyle ?? AppTextStyles.text(context),
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              AppTextStyles.text(context).copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  /// Reusable detail row widget with modern styling
  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: context.getWidth(20),
        ),
        SizedBox(width: context.getWidth(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.text(context).copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: context.getHeight(2)),
              Text(
                value,
                style: AppTextStyles.text(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the confirm button with modern styling
  Widget _buildConfirmButton(
    BuildContext context,
    BookingManagerProvider bookingManager,
    dynamic service,
  ) {
    final serviceCost = bookingManager.getServiceCost(service);

    return PrimaryButton(
      text: AppLocalizations.of(context)!.confirm,
      onPressed:
          (bookingManager.isPaymentProcessing || bookingManager.isLoading)
              ? () {}
              : () async {
                  final success = await bookingManager.createOrder(
                    context,
                    service.id!,
                    serviceCost,
                  );
                  if (success) {
                    if (context.mounted) {
                      await Navigator.of(context).pushNamed(AppRoutes.userMain);
                    }
                  }
                },
      isLoading: bookingManager.isPaymentProcessing,
    );
  }
}

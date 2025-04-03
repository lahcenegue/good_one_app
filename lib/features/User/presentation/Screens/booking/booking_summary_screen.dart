import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Widgets/general_box.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Providers/User/booking_manager_provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Displays a summary of the booking details and handles order confirmation.
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

        final contractorCost =
            userManager.selectedContractor!.costPerHour!.toDouble();
        final basePrice = bookingManager.basePrice(contractorCost);
        final effectivePrice = bookingManager.effectivePrice(contractorCost);

        final finalPrice = bookingManager.finalPrice(contractorCost);

        return Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(
            context,
            bookingManager,
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
    );
  }

  /// Displays a message when no contractor is selected.
  Widget _buildNoContractorSelected(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Center(
        child: Text('No contractor selected'),
      ),
    );
  }

  /// Builds the main content of the screen.
  Widget _buildBody(
    BuildContext context,
    BookingManagerProvider bookingManager,
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
            _buildContractorInfo(context),
            SizedBox(height: context.getHeight(24)),
            _buildBookingDetails(context, bookingManager),
            SizedBox(height: context.getHeight(24)),
            _buildLocationDetails(context, bookingManager),
            SizedBox(height: context.getHeight(24)),
            _buildOffersSection(context, bookingManager),
            SizedBox(height: context.getHeight(24)),
            _buildPricingSummary(
              context,
              bookingManager,
              basePrice,
              effectivePrice,
              finalPrice,
            ),
            SizedBox(height: context.getHeight(32)),
            _buildConfirmButton(context, bookingManager),
          ],
        ),
      ),
    );
  }

  /// Displays contractor information from UserProvider.
  Widget _buildContractorInfo(BuildContext context) {
    final userProvider =
        Provider.of<UserManagerProvider>(context, listen: false);
    return GeneralBox(
      child: Row(
        children: [
          UserAvatar(
            picture: userProvider.selectedContractor!.picture,
            size: context.getWidth(60),
          ),
          SizedBox(width: context.getWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.selectedContractor!.fullName!,
                  style: AppTextStyles.title2(context),
                ),
                SizedBox(height: context.getHeight(4)),
                Text(
                  userProvider.selectedContractor!.service!,
                  style: AppTextStyles.text(context),
                ),
                SizedBox(height: context.getHeight(4)),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: context.getWidth(16),
                    ),
                    SizedBox(width: context.getWidth(4)),
                    Text(
                      userProvider.selectedContractor!.ratings!.isNotEmpty
                          ? (userProvider.selectedContractor!.ratings!
                                      .map((r) => r.rate)
                                      .reduce((a, b) => a + b) /
                                  userProvider
                                      .selectedContractor!.ratings!.length)
                              .toStringAsFixed(1)
                          : '0.0',
                      style: AppTextStyles.text(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Displays booking details from BookingManagerProvider.
  Widget _buildBookingDetails(
    BuildContext context,
    BookingManagerProvider bookingManager,
  ) {
    return GeneralBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.bookingDetails,
              style: AppTextStyles.title2(context)),
          SizedBox(height: context.getHeight(16)),
          _buildDetailRow(
              context,
              Icons.calendar_today,
              AppLocalizations.of(context)!.date,
              bookingManager.formattedDateTime),
          SizedBox(height: context.getHeight(12)),
          _buildDetailRow(
              context,
              Icons.access_time,
              AppLocalizations.of(context)!.startTime,
              bookingManager.selectedTime),
          SizedBox(height: context.getHeight(12)),
          _buildDetailRow(
              context,
              Icons.timer,
              AppLocalizations.of(context)!.duration,
              '${bookingManager.taskDurationHours} ${bookingManager.taskDurationHours == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}'),
        ],
      ),
    );
  }

  /// Displays location details.
  Widget _buildLocationDetails(
    BuildContext context,
    BookingManagerProvider bookingManager,
  ) {
    return GeneralBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.location,
              style: AppTextStyles.title2(context)),
          SizedBox(height: context.getHeight(16)),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.primaryColor,
                size: context.getWidth(24),
              ),
              SizedBox(width: context.getWidth(12)),
              Expanded(
                child: Text(
                  bookingManager.locationAddress.isNotEmpty
                      ? bookingManager.locationAddress
                      : AppLocalizations.of(context)!.noLocationSpecified,
                  style: AppTextStyles.text(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Handles coupon application UI.
  Widget _buildOffersSection(
    BuildContext context,
    BookingManagerProvider bookingManager,
  ) {
    return GeneralBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer,
                color: AppColors.primaryColor,
                size: context.getWidth(20),
              ),
              SizedBox(width: context.getWidth(8)),
              Text(
                AppLocalizations.of(context)!.couponsAndOffers,
                style: AppTextStyles.title2(context),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(12)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.typeCouponCodeHere,
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
              ),
              SizedBox(width: context.getWidth(8)),
              SizedBox(
                width: context.getWidth(100),
                child: SmallPrimaryButton(
                  text: AppLocalizations.of(context)!.apply,
                  onPressed: bookingManager.isLoading
                      ? () {}
                      : () => _applyCoupon(context, bookingManager),
                  isLoading: bookingManager.isLoading,
                ),
              ),
            ],
          ),
          if (bookingManager.couponError != null)
            Padding(
              padding: EdgeInsets.only(top: context.getHeight(8)),
              child: Text(
                bookingManager.couponError!,
                style: AppTextStyles.text(context)
                    .copyWith(color: AppColors.primaryColor),
              ),
            ),
          if (bookingManager.appliedCoupon != null)
            Padding(
              padding: EdgeInsets.only(top: context.getHeight(8)),
              child: Text(
                AppLocalizations.of(context)!.couponApplied(
                    bookingManager.appliedCoupon!,
                    (bookingManager.discountPercentage! * 100)
                        .toStringAsFixed(0)),
                style:
                    AppTextStyles.text(context).copyWith(color: Colors.green),
              ),
            ),
        ],
      ),
    );
  }

  /// Applies a coupon using the provider.
  void _applyCoupon(
      BuildContext context, BookingManagerProvider bookingManager) {
    final couponCode = _couponController.text.trim();
    bookingManager.applyCoupon(couponCode, context);
  }

  /// Displays the pricing summary.
  Widget _buildPricingSummary(
      BuildContext context,
      BookingManagerProvider bookingManager,
      double basePrice,
      double effectivePrice,
      double finalPrice) {
    final userManager =
        Provider.of<UserManagerProvider>(context, listen: false);
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
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.priceSummary,
              style: AppTextStyles.title2(context)),
          SizedBox(height: context.getHeight(16)),
          _buildPriceRow(context, AppLocalizations.of(context)!.hourlyRate,
              '\$${userManager.selectedContractor!.costPerHour}/hr'),
          SizedBox(height: context.getHeight(8)),
          _buildPriceRow(context, AppLocalizations.of(context)!.duration,
              '${bookingManager.taskDurationHours} ${bookingManager.taskDurationHours == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}'),
          SizedBox(height: context.getHeight(8)),
          _buildPriceRow(context, AppLocalizations.of(context)!.subtotal,
              '\$${basePrice.toStringAsFixed(2)}'),
          if (bookingManager.discountPercentage != null) ...[
            SizedBox(height: context.getHeight(8)),
            _buildPriceRow(context, AppLocalizations.of(context)!.discount,
                '-${discountAmount.toStringAsFixed(2)} (${(bookingManager.discountPercentage! * 100).toStringAsFixed(0)}%)',
                textColor: Colors.green),
          ],
          if (taxInfo != null) ...[
            SizedBox(height: context.getHeight(8)),
            _buildPriceRow(context, 'Region Taxes (${taxInfo.regionTaxes}%)',
                '\$${taxAmount.toStringAsFixed(2)}'),
            if (taxInfo.platformFeesPercentage != 0) ...[
              SizedBox(height: context.getHeight(8)),
              _buildPriceRow(
                  context,
                  'Platform Fee (${taxInfo.platformFeesPercentage}%)',
                  '\$${platformFeePercentageAmount.toStringAsFixed(2)}'),
            ],
            if (taxInfo.platformFees != 0) ...[
              SizedBox(height: context.getHeight(8)),
              _buildPriceRow(context, 'Platform Fee (Fixed)',
                  '\$${platformFeeFixed.toStringAsFixed(2)}'),
            ],
          ],
          Divider(height: context.getHeight(24)),
          _buildPriceRow(context, AppLocalizations.of(context)!.totalAmount,
              '\$${finalPrice.toStringAsFixed(2)}',
              titleStyle: AppTextStyles.title2(context),
              valueStyle: AppTextStyles.title2(context)
                  .copyWith(color: AppColors.primaryColor)),
        ],
      ),
    );
  }

  /// Reusable price row widget.
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
        Text(title, style: titleStyle ?? AppTextStyles.text(context)),
        Text(value,
            style: valueStyle ??
                AppTextStyles.text(context).copyWith(color: textColor)),
      ],
    );
  }

  /// Reusable detail row widget.
  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: context.getWidth(24),
        ),
        SizedBox(width: context.getWidth(12)),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.subTitle(context),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
              Text(value,
                  style: AppTextStyles.text(context),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  softWrap: true),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the confirm button with loading state.
  Widget _buildConfirmButton(
    BuildContext context,
    BookingManagerProvider bookingManager,
  ) {
    final userManager =
        Provider.of<UserManagerProvider>(context, listen: false);
    final contractorCost = userManager.selectedContractor!.costPerHour ?? 50.0;
    return PrimaryButton(
      text: AppLocalizations.of(context)!.confirm,
      onPressed:
          (bookingManager.isPaymentProcessing || bookingManager.isLoading)
              ? () {}
              : () async {
                  final success = await bookingManager.createOrder(
                    context,
                    userManager.selectedContractor!.serviceId!,
                    contractorCost.toDouble(),
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

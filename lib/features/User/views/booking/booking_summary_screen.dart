import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Core/presentation/Widgets/user_avatar.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/user_state_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return Consumer<UserStateProvider>(
      builder: (context, userManager, _) {
        if (userManager.selectedContractor == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.bookingSummary,
                style: AppTextStyles.appBarTitle(context),
              ),
            ),
            body: const Center(child: Text('No contractor selected')),
          );
        }

        final totalPrice = userManager.selectedContractor!.costPerHour! *
            userManager.taskDurationHours;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.bookingSummary,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(context.getWidth(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContractorInfo(context, userManager),
                  SizedBox(height: context.getHeight(24)),
                  _buildBookingDetails(context, userManager),
                  SizedBox(height: context.getHeight(24)),
                  _buildLocationDetails(context, userManager),
                  SizedBox(height: context.getHeight(24)),
                  _buildOffersSection(context), // New offers box
                  SizedBox(height: context.getHeight(24)),
                  _buildPricingSummary(
                      context, totalPrice.toDouble(), userManager),
                  SizedBox(height: context.getHeight(32)),
                  _buildConfirmButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContractorInfo(
      BuildContext context, UserStateProvider userManager) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          UserAvatar(
            picture: userManager.selectedContractor!.picture,
            size: context.getWidth(60),
          ),
          SizedBox(width: context.getWidth(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userManager.selectedContractor!.fullName!,
                  style: AppTextStyles.title2(context),
                ),
                SizedBox(height: context.getHeight(4)),
                Text(
                  userManager.selectedContractor!.service!,
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
                      '${userManager.selectedContractor!.ratings.isNotEmpty ? (userManager.selectedContractor!.ratings.map((r) => r.rate).reduce((a, b) => a + b) / userManager.selectedContractor!.ratings.length).toStringAsFixed(1) : '0.0'}',
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

  Widget _buildBookingDetails(
      BuildContext context, UserStateProvider userManager) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.bookingDetails,
            style: AppTextStyles.title2(context),
          ),
          SizedBox(height: context.getHeight(16)),
          _buildDetailRow(
            context,
            Icons.calendar_today,
            AppLocalizations.of(context)!.date,
            userManager.formattedDateTime,
          ),
          SizedBox(height: context.getHeight(12)),
          _buildDetailRow(
            context,
            Icons.access_time,
            AppLocalizations.of(context)!.startTime,
            userManager.selectedTime,
          ),
          SizedBox(height: context.getHeight(12)),
          _buildDetailRow(
            context,
            Icons.timer,
            AppLocalizations.of(context)!.duration,
            '${userManager.taskDurationHours} ${userManager.taskDurationHours == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetails(
      BuildContext context, UserStateProvider userManager) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.location,
            style: AppTextStyles.title2(context),
          ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userManager.locationAddress.isNotEmpty
                          ? userManager.locationAddress
                          : AppLocalizations.of(context)!.noLocationSpecified,
                      style: AppTextStyles.text(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
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
                  onPressed: () {
                    // TODO: Implement coupon validation and apply discount logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Coupon "${_couponController.text}" applied (if valid)'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummary(
    BuildContext context,
    double totalPrice,
    UserStateProvider userManager,
  ) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.priceSummary,
            style: AppTextStyles.title2(context),
          ),
          SizedBox(height: context.getHeight(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.hourlyRate,
                style: AppTextStyles.text(context),
              ),
              Text(
                '\$${userManager.selectedContractor!.costPerHour}/hr',
                style: AppTextStyles.text(context),
              ),
            ],
          ),
          SizedBox(height: context.getHeight(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.duration,
                style: AppTextStyles.text(context),
              ),
              Text(
                '${userManager.taskDurationHours} ${userManager.taskDurationHours == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}',
                style: AppTextStyles.text(context),
              ),
            ],
          ),
          Divider(height: context.getHeight(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.totalAmount,
                style: AppTextStyles.title2(context),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: AppTextStyles.title2(context).copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          // Use Flexible instead of Expanded to allow shrinking
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.subTitle(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                value,
                style: AppTextStyles.text(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return PrimaryButton(
      text: AppLocalizations.of(context)!.confirm,
      onPressed: () {
        // Example:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => PaymentScreen(),
        //   ),
        // );
      },
    );
  }
}

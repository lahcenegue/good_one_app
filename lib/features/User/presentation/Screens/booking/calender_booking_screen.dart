import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Providers/User/booking_manager_provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class CalendarBookingScreen extends StatelessWidget {
  const CalendarBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.schedule,
          style: AppTextStyles.appBarTitle(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Consumer2<BookingManagerProvider, UserManagerProvider>(
        builder: (context, bookingManager, userManager, _) {
          if (userManager.selectedContractor == null) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noContractorSelected),
            );
          }

          final service = userManager.selectedContractor!;
          final servicePricingType = service.pricingType ?? 'hourly';

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(context.getWidth(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar Section
                      _buildCalendar(context, bookingManager),
                      SizedBox(height: context.getHeight(24)),

                      // Time Selection
                      _buildTimeSelection(context, bookingManager),
                      SizedBox(height: context.getHeight(24)),

                      // Duration Selection (based on service pricing type)
                      _buildDurationSelection(
                          context, bookingManager, servicePricingType, service),
                      SizedBox(height: context.getHeight(24)),

                      // Booking Summary
                      _buildBookingSummary(context, bookingManager, service),
                      SizedBox(height: context.getHeight(32)),

                      // Next Button
                      _buildNextButton(context, bookingManager),
                      SizedBox(height: context.getHeight(24)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Calendar widget with modern design
  Widget _buildCalendar(
      BuildContext context, BookingManagerProvider bookingManager) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.getWidth(20)),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: context.getWidth(12)),
                Text(
                  AppLocalizations.of(context)!.startDate,
                  style: AppTextStyles.title2(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.getWidth(12)),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 31)),
              focusedDay: bookingManager.focusedDay,
              selectedDayPredicate: (day) =>
                  isSameDay(bookingManager.selectedDay, day),
              calendarFormat: CalendarFormat.month,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: AppTextStyles.title2(context),
                leftChevronIcon: Icon(Icons.chevron_left,
                    size: context.getWidth(24), color: AppColors.primaryColor),
                rightChevronIcon: Icon(Icons.chevron_right,
                    size: context.getWidth(24), color: AppColors.primaryColor),
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                    color: AppColors.primaryColor, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                weekendTextStyle: TextStyle(
                    color: AppColors.primaryColor.withValues(alpha: 0.5)),
              ),
              onDaySelected: bookingManager.onDaySelected,
            ),
          ),
          SizedBox(height: context.getHeight(12)),
        ],
      ),
    );
  }

  /// Time selection with modern chips
  Widget _buildTimeSelection(
      BuildContext context, BookingManagerProvider bookingManager) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.getWidth(20)),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: context.getWidth(12)),
                Text(
                  AppLocalizations.of(context)!.startTime,
                  style: AppTextStyles.title2(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.getWidth(16)),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.2,
                crossAxisSpacing: context.getWidth(8),
                mainAxisSpacing: context.getHeight(8),
              ),
              itemCount: 24,
              itemBuilder: (context, index) {
                final hour = index;
                final timeSlot = '${hour.toString().padLeft(2, '0')}:00';
                final isSelected = timeSlot == bookingManager.selectedTime;
                final isAvailable =
                    bookingManager.isTimeSlotAvailable(timeSlot);
                return _buildTimeChip(
                    context, timeSlot, isSelected, isAvailable, bookingManager);
              },
            ),
          ),
          SizedBox(height: context.getHeight(16)),
        ],
      ),
    );
  }

  /// Modern time chip design
  Widget _buildTimeChip(
    BuildContext context,
    String timeSlot,
    bool isSelected,
    bool isAvailable,
    BookingManagerProvider bookingManager,
  ) {
    final hour = int.parse(timeSlot.split(':')[0]);
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayTime = '$displayHour$period';

    return InkWell(
      onTap: isAvailable ? () => bookingManager.selectTime(timeSlot) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withValues(alpha: 0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isAvailable ? Colors.grey.shade50 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isAvailable ? Colors.grey.shade300 : Colors.grey.shade400),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            displayTime,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isAvailable ? Colors.black87 : Colors.grey.shade500),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Duration selection based on service pricing type
  Widget _buildDurationSelection(
    BuildContext context,
    BookingManagerProvider bookingManager,
    String servicePricingType,
    dynamic service,
  ) {
    // Set the duration type based on service pricing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bookingManager.durationType != servicePricingType) {
        bookingManager.setDurationType(servicePricingType);
      }
    });

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
                  _getPricingIcon(servicePricingType),
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                SizedBox(width: context.getWidth(12)),
                Text(
                  _getPricingTitle(context, servicePricingType),
                  style: AppTextStyles.title2(context),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(16)),

            // Show pricing info
            Container(
              padding: EdgeInsets.all(context.getWidth(16)),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: context.getWidth(12)),
                  Expanded(
                    child: Text(
                      _getPricingDescription(
                          context, servicePricingType, service),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Duration input (only for hourly and daily)
            if (servicePricingType != 'fixed') ...[
              SizedBox(height: context.getHeight(20)),
              Text(
                _getDurationInputLabel(context, servicePricingType),
                style: AppTextStyles.text(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: context.getHeight(12)),

              // Manual input field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.3)),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: bookingManager.durationController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: _getHintText(context, servicePricingType),
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: context.getWidth(16),
                            vertical: context.getHeight(14),
                          ),
                        ),
                        onChanged: (value) =>
                            bookingManager.updateDurationInput(value),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.getWidth(16),
                        vertical: context.getHeight(14),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        _getDurationUnit(context, servicePricingType),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick selection chips
              SizedBox(height: context.getHeight(16)),
              Text(
                AppLocalizations.of(context)!.quickSelect,
                style: AppTextStyles.text(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: context.getHeight(12)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _getQuickSelectOptions(servicePricingType)
                      .map((value) =>
                          _buildQuickSelectChip(context, bookingManager, value))
                      .toList(),
                ),
              ),
            ],

            // Duration summary
            if (bookingManager.hasValidDuration ||
                servicePricingType == 'fixed') ...[
              SizedBox(height: context.getHeight(16)),
              Container(
                padding: EdgeInsets.all(context.getWidth(16)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.1),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: context.getWidth(12)),
                    Expanded(
                      child: Text(
                        _getDurationSummary(
                            context, bookingManager, servicePricingType),
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Quick selection chips with modern design
  Widget _buildQuickSelectChip(
    BuildContext context,
    BookingManagerProvider bookingManager,
    double value,
  ) {
    final isSelected = bookingManager.durationValue == value;

    return Padding(
      padding: EdgeInsets.only(right: context.getWidth(8)),
      child: InkWell(
        onTap: () => bookingManager.setDurationValue(value),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.getWidth(16),
            vertical: context.getHeight(8),
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.8)
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            value == value.toInt()
                ? value.toInt().toString()
                : value.toString(),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  ///  Booking summary
  Widget _buildBookingSummary(
    BuildContext context,
    BookingManagerProvider bookingManager,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: AppColors.primaryColor,
                  size: context.getAdaptiveSize(24),
                ),
                SizedBox(width: context.getWidth(12)),
                Text(
                  AppLocalizations.of(context)!.bookingSummary,
                  style: AppTextStyles.title2(context).copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.getHeight(16)),

            // Date and time
            _buildSummaryRow(
              context,
              Icons.event,
              AppLocalizations.of(context)!.dateTime,
              bookingManager.formattedDateTime,
            ),

            if (service.pricingType != 'fixed') ...[
              SizedBox(height: context.getHeight(12)),
              _buildSummaryRow(
                context,
                Icons.schedule,
                AppLocalizations.of(context)!.duration,
                _getDurationSummary(
                    context, bookingManager, service.pricingType ?? 'hourly'),
              ),
            ],

            SizedBox(height: context.getHeight(12)),
            _buildSummaryRow(
              context,
              Icons.attach_money,
              AppLocalizations.of(context)!.estimatedPrice,
              service.displayPrice?.displayText ?? 'Contact for pricing',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: context.getAdaptiveSize(18),
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

  /// Modern next button
  Widget _buildNextButton(
      BuildContext context, BookingManagerProvider bookingManager) {
    final isValid = bookingManager.isValidTimeSelection();

    return PrimaryButton(
      text: AppLocalizations.of(context)!.next,
      onPressed: isValid
          ? () {
              Navigator.of(context).pushNamed(AppRoutes.locationScreen);
            }
          : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.selectValidTimeSlot),
                  backgroundColor: Colors.red,
                ),
              ),
    );
  }

  // Helper methods
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

  String _getPricingTitle(BuildContext context, String pricingType) {
    switch (pricingType) {
      case 'hourly':
        return AppLocalizations.of(context)!.hourlyPricing;
      case 'daily':
        return AppLocalizations.of(context)!.dailyPricing;
      case 'fixed':
        return AppLocalizations.of(context)!.fixedPricing;
      default:
        return AppLocalizations.of(context)!.pricing;
    }
  }

  String _getPricingDescription(
      BuildContext context, String pricingType, dynamic service) {
    switch (pricingType) {
      case 'hourly':
        return '${AppLocalizations.of(context)!.chargedAt} ${service.costPerHour ?? 0}/${AppLocalizations.of(context)!.hour}. ${AppLocalizations.of(context)!.selectHoursNeeded}';
      case 'daily':
        return '${AppLocalizations.of(context)!.chargedAt} ${service.costPerDay ?? 0}/${AppLocalizations.of(context)!.day}. ${AppLocalizations.of(context)!.selectDaysNeeded}';
      case 'fixed':
        return '${AppLocalizations.of(context)!.fixedPriceOf} ${service.fixedPrice ?? 0} ${AppLocalizations.of(context)!.forCompleteService}.';
      default:
        return AppLocalizations.of(context)!.servicePricingInformation;
    }
  }

  String _getDurationInputLabel(BuildContext context, String durationType) {
    switch (durationType) {
      case 'hourly':
        return AppLocalizations.of(context)!.enterHours;
      case 'daily':
        return AppLocalizations.of(context)!.enterDays;
      default:
        return AppLocalizations.of(context)!.enterDuration;
    }
  }

  String _getHintText(BuildContext context, String durationType) {
    switch (durationType) {
      case 'hourly':
        return AppLocalizations.of(context)!.exampleHours;
      case 'daily':
        return AppLocalizations.of(context)!.exampleDays;
      default:
        return '';
    }
  }

  String _getDurationUnit(BuildContext context, String durationType) {
    switch (durationType) {
      case 'hourly':
        return AppLocalizations.of(context)!.hoursUnit;
      case 'daily':
        return AppLocalizations.of(context)!.daysUnit;
      default:
        return '';
    }
  }

  List<double> _getQuickSelectOptions(String durationType) {
    switch (durationType) {
      case 'hourly':
        return [1, 2, 4, 6, 8, 12];
      case 'daily':
        return [1, 2, 3, 5, 7, 14];
      default:
        return [];
    }
  }

  String _getDurationSummary(BuildContext context,
      BookingManagerProvider bookingManager, String pricingType) {
    final value = bookingManager.durationValue;

    switch (pricingType) {
      case 'hourly':
        return '${value == value.toInt() ? value.toInt() : value} ${value == 1 ? AppLocalizations.of(context)!.hour : AppLocalizations.of(context)!.hours}';
      case 'daily':
        return '${value == value.toInt() ? value.toInt() : value} ${value == 1 ? AppLocalizations.of(context)!.day : AppLocalizations.of(context)!.days}';
      case 'fixed':
        return AppLocalizations.of(context)!.completeServiceFixedPrice;
      default:
        return '';
    }
  }
}

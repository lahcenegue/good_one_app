import 'package:flutter/material.dart';
import 'package:good_one_app/core/utils/size_config.dart';
import 'package:good_one_app/core/presentation/widgets/buttons/primary_button.dart';
import 'package:good_one_app/core/presentation/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../Providers/booking_manager_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/presentation/theme/app_text_styles.dart';

/// Allows users to select booking date, time, and duration.
class CalendarBookingScreen extends StatelessWidget {
  const CalendarBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.schedule,
            style: AppTextStyles.appBarTitle(context)),
      ),
      body: Consumer<BookingManagerProvider>(
        builder: (context, bookingManager, _) => SingleChildScrollView(
          padding: EdgeInsets.all(context.getWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendar(context, bookingManager),
              SizedBox(height: context.getHeight(24)),
              _buildTimeSelection(context, bookingManager),
              SizedBox(height: context.getHeight(24)),
              _buildDurationSelection(context, bookingManager),
              SizedBox(height: context.getHeight(24)),
              _buildSummaryCard(context, bookingManager),
              SizedBox(height: context.getHeight(32)),
              _buildNextButton(context, bookingManager),
              SizedBox(height: context.getHeight(24)),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the calendar widget for date selection.
  Widget _buildCalendar(
      BuildContext context, BookingManagerProvider bookingManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.startDate,
            style: AppTextStyles.title2(context)),
        SizedBox(height: context.getHeight(12)),
        Container(
          padding: EdgeInsets.all(context.getWidth(12)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
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
                  color: AppColors.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle),
              weekendTextStyle:
                  TextStyle(color: AppColors.primaryColor.withOpacity(0.5)),
            ),
            onDaySelected: bookingManager.onDaySelected,
          ),
        ),
      ],
    );
  }

  /// Builds the time selection grid.
  Widget _buildTimeSelection(
      BuildContext context, BookingManagerProvider bookingManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.startTime,
          style: AppTextStyles.title2(context),
        ),
        SizedBox(height: context.getHeight(12)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.getWidth(12)),
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
              final isAvailable = bookingManager.isTimeSlotAvailable(timeSlot);
              return _buildTimeChip(
                context,
                timeSlot,
                isSelected,
                isAvailable,
                bookingManager,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Reusable time chip widget.
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
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : (isAvailable ? Colors.transparent : AppColors.dimGray),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isAvailable ? Colors.grey.shade300 : Colors.grey.shade200),
          ),
        ),
        child: Center(
          child: Text(
            displayTime,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isAvailable ? Colors.black87 : Colors.grey),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the duration selection row.
  Widget _buildDurationSelection(
      BuildContext context, BookingManagerProvider bookingManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Duration', //TODO
          style: AppTextStyles.title2(context),
        ),
        SizedBox(height: context.getHeight(12)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: EdgeInsets.all(context.getWidth(12)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: bookingManager.availableDurations.map((hours) {
                final isSelected = bookingManager.taskDurationHours == hours;
                return Padding(
                  padding: EdgeInsets.only(
                      right: hours == bookingManager.availableDurations.last
                          ? 0
                          : context.getWidth(8)),
                  child: InkWell(
                    onTap: () => bookingManager.setTaskDuration(hours),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.getWidth(16),
                          vertical: context.getHeight(8)),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.dimGray),
                      ),
                      child: Text(
                        '$hours ${hours == 1 ? 'hour' : 'hours'}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Displays a summary of the selected booking details.
  Widget _buildSummaryCard(
      BuildContext context, BookingManagerProvider bookingManager) {
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
            'Booking Summary',
            style: AppTextStyles.title2(context)
                .copyWith(color: AppColors.primaryColor),
          ),
          SizedBox(height: context.getHeight(12)),
          Row(
            children: [
              const Icon(
                Icons.event,
                color: AppColors.primaryColor,
                size: 20,
              ),
              SizedBox(width: context.getWidth(8)),
              Expanded(
                  child: Text(bookingManager.formattedDateTime,
                      style: AppTextStyles.text(context))),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the next button with validation.
  Widget _buildNextButton(
      BuildContext context, BookingManagerProvider bookingManager) {
    final isValid =
        bookingManager.isValidTimeSelection(); // Use your updated validation

    return PrimaryButton(
      text: AppLocalizations.of(context)!.next,
      onPressed: isValid
          ? () {
              Navigator.of(context).pushNamed(AppRoutes.locationScreen);
            }
          : () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        AppLocalizations.of(context)!.selectValidTimeSlot)),
              ),
    );
  }
}

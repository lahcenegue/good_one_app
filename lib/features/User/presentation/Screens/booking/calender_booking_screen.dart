import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Providers/User/booking_manager_provider.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Presentation/Resources/app_colors.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle),
              weekendTextStyle: TextStyle(
                  color: AppColors.primaryColor.withValues(alpha: 0.5)),
            ),
            onDaySelected: bookingManager.onDaySelected,
          ),
        ),
      ],
    );
  }

  /// Builds the time selection grid.
  Widget _buildTimeSelection(
    BuildContext context,
    BookingManagerProvider bookingManager,
  ) {
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

  Widget _buildDurationSelection(
    BuildContext context,
    BookingManagerProvider bookingManager,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.taskDuration,
          style: AppTextStyles.title2(context),
        ),
        SizedBox(height: context.getHeight(12)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: EdgeInsets.all(context.getWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Duration Type Selection
              Text(
                AppLocalizations.of(context)!.selectDurationType,
                style: AppTextStyles.text(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: context.getHeight(8)),
              Row(
                children: [
                  _buildDurationTypeChip(
                    context,
                    bookingManager,
                    'hours',
                    AppLocalizations.of(context)!.hours,
                    Icons.access_time,
                  ),
                  SizedBox(width: context.getWidth(8)),
                  _buildDurationTypeChip(
                    context,
                    bookingManager,
                    'days',
                    AppLocalizations.of(context)!.days,
                    Icons.calendar_today,
                  ),
                  SizedBox(width: context.getWidth(8)),
                  _buildDurationTypeChip(
                    context,
                    bookingManager,
                    'task',
                    AppLocalizations.of(context)!.taskBased,
                    Icons.task_alt,
                  ),
                ],
              ),

              SizedBox(height: context.getHeight(16)),

              // Duration Input Section (only for hours and days)
              if (bookingManager.durationType != 'task') ...[
                Text(
                  _getDurationInputLabel(context, bookingManager.durationType),
                  style: AppTextStyles.text(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: context.getHeight(8)),

                // Manual Input Field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
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
                            hintText: _getHintText(
                                context, bookingManager.durationType),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: context.getWidth(12),
                              vertical: context.getHeight(12),
                            ),
                          ),
                          onChanged: (value) =>
                              bookingManager.updateDurationInput(value),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.getWidth(12),
                          vertical: context.getHeight(12),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          _getDurationUnit(
                              context, bookingManager.durationType),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Task-based explanation
                Container(
                  padding: EdgeInsets.all(context.getWidth(12)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
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
                      SizedBox(width: context.getWidth(8)),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.taskBasedInfo,
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Quick Selection for Hours/Days
              if (bookingManager.durationType != 'task') ...[
                SizedBox(height: context.getHeight(12)),
                Text(
                  AppLocalizations.of(context)!.quickSelect,
                  style: AppTextStyles.text(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: context.getHeight(8)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _getQuickSelectOptions(bookingManager.durationType)
                            .map((value) => _buildQuickSelectChip(
                                  context,
                                  bookingManager,
                                  value,
                                ))
                            .toList(),
                  ),
                ),
              ],

              // Duration Summary
              if (bookingManager.hasValidDuration) ...[
                SizedBox(height: context.getHeight(12)),
                Container(
                  padding: EdgeInsets.all(context.getWidth(12)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryColor,
                        size: 18,
                      ),
                      SizedBox(width: context.getWidth(8)),
                      Expanded(
                        child: Text(
                          _getDurationSummary(context, bookingManager),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 13,
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
      ],
    );
  }

  /// Builds duration type selection chips (Hours/Days/Task-based)
  Widget _buildDurationTypeChip(
    BuildContext context,
    BookingManagerProvider bookingManager,
    String type,
    String label,
    IconData icon,
  ) {
    final isSelected = bookingManager.durationType == type;

    return Expanded(
      child: InkWell(
        onTap: () => bookingManager.setDurationType(type),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.getWidth(12),
            vertical: context.getHeight(10),
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              SizedBox(width: context.getWidth(6)),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds quick selection chips for common durations
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
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.getWidth(12),
            vertical: context.getHeight(6),
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
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
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// Helper methods for labels and options
  String _getDurationInputLabel(BuildContext context, String durationType) {
    switch (durationType) {
      case 'hours':
        return AppLocalizations.of(context)!.enterHours;
      case 'days':
        return AppLocalizations.of(context)!.enterDays;
      case 'task':
        return AppLocalizations.of(context)!.taskPrice;
      default:
        return AppLocalizations.of(context)!.enterDuration;
    }
  }

  String _getHintText(BuildContext context, String durationType) {
    switch (durationType) {
      case 'hours':
        return AppLocalizations.of(context)!.exampleHours;
      case 'days':
        return AppLocalizations.of(context)!.exampleDays;
      case 'task':
        return AppLocalizations.of(context)!.exampleTaskPrice;
      default:
        return '';
    }
  }

  String _getDurationUnit(BuildContext context, String durationType) {
    switch (durationType) {
      case 'hours':
        return AppLocalizations.of(context)!.hoursUnit;
      case 'days':
        return AppLocalizations.of(context)!.daysUnit;
      case 'task':
        return '\$';
      default:
        return '';
    }
  }

  List<double> _getQuickSelectOptions(String durationType) {
    switch (durationType) {
      case 'hours':
        return [1, 2, 4, 6, 8, 12];
      case 'days':
        return [1, 2, 3, 5, 7, 14];
      default:
        return [];
    }
  }

  String _getDurationSummary(
      BuildContext context, BookingManagerProvider bookingManager) {
    final value = bookingManager.durationValue;
    final type = bookingManager.durationType;

    switch (type) {
      case 'hours':
        return '${AppLocalizations.of(context)!.totalHours}: ${value == value.toInt() ? value.toInt() : value}';
      case 'days':
        final totalHours = value * 8; // Assuming 8 hours per day
        return '${AppLocalizations.of(context)!.totalDays}: ${value == value.toInt() ? value.toInt() : value} (${totalHours.toInt()} ${AppLocalizations.of(context)!.hours})';
      case 'task':
        return '${AppLocalizations.of(context)!.fixedTaskPrice}: ${AppLocalizations.of(context)!.oneHourService}';
      default:
        return '';
    }
  }

  /// Displays a summary of the selected booking details.
  Widget _buildSummaryCard(
      BuildContext context, BookingManagerProvider bookingManager) {
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
          Text(
            AppLocalizations.of(context)!.bookingSummary,
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

import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Features/User/views/location_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../Core/presentation/Theme/app_text_styles.dart';
import '../../../Providers/user_manager_provider.dart';

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
      body: Consumer<UserManagerProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(context.getWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Start Date (Calendar) first
                _buildCalendar(context, provider),
                SizedBox(height: context.getHeight(24)),

                // 2. Start Time selection second
                _buildTimeSelection(context, provider),
                SizedBox(height: context.getHeight(24)),

                // 3. Task Duration third
                _buildDurationSelection(context, provider),
                SizedBox(height: context.getHeight(24)),

                // Summary and Next button remain at the bottom
                _buildSummaryCard(context, provider),
                SizedBox(height: context.getHeight(32)),
                _buildNextButton(context, provider),
                SizedBox(height: context.getHeight(24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelection(
      BuildContext context, UserManagerProvider provider) {
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
              final isSelected = timeSlot == provider.selectedTime;
              final isAvailable = provider.isTimeSlotAvailable(timeSlot);

              return _buildTimeChip(
                context,
                timeSlot,
                isSelected,
                isAvailable,
                provider,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip(
    BuildContext context,
    String timeSlot,
    bool isSelected,
    bool isAvailable,
    UserManagerProvider provider,
  ) {
    final hour = int.parse(timeSlot.split(':')[0]);
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayTime = '${displayHour.toString()}${period}';

    return InkWell(
      onTap: isAvailable ? () => provider.selectTime(timeSlot) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : isAvailable
                  ? Colors.transparent
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : isAvailable
                    ? Colors.grey.shade300
                    : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Text(
            displayTime,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isAvailable
                      ? Colors.black87
                      : Colors.grey,
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
    UserManagerProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Duration',
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
              children: provider.availableDurations.map((hours) {
                final isSelected = provider.taskDurationHours == hours;
                return Padding(
                  padding: EdgeInsets.only(
                      right: hours == provider.availableDurations.last
                          ? 0
                          : context.getWidth(8)),
                  child: InkWell(
                    onTap: () => provider.setTaskDuration(hours),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.getWidth(16),
                        vertical: context.getHeight(8),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.dimGray,
                        ),
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

  Widget _buildCalendar(BuildContext context, UserManagerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.startDate,
          style: AppTextStyles.title2(context),
        ),
        SizedBox(height: context.getHeight(12)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: EdgeInsets.all(context.getWidth(12)),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 31)),
            focusedDay: provider.focusedDay,
            selectedDayPredicate: (day) => isSameDay(provider.selectedDay, day),
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: AppTextStyles.title2(context),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                size: context.getWidth(24),
                color: AppColors.primaryColor,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                size: context.getWidth(24),
                color: AppColors.primaryColor,
              ),
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red.shade300),
            ),
            onDaySelected: provider.onDaySelected,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, UserManagerProvider provider) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: AppTextStyles.title2(context).copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: context.getHeight(12)),
          Row(
            children: [
              Icon(Icons.event, color: AppColors.primaryColor, size: 20),
              SizedBox(width: context.getWidth(8)),
              Expanded(
                child: Text(
                  provider.formattedDateTime,
                  style: AppTextStyles.text(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, UserManagerProvider provider) {
    final bool isValid = provider.isValidBookingSelection(debug: true);

    return PrimaryButton(
      text: AppLocalizations.of(context)!.next,
      onPressed: isValid
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationScreen(),
                ),
              );
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please select a valid future time slot'),
                ),
              );
            },
    );
  }
}

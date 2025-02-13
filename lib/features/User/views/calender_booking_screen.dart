import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../Core/presentation/Theme/app_text_styles.dart';
import '../../../Providers/user_manager_provider.dart';

class CalenderBookingScreen extends StatelessWidget {
  const CalenderBookingScreen({super.key});

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
                _buildCalendar(context, provider),
                SizedBox(height: context.getHeight(20)),
                _buildTimeSelection(context, provider),
                SizedBox(height: context.getHeight(20)),
                _buildSelectedDateTime(context, provider),
                SizedBox(height: context.getHeight(50)),
                _buildNextButton(context, provider),
                SizedBox(height: context.getHeight(30)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    UserManagerProvider provider,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.startDate,
          style: AppTextStyles.title2(context),
        ),
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 31)),
          focusedDay: provider.focusedDay,
          selectedDayPredicate: (day) => isSameDay(provider.selectedDay, day),
          calendarFormat: CalendarFormat.month,
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            leftChevronIcon:
                Icon(Icons.chevron_left, size: context.getWidth(24)),
            rightChevronIcon:
                Icon(Icons.chevron_right, size: context.getWidth(24)),
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
          ),
          onDaySelected: provider.onDaySelected,
        ),
      ],
    );
  }

  Widget _buildTimeSelection(
    BuildContext context,
    UserManagerProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.startTime,
          style: AppTextStyles.title2(context),
        ),
        Padding(
          padding: EdgeInsets.all(context.getWidth(8)),
          child: Column(
            children: List.generate(6, (rowIndex) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: rowIndex < 5 ? context.getHeight(8) : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(4, (colIndex) {
                    final timeIndex = rowIndex * 4 + colIndex;

                    // Convert to 12-hour format with AM/PM
                    int hour = timeIndex;
                    String period = hour >= 12 ? 'PM' : 'AM';

                    if (hour == 0) {
                      hour = 12;
                    } else if (hour > 12) {
                      hour -= 12;
                    }

                    final hourString = hour.toString().padLeft(2, '0');
                    final timeSlot = '$hourString:00 $period';
                    final isSelected = timeSlot == provider.selectedTime;

                    return SizedBox(
                      width: (context.screenWidth - context.getWidth(64)) / 4,
                      child: ChoiceChip(
                        label: Text(
                          timeSlot,
                          style: AppTextStyles.text(context).copyWith(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            provider.selectTime(timeSlot);
                          }
                        },
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.dimGray,
                          ),
                        ),
                        padding: EdgeInsets.all(context.getWidth(4)),
                        labelPadding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // Widget _buildTimeSelection(
  //   BuildContext context,
  //   UserManagerProvider provider,
  // ) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Container(
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(color: AppColors.dimGray.withOpacity(0.3)),
  //         ),
  //         child: GridView.builder(
  //           padding: EdgeInsets.all(context.getWidth(8)),
  //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: 4,
  //             childAspectRatio: 2.2,
  //             mainAxisSpacing: context.getHeight(8),
  //             crossAxisSpacing: context.getWidth(8),
  //           ),
  //           itemCount: provider.timeSlots.length,
  //           itemBuilder: (context, index) {
  //             final timeSlot = provider.timeSlots[index];
  //             final isSelected = timeSlot == provider.selectedTime;

  //             return Material(
  //               color: isSelected ? AppColors.primaryColor : Colors.transparent,
  //               borderRadius: BorderRadius.circular(8),
  //               child: InkWell(
  //                 onTap: () => provider.selectTime(timeSlot),
  //                 borderRadius: BorderRadius.circular(8),
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(8),
  //                     border: Border.all(
  //                       color: isSelected
  //                           ? AppColors.primaryColor
  //                           : AppColors.dimGray,
  //                     ),
  //                   ),
  //                   child: Center(
  //                     child: Text(
  //                       timeSlot,
  //                       style: AppTextStyles.text(context),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildCouponSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Row(
  //         children: [
  //           Icon(Icons.local_offer_outlined),
  //           SizedBox(width: 8),
  //           Text(
  //             'Coupons & Offers',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 8),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: TextField(
  //               controller: _couponController,
  //               decoration: const InputDecoration(
  //                 hintText: 'Type your coupon code here...',
  //                 border: OutlineInputBorder(),
  //                 contentPadding:
  //                     EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(width: 8),
  //           ElevatedButton(
  //             onPressed: () {},
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red,
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //             ),
  //             child: const Text('Apply'),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSelectedDateTime(
    BuildContext context,
    UserManagerProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: AppColors.primaryColor),
          SizedBox(width: context.getWidth(8)),
          Expanded(
            child: Text(
                '${AppLocalizations.of(context)!.selected}: ${provider.formattedDateTime}',
                style: AppTextStyles.text(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, UserManagerProvider provider) {
    return PrimaryButton(
      text: AppLocalizations.of(context)!.next,
      onPressed: () {
        print(provider.bookingTimestamp);
      },
    );
  }
}

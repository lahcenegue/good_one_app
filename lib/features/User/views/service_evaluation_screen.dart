import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:good_one_app/Core/presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/booking_manager_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ServiceEvaluationScreen extends StatelessWidget {
  final int serviceId;

  const ServiceEvaluationScreen({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.rateService,
          style: AppTextStyles.appBarTitle(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<BookingManagerProvider>(
          builder: (context, bookingManager, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(context.getAdaptiveSize(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.getHeight(24)),
                  // Title
                  Text(
                    AppLocalizations.of(context)!.rateYourExperience,
                    style: AppTextStyles.title2(context),
                  ),
                  SizedBox(height: context.getHeight(24)),

                  // Rating Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.rating,
                        style: AppTextStyles.subTitle(context),
                      ),
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: context.getAdaptiveSize(32),
                        itemPadding: EdgeInsets.symmetric(
                            horizontal: context.getAdaptiveSize(4)),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: AppColors.rating,
                        ),
                        onRatingUpdate: (rating) {
                          bookingManager.setRating(rating);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: context.getHeight(8)),

                  // Comment Section
                  Text(
                    AppLocalizations.of(context)!.comment,
                    style: AppTextStyles.subTitle(context),
                  ),
                  SizedBox(height: context.getHeight(8)),
                  TextField(
                    controller: bookingManager.commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.commentHint,
                      hintStyle: AppTextStyles.text(context)
                          .copyWith(color: AppColors.hintColor),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(context.getAdaptiveSize(8)),
                      ),
                      contentPadding:
                          EdgeInsets.all(context.getAdaptiveSize(12)),
                    ),
                  ),
                  SizedBox(height: context.getHeight(16)),

                  // Error Message (if any)
                  if (bookingManager.ratingError != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: context.getHeight(8)),
                      child: Text(
                        bookingManager.ratingError!,
                        style: AppTextStyles.text(context)
                            .copyWith(color: Colors.red),
                      ),
                    ),

                  SizedBox(
                    height: context.getHeight(100),
                  ),
                  // Submit Button
                  PrimaryButton(
                    text: AppLocalizations.of(context)!.submit,
                    onPressed: () async {
                      await bookingManager.rateService(
                        context,
                        serviceId,
                        bookingManager.rating.toInt(),
                      );
                    },
                    isLoading: bookingManager.isRatingSubmitting,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

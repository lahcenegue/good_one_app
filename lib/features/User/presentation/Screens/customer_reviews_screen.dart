import 'package:flutter/material.dart';

import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/user_avatar.dart';
import 'package:good_one_app/Features/User/Models/contractor.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomerReviewsScreen extends StatelessWidget {
  final Contractor contractor;
  final ScrollController _scrollController = ScrollController();

  CustomerReviewsScreen({
    super.key,
    required this.contractor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${AppLocalizations.of(context)!.allReviews} (${contractor.ratings!.length})",
          style: AppTextStyles.appBarTitle(context),
        ),
      ),
      body: Column(
        children: [
          _buildRatingSummary(context),
          Expanded(
            child: _buildReviewsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context) {
    final averageRating = contractor.rating!.rating;
    final totalReviews = contractor.rating!.timesRated;

    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: AppTextStyles.title2(context).copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/5',
                    style: AppTextStyles.text(context).copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Text(
                '$totalReviews ${AppLocalizations.of(context)!.reviews}',
                style: AppTextStyles.text(context).copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(width: context.getWidth(24)),
          Expanded(
            child: _buildRatingBars(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBars(BuildContext context) {
    // Calculate rating distribution
    Map<int, int> ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var rating in contractor.ratings!) {
      ratingCounts[rating.rate] = (ratingCounts[rating.rate] ?? 0) + 1;
    }

    return Column(
      children: [
        for (var i = 5; i >= 1; i--)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.getHeight(2)),
            child: Row(
              children: [
                Text(
                  '$i',
                  style: AppTextStyles.text(context),
                ),
                Icon(Icons.star, size: 14, color: Colors.amber),
                SizedBox(width: context.getWidth(8)),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: contractor.ratings!.isEmpty
                          ? 0
                          : (ratingCounts[i] ?? 0) / contractor.ratings!.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: 8,
                    ),
                  ),
                ),
                SizedBox(width: context.getWidth(8)),
                Text(
                  '${ratingCounts[i]}',
                  style: AppTextStyles.text(context).copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsList(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.all(context.getWidth(16)),
      itemCount: contractor.ratings!.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: context.getHeight(16)),
      itemBuilder: (context, index) {
        final review = contractor.ratings![index];
        return _buildReviewItem(context, review);
      },
    );
  }

  Widget _buildReviewItem(BuildContext context, RatingDetail review) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(16)),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D1D1)),
        borderRadius: BorderRadius.circular(context.getWidth(12)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                picture: review.reviewer.picture,
                size: context.getWidth(48),
              ),
              SizedBox(width: context.getWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            review.reviewer.fullName,
                            style: AppTextStyles.title2(context),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: context.getWidth(16),
                            ),
                            SizedBox(width: context.getWidth(4)),
                            Text(
                              '${review.rate}.0',
                              style: AppTextStyles.text(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (review.message.isNotEmpty) ...[
                      SizedBox(height: context.getHeight(12)),
                      Text(
                        review.message,
                        style: AppTextStyles.text(context),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

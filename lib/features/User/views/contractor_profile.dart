import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/presentation/Widgets/Buttons/secondary_button.dart';
import 'package:good_one_app/Core/presentation/resources/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Core/Navigation/app_routes.dart';
import '../../../Core/infrastructure/api/api_endpoints.dart';
import '../../../Core/presentation/Theme/app_text_styles.dart';
import '../../../Core/presentation/Widgets/user_avatar.dart';
import '../../../Core/presentation/resources/app_assets.dart';
import '../../../Providers/user_manager_provider.dart';
import '../Widgets/auth_required_dialog.dart';
import '../Widgets/gallery_viewer_page.dart';
import '../models/contractor.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'calender_booking_screen.dart';
import 'customer_reviews_screen.dart';

class ContractorProfile extends StatelessWidget {
  final Contractor contractor;
  const ContractorProfile({
    super.key,
    required this.contractor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagerProvider>(
      builder: (context, userManager, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.profile,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.getWidth(20),
                vertical: context.getHeight(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContractorInfo(context),
                  SizedBox(height: context.getHeight(20)),
                  _buildChecked(context),
                  SizedBox(height: context.getHeight(20)),
                  _buildServiceInfo(context),
                  SizedBox(height: context.getHeight(20)),
                  _buildServiceDescription(context),
                  SizedBox(height: context.getHeight(20)),
                  _buildServiceGallery(context),
                  SizedBox(height: context.getHeight(20)),
                  _buildCostomersReviews(context),
                  SizedBox(height: context.getHeight(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallSecondaryButton(
                        text: 'message',
                        onPressed: () {
                          if (userManager.token == null) {
                            showDialog(
                              context: context,
                              builder: (context) => const AuthRequiredDialog(),
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.chat,
                              arguments: {
                                'otherUserId': contractor.id.toString(),
                                'otherUserName': contractor.fullName,
                              },
                            );
                          }
                        },
                      ),
                      SmallPrimaryButton(
                        text: 'Book',
                        onPressed: () {
                          if (userManager.token == null) {
                            showDialog(
                              context: context,
                              builder: (context) => const AuthRequiredDialog(),
                            );
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CalenderBookingScreen()));
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: context.getHeight(40)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContractorInfo(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          picture: contractor.picture,
          size: context.getWidth(100),
        ),
        SizedBox(width: context.getWidth(10)),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    contractor.fullName,
                    style: AppTextStyles.text(context),
                  ),
                  SizedBox(width: context.getWidth(5)),
                  contractor.securityCheck == 0
                      ? Image.asset(
                          AppAssets.security,
                          width: context.getWidth(15),
                        )
                      : SizedBox(),
                ],
              ),
              Text(
                contractor.service,
                style: AppTextStyles.title2(context),
              ),
              Text(
                '${contractor.costPerHour} \$',
                style: AppTextStyles.price(context),
              ),
              Row(
                children: [
                  Image.asset(AppAssets.location),
                  Text(
                    contractor.location,
                    style: AppTextStyles.text(context),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChecked(BuildContext context) {
    if (contractor.verifiedLiscence == 0) {
      return SizedBox(
        child: Row(
          children: [
            Image.asset(
              AppAssets.lisence,
              width: context.getWidth(20),
            ),
            Expanded(
              child: Text(
                'Confird ${contractor.service} (With Lisence)',
                style: AppTextStyles.textButton(context),
              ),
            )
          ],
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildServiceInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _serviceBox(
          context,
          AppAssets.experience,
          contractor.yearsOfExperience.toString(),
          'Years exp',
        ),
        _serviceBox(
          context,
          AppAssets.rating,
          contractor.ratings.length.toString(),
          'Rating',
        ),
        _serviceBox(
          context,
          AppAssets.clients,
          contractor.orders.toString(),
          'Clients',
        ),
        _serviceBox(
          context,
          AppAssets.distance,
          contractor.location,
          'Direction',
        ),
      ],
    );
  }

  Widget _serviceBox(
    BuildContext context,
    String icon,
    String info,
    String title,
  ) {
    return Column(
      children: [
        Container(
          width: context.getWidth(72),
          height: context.getWidth(72),
          decoration: BoxDecoration(
            color: AppColors.dimGray,
            borderRadius: BorderRadius.circular(context.getWidth(8)),
          ),
          child: Center(
            child: Image.asset(
              icon,
              width: context.getWidth(28),
            ),
          ),
        ),
        SizedBox(height: context.getHeight(5)),
        SizedBox(
          width: context.getWidth(72),
          child: Text(
            info,
            textAlign: TextAlign.center,
            style: AppTextStyles.title2(context),
          ),
        ),
        SizedBox(height: context.getHeight(5)),
        Text(
          title,
          style: AppTextStyles.text(context),
        ),
      ],
    );
  }

  Widget _buildServiceDescription(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: AppTextStyles.title2(context),
        ),
        SizedBox(height: context.getHeight(10)),
        Text(
          contractor.about,
          style: AppTextStyles.text(context),
        ),
      ],
    );
  }

  Widget _buildServiceGallery(BuildContext context) {
    if (contractor.gallery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo albums',
              style: AppTextStyles.title2(context),
            ),
            TextButton(
              onPressed: () => _showFullGallery(context, 0),
              child: Text(
                'See all',
                style: AppTextStyles.textButton(context),
              ),
            ),
          ],
        ),
        SizedBox(
          height: context.getHeight(280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  if (contractor.gallery.isNotEmpty)
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => _showFullGallery(context, 0),
                        child: Container(
                          height: context.getHeight(280),
                          margin: EdgeInsets.only(right: context.getWidth(4)),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(context.getWidth(12)),
                            child: Image.network(
                              '${ApiEndpoints.imageBaseUrl}/${contractor.gallery[0].image}',
                              fit: BoxFit.cover,
                              errorBuilder: _errorBuilder,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (contractor.gallery.length > 1)
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          for (var i = 1;
                              i < contractor.gallery.length.clamp(0, 4);
                              i++)
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showFullGallery(context, i),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    bottom: i < 3 ? 4 : 0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      '${ApiEndpoints.imageBaseUrl}/${contractor.gallery[i].image}',
                                      fit: BoxFit.cover,
                                      errorBuilder: _errorBuilder,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _errorBuilder(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
      ),
    );
  }

  void _showFullGallery(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryViewerPage(
          gallery: contractor.gallery,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  Widget _buildCostomersReviews(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer reviews',
              style: AppTextStyles.title2(context),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CustomerReviewsScreen(contractor: contractor),
                  ),
                );
              },
              child: Text(
                'See all',
                style: AppTextStyles.textButton(context),
              ),
            ),
          ],
        ),
        SizedBox(height: context.getHeight(10)),
        if (contractor.ratings.isEmpty) const SizedBox.shrink(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: contractor.ratings.length.clamp(0, 3),
          separatorBuilder: (context, index) =>
              SizedBox(height: context.getHeight(20)),
          itemBuilder: (context, index) {
            final review = contractor.ratings[index];
            return _buildReviewItem(context, review);
          },
        ),
      ],
    );
  }

  Widget _buildReviewItem(BuildContext context, RatingDetail review) {
    return Container(
      padding: EdgeInsets.all(context.getWidth(12)),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFD1D1D1)),
        borderRadius: BorderRadius.circular(context.getWidth(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                picture: review.user.picture,
                size: context.getWidth(40),
              ),
              SizedBox(width: context.getWidth(10)),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.user.fullName,
                    style: AppTextStyles.title2(context),
                  ),
                  Text(
                    _formatDate(review.updatedAt),
                    style: AppTextStyles.text(context).copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: context.getWidth(20),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '(${review.rate}.0)',
                    style: AppTextStyles.text(context),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: context.getHeight(10)),
          Text(
            review.message,
            textAlign: TextAlign.justify,
            style: AppTextStyles.text(context),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }
}

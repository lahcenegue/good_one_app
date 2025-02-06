import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';

import '../../../Core/presentation/Theme/app_text_styles.dart';
import '../../../Core/presentation/Widgets/user_avatar.dart';
import '../../../Core/presentation/resources/app_assets.dart';
import '../models/contractor.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContractorProfile extends StatelessWidget {
  final Contractor contractor;
  const ContractorProfile({
    super.key,
    required this.contractor,
  });

  @override
  Widget build(BuildContext context) {
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
              _buildInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(
    BuildContext context,
  ) {
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
              Text(
                contractor.fullName,
                style: AppTextStyles.text(context),
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
              )
            ],
          ),
        ),
      ],
    );
  }
}

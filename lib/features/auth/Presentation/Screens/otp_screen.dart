import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/Both/auth_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.otpVerification,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(context.getAdaptiveSize(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.getHeight(50)),
                Text(
                  AppLocalizations.of(context)!.enterVerificationCode,
                  style: AppTextStyles.title2(context),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: context.getHeight(5)),
                Text(
                  AppLocalizations.of(context)!.otpSent,
                  style: AppTextStyles.text(context),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: context.getHeight(20)),
                _buildPinput(context, auth),
                SizedBox(height: context.getHeight(40)),
                PrimaryButton(
                  text: AppLocalizations.of(context)!.checkCode,
                  onPressed: () {
                    auth.checkOtp();
                  },
                ),
                _buildFooter(context, auth),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinput(
    BuildContext context,
    AuthProvider auth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.screenWidth,
          child: Pinput(
            length: 6,
            onCompleted: (value) async {
              auth.getOtpCode(value);
            },
          ),
        ),
        SizedBox(height: context.getHeight(5)),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            '00:${auth.seconds}',
            style: AppTextStyles.text(context),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AuthProvider auth,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (auth.seconds == 0)
          TextButton(
            onPressed: () async {
              auth.sendOtp();
            },
            child: Text(
              AppLocalizations.of(context)!.resendCode,
              style: AppTextStyles.textButton(context),
            ),
          ),
      ],
    );
  }
}

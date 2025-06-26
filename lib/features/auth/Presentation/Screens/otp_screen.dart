import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Providers/Both/auth_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/l10n/app_localizations.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Ensure timer is running when screen is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          auth.ensureTimerIsRunning();
        });
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
                  isLoading: auth.isLoading,
                  onPressed: (auth.otpCode != null &&
                          auth.otpCode!.length == 6 &&
                          !auth.isLoading)
                      ? () => auth.checkOtp(context)
                      : () {},
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
              auth.setOtpCode(value);
            },
            onChanged: (value) {
              if (value.length == 6) {
                auth.setOtpCode(value);
              } else {
                //auth.setOtpCode(null);
              }
            },
          ),
        ),
        SizedBox(height: context.getHeight(5)),
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            '00:${auth.seconds.toString().padLeft(2, '0')}',
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
    return Column(
      children: [
        SizedBox(height: context.getHeight(20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (auth.isTimerExpired) // Use the new getter
              TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        await auth.sendOtp();
                      },
                child: Text(
                  AppLocalizations.of(context)!.resendCode,
                  style: AppTextStyles.textButton(context),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

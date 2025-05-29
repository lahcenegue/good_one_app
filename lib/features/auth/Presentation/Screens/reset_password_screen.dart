import 'dart:async';
import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Presentation/Theme/app_text_styles.dart';
import 'package:good_one_app/Core/Presentation/Widgets/Buttons/primary_button.dart';
import 'package:good_one_app/Core/Utils/size_config.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Features/Auth/Models/reset_password_request.dart';
import 'package:good_one_app/Features/Auth/Services/auth_api.dart';
import 'package:good_one_app/Providers/Both/auth_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _error;
  String? _otpCode;

  Timer? _timer;
  int _seconds = 60;

  // Validation states
  String? _passwordError;
  String? _confirmPasswordError;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void _setError(String? error) {
    if (mounted) {
      setState(() {
        _error = error;
      });
    }
  }

  bool _validateForm() {
    bool isValid = true;

    // Validate OTP
    if (_otpCode == null || _otpCode!.length != 6) {
      setState(() {
        _otpError = AppLocalizations.of(context)!.otpRequired;
      });
      isValid = false;
    } else {
      setState(() {
        _otpError = null;
      });
    }

    // Validate password
    if (_newPasswordController.text.isEmpty) {
      setState(() {
        _passwordError = AppLocalizations.of(context)!.passwordRequired;
      });
      isValid = false;
    } else if (_newPasswordController.text.length < 6) {
      setState(() {
        _passwordError = AppLocalizations.of(context)!.passwordTooShort;
      });
      isValid = false;
    } else {
      setState(() {
        _passwordError = null;
      });
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError =
            AppLocalizations.of(context)!.confirmPasswordRequired;
      });
      isValid = false;
    } else if (_confirmPasswordController.text != _newPasswordController.text) {
      setState(() {
        _confirmPasswordError =
            AppLocalizations.of(context)!.passwordsDoNotMatch;
      });
      isValid = false;
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }

    return isValid;
  }

  Future<void> _resetPassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!_validateForm()) {
      return;
    }

    try {
      _setLoading(true);
      _setError(null);

      final request = ResetPasswordRequest(
        email: authProvider.forgotPasswordEmailController.text.trim(),
        otp: _otpCode!,
        password: _newPasswordController.text,
      );

      final response = await AuthApi.resetPassword(request);

      if (response.success) {
        // Clear the forgot password email controller
        authProvider.forgotPasswordEmailController.clear();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.passwordResetSuccess ??
                      'Password reset successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Navigate back to login with a small delay to show the success message
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await NavigationService.navigateToAndReplace(AppRoutes.login);
        }
      } else {
        _setError(response.error);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _resendOtp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      _setLoading(true);
      _setError(null);

      final response = await AuthApi.sendOtp(
        email: authProvider.forgotPasswordEmailController.text.trim(),
      );

      if (response.success) {
        _startTimer();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.otpSent),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _setError(response.error);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.resetPassword,
              style: AppTextStyles.appBarTitle(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(context.getAdaptiveSize(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.getHeight(30)),
                Text(
                  AppLocalizations.of(context)!.resetYourPassword,
                  style: AppTextStyles.title2(context),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: context.getHeight(5)),
                Text(
                  AppLocalizations.of(context)!.enterOtpAndNewPassword,
                  style: AppTextStyles.text(context),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: context.getHeight(10)),
                Text(
                  'Email: ${authProvider.forgotPasswordEmailController.text}',
                  style: AppTextStyles.text(context).copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: context.getHeight(30)),

                // OTP Section
                Text(
                  AppLocalizations.of(context)!.verificationCode,
                  style: AppTextStyles.subTitle(context),
                ),
                SizedBox(height: context.getHeight(10)),
                _buildPinput(),
                if (_otpError != null) ...[
                  SizedBox(height: context.getHeight(5)),
                  Text(
                    _otpError!,
                    style: AppTextStyles.text(context).copyWith(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
                SizedBox(height: context.getHeight(30)),

                // New Password Section
                Text(
                  AppLocalizations.of(context)!.newPassword,
                  style: AppTextStyles.subTitle(context),
                ),
                SizedBox(height: context.getHeight(10)),
                _buildPasswordField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  hintText: AppLocalizations.of(context)!.enterNewPassword,
                  errorText: _passwordError,
                ),
                SizedBox(height: context.getHeight(20)),

                // Confirm Password Section
                Text(
                  AppLocalizations.of(context)!.confirmPassword,
                  style: AppTextStyles.subTitle(context),
                ),
                SizedBox(height: context.getHeight(10)),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  hintText: AppLocalizations.of(context)!.confirmNewPassword,
                  errorText: _confirmPasswordError,
                ),

                // Error Display
                if (_error != null) ...[
                  SizedBox(height: context.getHeight(15)),
                  Container(
                    padding: EdgeInsets.all(context.getAdaptiveSize(12)),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: context.getAdaptiveSize(20),
                        ),
                        SizedBox(width: context.getWidth(8)),
                        Expanded(
                          child: Text(
                            _error!,
                            style: AppTextStyles.text(context).copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: context.getHeight(40)),
                PrimaryButton(
                  text: AppLocalizations.of(context)!.resetPassword,
                  isLoading: _isLoading,
                  onPressed: _resetPassword,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.screenWidth,
          child: Pinput(
            length: 6,
            onCompleted: (value) {
              setState(() {
                _otpCode = value;
                _otpError = null; // Clear error when OTP is entered
              });
            },
            onChanged: (value) {
              if (value.length == 6) {
                setState(() {
                  _otpCode = value;
                  _otpError = null;
                });
              }
            },
          ),
        ),
        SizedBox(height: context.getHeight(5)),
        Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(height: context.getHeight(10)),
                  Text(
                    '00:${_seconds.toString().padLeft(2, '0')}',
                    style: AppTextStyles.text(context),
                  ),
                ],
              ),
              _buildResendButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String hintText,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: (value) {
            // Clear errors when user types
            if (controller == _newPasswordController &&
                _passwordError != null) {
              setState(() {
                _passwordError = null;
              });
            } else if (controller == _confirmPasswordController &&
                _confirmPasswordError != null) {
              setState(() {
                _confirmPasswordError = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? Colors.red
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.blue,
                width: 2,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: context.getHeight(5)),
          Text(
            errorText,
            style: AppTextStyles.text(context).copyWith(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResendButton() {
    if (_seconds == 0) {
      return TextButton(
        onPressed: _isLoading ? null : _resendOtp,
        child: Text(
          AppLocalizations.of(context)!.resendCode,
          style: AppTextStyles.textButton(context),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

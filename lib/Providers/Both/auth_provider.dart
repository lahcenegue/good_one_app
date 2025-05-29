import 'dart:async';

import 'package:flutter/material.dart';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Features/Auth/Models/check_request.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Features/Auth/Models/register_request.dart';
import 'package:good_one_app/Features/Auth/Services/auth_api.dart';
import 'package:good_one_app/Features/Auth/Models/auth_request.dart';
import 'package:good_one_app/Features/Auth/Models/auth_model.dart';
import 'package:good_one_app/Features/Auth/Services/token_manager.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthProvider with ChangeNotifier {
  bool _isInitialized = false;

  // Authentication State
  AuthModel? _authData;
  bool _isLoading = false;
  String? _error;

  Timer? _timer;
  int _seconds = 60;
  String? _otpCode;

  String? selectedCountry;
  String? selectedCity;

  // Form Controllers
  // final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  // final GlobalKey<FormState> registrationFormKey = GlobalKey<FormState>();
  // final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController forgotPasswordEmailController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  //Image
  File? _selectedImage;
  String? _imageError;
  final ImagePicker _picker = ImagePicker();

  AuthProvider() {
    initialize();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuth => _authData?.accessToken != null;
  String? get token => _authData?.accessToken;
  String? get error => _error;
  int get seconds => _seconds;
  String? get otpCode => _otpCode;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  File? get selectedImage => _selectedImage;
  String? get imageError => _imageError;

  List<String> get availableCities {
    return selectedCountry != null
        ? AppConfig.citiesByCountry[selectedCountry] ?? []
        : [];
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    TokenManager.instance.tokenStream.listen((auth) {
      _authData = auth;
    });
    _isInitialized = true;
    notifyListeners();
  }

  // UI Methods
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  String? validateFullName(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.fullNameRequired;
    }
    return null;
  }

  String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailRequired;
    }
    if (!value.contains('@')) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    return null;
  }

  String? validatePhone(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.phoneRequired;
    }
    // Add your phone validation logic here
    return null;
  }

  String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.passwordRequired;
    }
    if (value.length < AppConfig.minPasswordLength) {
      return AppLocalizations.of(context)!.passwordTooShort;
    }
    return null;
  }

  String? validateConfirmPassword(
      BuildContext context, String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.confirmPasswordRequired;
    }
    if (value != password) {
      return AppLocalizations.of(context)!.passwordsDoNotMatch;
    }
    return null;
  }

  void setCountry(String? country) {
    selectedCountry = country;
    selectedCity = null;
    notifyListeners();
  }

  void setCity(String? city) {
    selectedCity = city;
    notifyListeners();
  }

  void getOtpCode(String otpCode) {
    _otpCode = otpCode;
    notifyListeners();
  }

// Authentication Methods
  Future<void> login(BuildContext context) async {
    print('======Login function ======');

    try {
      _setLoading(true);
      _clearErrors();

      final [accountType, deviceToken] = await Future.wait([
        StorageManager.getString(StorageKeys.accountTypeKey),
        StorageManager.getString(StorageKeys.fcmTokenKey),
      ]);

      final request = AuthRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
        deviceToken: deviceToken!,
      );

      final response = await AuthApi.login(request);

      if (response.success) {
        _authData = response.data;
        _clearFormData();
        await _saveAuthData();

        _setLoading(false);

        if (accountType == AppConfig.service) {
          await NavigationService.navigateToAndReplace(AppRoutes.workerMain);
        } else {
          await NavigationService.navigateToAndReplace(AppRoutes.userMain);
        }
      } else if (response.error == 'Account is not verified') {
        await sendOtp();
      } else {
        _error = response.error;
        notifyListeners();
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      await TokenManager.instance.initialize();
      _authData = TokenManager.instance.currentAuth;
      notifyListeners();
      return _authData != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> register(BuildContext context) async {
    try {
      _setLoading(true);
      _clearErrors();

      final [accountType, deviceToken] = await Future.wait([
        StorageManager.getString(StorageKeys.accountTypeKey),
        StorageManager.getString(StorageKeys.fcmTokenKey),
      ]);

      if (accountType == null) {
        NavigationService.navigateToAndReplace(AppRoutes.accountSelection);
      }

      if (accountType == AppConfig.service) {
        if (selectedCountry == null || selectedCity == null) {
          if (context.mounted) {
            _error = AppLocalizations.of(context)!.locationRequired;
          }

          notifyListeners();
          return;
        }
      }

      final request = RegisterRequest(
        image: _selectedImage,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        type: accountType!,
        deviceToken: deviceToken ?? '',
        country: accountType == AppConfig.service ? selectedCountry : null,
        city: accountType == AppConfig.service ? selectedCity : null,
      );

      final response = await AuthApi.register(request);
      if (response.success) {
        await NavigationService.navigateToAndReplace(AppRoutes.otpScreen);
      } else {
        _error = response.error;
        notifyListeners();
      }

      // if (response.success) {
      //   _authData = response.data;
      //   _clearFormData();
      //   await _saveAuthData();

      //   _setLoading(false);
      //   if (accountType == AppConfig.service) {
      //     await NavigationService.navigateToAndReplace(AppRoutes.workerMain);
      //   } else {
      //     await NavigationService.navigateToAndReplace(
      //       AppRoutes.userMain,
      //       arguments: 0,
      //     );
      //   }
      // } else {
      //   _error = response.error;
      //   notifyListeners();
      // }
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      _setLoading(true);
      _clearErrors();
      _clearFormData();

      clearData();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  //TODO
  Future<void> deleteAccount() async {}

  Future<void> sendOtp({bool isForPasswordReset = false}) async {
    try {
      final email = isForPasswordReset
          ? forgotPasswordEmailController.text.trim()
          : emailController.text.trim();

      final response = await AuthApi.sendOtp(email: email);
      if (response.success) {
        startTimer();
        if (isForPasswordReset) {
          await NavigationService.navigateTo(AppRoutes.resetPassword);
        } else {
          await NavigationService.navigateTo(AppRoutes.otpScreen);
        }
      } else {
        _error = response.error;
        notifyListeners();
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> resendOtpForPasswordReset() async {
    try {
      final response = await AuthApi.sendOtp(
        email: forgotPasswordEmailController.text.trim(),
      );
      if (response.success) {
        startTimer();
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> checkOtp() async {
    try {
      _setLoading(true);
      _clearErrors();

      final accountType =
          await StorageManager.getString(StorageKeys.accountTypeKey);

      final request = CheckRequest(
        email: emailController.text.trim(),
        otp: _otpCode!,
      );

      final response = await AuthApi.checkOtp(request);

      if (response.success) {
        _authData = response.data;
        _clearFormData();
        await _saveAuthData();
        _setLoading(false);

        if (accountType == AppConfig.service) {
          await NavigationService.navigateToAndReplace(AppRoutes.workerMain);
        } else {
          await NavigationService.navigateToAndReplace(AppRoutes.userMain);
        }
      } else {
        _error = response.error;
        notifyListeners();
      }
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearData() async {
    await StorageManager.remove(StorageKeys.tokenKey);
    await StorageManager.remove(StorageKeys.accountTypeKey);
    await StorageManager.remove(StorageKeys.refreshTokenKey);

    await TokenManager.instance.clearToken();
  }

  // Private Helper Methods
  Future<void> pickImage(BuildContext context, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _imageError = null;
        notifyListeners();
      }
    } catch (e) {
      if (context.mounted) {
        _imageError = AppLocalizations.of(context)!.generalError;
      }

      notifyListeners();
    }
  }

  Future<void> _saveAuthData() async {
    try {
      await TokenManager.instance.setToken(_authData!);
    } catch (e) {
      throw Exception('Failed to save authentication data');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearErrors() {
    _imageError = null;
    _error = null;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _error = error.toString();
    notifyListeners();
  }

  void startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        _seconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
  }

  // String? _getLocalizedErrorMessage(String? errorCode,
  //     [BuildContext? context]) {
  //   if (context == null) return null;

  //   switch (errorCode) {
  //     case 'auth_error':
  //       return AppLocalizations.of(context)!.authError;
  //     case 'network_error':
  //       return AppLocalizations.of(context)!.networkError;
  //     case 'storage_error':
  //       return AppLocalizations.of(context)!.storageError;
  //     case 'invalid_credentials':
  //       return AppLocalizations.of(context)!.invalidCredentials;
  //     case 'invalid_response':
  //       return AppLocalizations.of(context)!.serverError;
  //     default:
  //       return _failure?.message ?? AppLocalizations.of(context)!.generalError;
  //   }
  // }

  void _clearFormData() {
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    _selectedImage = null;
    _otpCode = null;
    fullNameController.clear();
    emailController.clear();
    forgotPasswordEmailController.clear();
    passwordController.clear();
    phoneController.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    forgotPasswordEmailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

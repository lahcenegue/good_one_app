import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Data/Models/auth_model.dart';
import '../Core/Utils/storage_keys.dart';
import '../Core/Utils/error_handling/error_handler.dart';
import '../Core/Utils/error_handling/failures.dart';
import '../Core/Navigation/app_routes.dart';
import '../Core/Navigation/navigation_service.dart';

import '../Core/infrastructure/storage/storage_manager.dart';
import '../Core/presentation/resources/app_strings.dart';
import '../Features/auth/Services/auth_api.dart';
import '../Features/auth/Services/token_manager.dart';
import '../Features/auth/models/auth_request.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Features/auth/models/register_request.dart';
import 'user_manager_provider.dart';

class AuthProvider with ChangeNotifier {
  bool _isInitialized = false;
  // Authentication State
  AuthModel? _authData;
  bool _isLoading = false;
  Failure? _failure;
  String? _error;

  String? selectedCountry;
  String? selectedCity;

  List<String> countries = [
    'Canada',
    'United States',
  ];

  Map<String, List<String>> citiesByCountry = {
    'United States': [
      'New York',
      'Los Angeles',
      'Chicago',
      'Houston',
      'Phoenix',
    ],
    'Canada': [
      'Toronto',
      'Vancouver',
      'Montreal',
      'Calgary',
      'Ottawa',
    ],
  };

  // Form Controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> registrationFormKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
  Failure? get failure => _failure;
  String? get error => _error;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  File? get selectedImage => _selectedImage;
  String? get imageError => _imageError;
  List<String> get availableCities {
    return selectedCountry != null
        ? citiesByCountry[selectedCountry] ?? []
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
    if (value.length < 4) {
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

// Authentication Methods
  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final accountType = StorageManager.getString(StorageKeys.accountTypeKey);

    try {
      _setLoading(true);
      _clearErrors();

      final request = AuthRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
        deviceToken: StorageManager.getString(StorageKeys.fcmTokenKey)!,
      );

      debugPrint('The Device token fron login ${request.deviceToken}');

      final response = await AuthApi.login(request);

      if (response.success) {
        _authData = response.data;
        await _saveAuthData();

        // Update UserManagerProvider with new token
        if (context.mounted) {
          await context
              .read<UserManagerProvider>()
              .updateToken(_authData!.accessToken);
        }

        _setLoading(false);

        if (accountType == AppStrings.service) {
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
    if (!registrationFormKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      _imageError = AppLocalizations.of(context)!.imageRequired;
      notifyListeners();
      return;
    }

    final accountType = StorageManager.getString(StorageKeys.accountTypeKey);

    if (accountType == AppStrings.service) {
      if (selectedCountry == null || selectedCity == null) {
        _error = AppLocalizations.of(context)!.locationRequired;
        notifyListeners();
        return;
      }
    }

    try {
      _setLoading(true);
      _clearErrors();

      final request = RegisterRequest(
        image: _selectedImage!,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        type: accountType!,
        deviceToken: StorageManager.getString(StorageKeys.fcmTokenKey)!,
        country: accountType == AppStrings.service ? selectedCountry : null,
        city: accountType == AppStrings.service ? selectedCity : null,
      );

      debugPrint('The Device token fron register ${request.deviceToken}');

      final response = await AuthApi.register(request);

      if (response.success) {
        _authData = response.data;
        await _saveAuthData();

        if (context.mounted) {
          await context
              .read<UserManagerProvider>()
              .updateToken(_authData!.accessToken);
        }

        _setLoading(false);
        if (accountType == AppStrings.service) {
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

  Future<void> logout(BuildContext context) async {
    try {
      _setLoading(true);
      _clearErrors();

      await TokenManager.instance.clearToken();

      // Clear UserManagerProvider data
      if (context.mounted) {
        await context.read<UserManagerProvider>().clearData();
      }

      _clearFormData();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
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
      throw const AuthFailure(
        message: 'Failed to save authentication data',
        code: 'storage_error',
      );
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearErrors() {
    _imageError = null;
    _error = null;
    _failure = null;
    notifyListeners();
  }

  void _handleError(dynamic error, [BuildContext? context]) {
    if (error is AuthFailure) {
      _failure = error;
      _error = _getLocalizedErrorMessage(error.code, context);
    } else {
      _failure = ErrorHandler.handleException(error);
      _error = _getLocalizedErrorMessage(_failure?.code, context);
    }

    notifyListeners();
  }

  String? _getLocalizedErrorMessage(String? errorCode,
      [BuildContext? context]) {
    if (context == null) return null;

    switch (errorCode) {
      case 'auth_error':
        return AppLocalizations.of(context)!.authError;
      case 'network_error':
        return AppLocalizations.of(context)!.networkError;
      case 'storage_error':
        return AppLocalizations.of(context)!.storageError;
      case 'invalid_credentials':
        return AppLocalizations.of(context)!.invalidCredentials;
      case 'invalid_response':
        return AppLocalizations.of(context)!.serverError;
      default:
        return _failure?.message ?? AppLocalizations.of(context)!.generalError;
    }
  }

  void _clearFormData() {
    emailController.clear();
    passwordController.clear();
    _obscurePassword = true;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

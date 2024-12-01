import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Data/Models/auth_model.dart';
import '../Core/Constants/storage_keys.dart';
import '../Core/Errors/error_handler.dart';
import '../Core/Errors/failures.dart';
import '../Core/Utils/navigation_service.dart';

import '../Features/auth/Services/auth_api.dart';
import '../Features/auth/models/auth_request.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Features/auth/models/register_request.dart';

class AuthProvider with ChangeNotifier {
  // Authentication State
  AuthModel? _authData;
  bool _isLoading = false;
  Failure? _failure;
  String? _error;

  //BuildContext? _context;

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
    if (value.length < 6) {
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

// Authentication Methods
  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      _setLoading(true);
      _clearErrors();

      final request = AuthRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await AuthApi.login(request);

      if (response.success) {
        _authData = response.data;
        await _saveAuthData();
        await NavigationService.navigateToAndReplace(AppRoutes.userHome);
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
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('authData')) return false;

      final authData = json.decode(prefs.getString('authData')!);
      _authData = AuthModel.fromJson(authData);
      notifyListeners();
      return true;
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

    try {
      _setLoading(true);
      _clearErrors();

      final sharedPrefs = await SharedPreferences.getInstance();
      final accountType = sharedPrefs.getString(StorageKeys.accountTypeKey);

      print(accountType);

      final request = RegisterRequest(
        image: _selectedImage!,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        type: accountType!,
      );

      final response = await AuthApi.register(request);

      if (response.success) {
        _authData = response.data;
        await _saveAuthData();
        NavigationService.navigateToAndReplace(AppRoutes.userHome);
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

  Future<void> logout() async {
    try {
      _setLoading(true);
      _clearErrors();

      _authData = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authData');

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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authData', json.encode(_authData!.toJson()));
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

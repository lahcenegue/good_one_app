import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Data/Models/auth_model.dart';
import '../Core/Errors/error_handler.dart';
import '../Core/Errors/failures.dart';
import '../Core/Utils/navigation_service.dart';

import '../features/auth/Services/auth_api.dart';
import '../features/auth/models/auth_request.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../features/auth/models/register_request.dart';

class AuthProvider with ChangeNotifier {
  // Authentication State
  AuthModel? _authData;
  bool _isLoading = false;
  Failure? _failure;
  String? _error;

  BuildContext? _context;

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
  void setContext(BuildContext context) {
    _context = context;
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  String? validateFullName(String? value) {
    if (_context == null) return null;

    if (value == null || value.isEmpty) {
      return AppLocalizations.of(_context!)!.fullNameRequired;
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (_context == null) return null;

    if (value == null || value.isEmpty) {
      return AppLocalizations.of(_context!)!.emailRequired;
    }
    if (!value.contains('@')) {
      return AppLocalizations.of(_context!)!.invalidEmail;
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (_context == null) return null;

    if (value == null || value.isEmpty) {
      return AppLocalizations.of(_context!)!.phoneRequired;
    }
    // Add your phone validation logic here
    return null;
  }

  String? validatePassword(String? value) {
    if (_context == null) return null;

    if (value == null || value.isEmpty) {
      return AppLocalizations.of(_context!)!.passwordRequired;
    }
    if (value.length < 6) {
      return AppLocalizations.of(_context!)!.passwordTooShort;
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String password) {
    if (_context == null) return null;

    if (value == null || value.isEmpty) {
      return AppLocalizations.of(_context!)!.confirmPasswordRequired;
    }
    if (value != password) {
      return AppLocalizations.of(_context!)!.passwordsDoNotMatch;
    }
    return null;
  }

// Authentication Methods
  Future<void> login() async {
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

  Future<void> register() async {
    if (!registrationFormKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      _imageError = _context != null
          ? AppLocalizations.of(_context!)!.imageRequired
          : 'Profile picture is required';
      notifyListeners();
      return;
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
  Future<void> pickImage(ImageSource source) async {
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
      _imageError = _context != null
          ? AppLocalizations.of(_context!)!.generalError
          : 'Failed to pick image';
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

  void _handleError(dynamic error) {
    if (_context == null) return;

    if (error is AuthFailure) {
      _failure = error;
      _error = _getLocalizedErrorMessage(error.code);
    } else {
      _failure = ErrorHandler.handleException(error);
      _error = _getLocalizedErrorMessage(_failure?.code);
    }

    notifyListeners();
  }

  String? _getLocalizedErrorMessage(String? errorCode) {
    if (_context == null) return null;

    switch (errorCode) {
      case 'auth_error':
        return AppLocalizations.of(_context!)!.authError;
      case 'network_error':
        return AppLocalizations.of(_context!)!.networkError;
      case 'storage_error':
        return AppLocalizations.of(_context!)!.storageError;
      case 'invalid_credentials':
        return AppLocalizations.of(_context!)!.invalidCredentials;
      case 'invalid_response':
        return AppLocalizations.of(_context!)!.serverError;
      default:
        return _failure?.message ??
            AppLocalizations.of(_context!)!.generalError;
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

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:good_one_app/Features/Both/Models/user_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:good_one_app/Core/Infrastructure/Services/token_manager.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Navigation/app_routes.dart';
import 'package:good_one_app/Core/Navigation/navigation_service.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Features/Auth/Models/auth_model.dart';
import 'package:good_one_app/Features/Auth/Models/auth_request.dart';
import 'package:good_one_app/Features/Auth/Models/check_request.dart';
import 'package:good_one_app/Features/Auth/Models/register_request.dart';
import 'package:good_one_app/Features/Auth/Services/auth_api.dart';
import 'package:good_one_app/Features/Both/Services/both_api.dart';
import 'package:good_one_app/Features/Setup/Models/account_type.dart';
import 'package:good_one_app/Providers/Both/chat_provider.dart';
import 'package:good_one_app/Providers/User/user_manager_provider.dart';
import 'package:good_one_app/Providers/Worker/worker_maganer_provider.dart';
import 'package:good_one_app/l10n/app_localizations.dart';

class AuthProvider with ChangeNotifier {
  // ================================
  // PRIVATE FIELDS
  // ================================

  bool _isInitialized = false;
  AccountType? _selectedRegistrationAccountType;

  // Authentication State
  AuthModel? _authData;
  bool _isLoading = false;
  String? _error;

  // OTP Timer State
  Timer? _timer;
  int _seconds = 60;
  String? _otpCode;

  // Location State
  String? _selectedCountry;
  String? _selectedCity;

  // Form Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _forgotPasswordEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // UI State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Image Handling
  File? _selectedImage;
  String? _imageError;
  final ImagePicker _picker = ImagePicker();

  // ================================
  // GETTERS
  // ================================

  // Registration State
  AccountType? get selectedRegistrationAccountType =>
      _selectedRegistrationAccountType;

  // Authentication State
  bool get isLoading => _isLoading;
  bool get isAuth => _authData?.accessToken != null;
  String? get token => _authData?.accessToken;
  String? get error => _error;

  // OTP State
  int get seconds => _seconds;
  bool get isTimerExpired => _seconds == 0;
  String? get otpCode => _otpCode;

  // UI State
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  // Image State
  File? get selectedImage => _selectedImage;
  String? get imageError => _imageError;

  // Location State
  String? get selectedCountry => _selectedCountry;
  String? get selectedCity => _selectedCity;
  List<String> get availableCities {
    return _selectedCountry != null
        ? AppConfig.citiesByCountry[_selectedCountry] ?? []
        : [];
  }

  // Form Controllers
  TextEditingController get emailController => _emailController;
  TextEditingController get forgotPasswordEmailController =>
      _forgotPasswordEmailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get phoneController => _phoneController;

  // ================================
  // CONSTRUCTOR & INITIALIZATION
  // ================================

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Listen to token changes
      TokenManager.instance.tokenStream.listen((auth) {
        _authData = auth;
        notifyListeners();
      });

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _handleError('Initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _forgotPasswordEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ================================
  // AUTHENTICATION METHODS
  // ================================

  /// Enhanced login with server-verified navigation
  Future<void> login(BuildContext context) async {
    debugPrint('AuthProvider: Starting login process');

    try {
      _setLoading(true);
      _clearErrors();

      final deviceToken = await TokenManager.instance.getDeviceToken();

      final request = AuthRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        deviceToken: deviceToken,
      );

      final response = await AuthApi.login(request);

      if (response.success && response.data != null) {
        _authData = response.data;
        await _saveAuthData();

        // Get user info to determine user type
        final userInfoResponse = await BothApi.getUserInfo();

        if (userInfoResponse.success && userInfoResponse.data != null) {
          final userData = userInfoResponse.data!;
          final userType = userData.type ?? AppConfig.customer;

          // Save user type to storage
          await StorageManager.setString(StorageKeys.accountTypeKey, userType);

          _clearFormData();

          // Navigate and initialize the appropriate provider
          if (userType == AppConfig.service) {
            await _navigateAndInitializeWorker(context, userData);
          } else {
            await _navigateAndInitializeUser(context, userData);
          }
        } else {
          throw Exception('Failed to get user information after login');
        }
      } else if (response.error!.contains('not verified')) {
        await _sendOtpForUnverifiedAccount();
        _setLoading(false);
        await NavigationService.navigateToAndReplace(AppRoutes.otpScreen);
      } else {
        _setError(response.error ?? 'Login failed');
      }
    } catch (e) {
      _handleError('Login error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Navigate to worker interface and ensure initialization
  Future<void> _navigateAndInitializeWorker(
      BuildContext context, UserInfo userData) async {
    await NavigationService.navigateToAndReplace(AppRoutes.workerMain);

    // Wait a frame for the widget tree to build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;

      try {
        final workerProvider =
            Provider.of<WorkerManagerProvider>(context, listen: false);
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);

        // Pre-populate with user data to avoid null states
        workerProvider.setUserDataDirectly(userData);

        // Initialize chat with user ID
        if (userData.id != null) {
          await chatProvider.initialize(userData.id.toString());
        }

        debugPrint('AuthProvider: Worker interface initialized successfully');
      } catch (e) {
        debugPrint('AuthProvider: Worker initialization error: $e');
      }
    });
  }

  /// Navigate to user interface and ensure initialization
  Future<void> _navigateAndInitializeUser(
      BuildContext context, UserInfo userData) async {
    await NavigationService.navigateToAndReplace(AppRoutes.userMain);

    // Wait a frame for the widget tree to build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;

      try {
        final userProvider =
            Provider.of<UserManagerProvider>(context, listen: false);
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);

        // Pre-populate with user data to avoid null states
        userProvider.setUserDataDirectly(userData);

        // Initialize chat with user ID
        if (userData.id != null) {
          await chatProvider.initialize(userData.id.toString());
        }

        debugPrint('AuthProvider: User interface initialized successfully');
      } catch (e) {
        debugPrint('AuthProvider: User initialization error: $e');
      }
    });
  }

  /// Enhanced auto-login with server verification
  Future<bool> tryAutoLogin() async {
    debugPrint('AuthProvider: Attempting auto-login');

    try {
      if (!TokenManager.instance.isInitialized) {
        await TokenManager.instance.initialize();
      }

      _authData = TokenManager.instance.currentAuth;

      if (_authData != null) {
        // Verify user type with server for auto-login
        await _verifyAndSyncUserType();
      }

      notifyListeners();
      return _authData != null;
    } catch (e) {
      debugPrint('AuthProvider: Auto-login failed: $e');
      return false;
    }
  }

  /// Register new user account
  Future<void> register(BuildContext context) async {
    debugPrint('AuthProvider: Starting registration process');

    try {
      _setLoading(true);
      _clearErrors();

      // Validate account type selection
      final accountType = _selectedRegistrationAccountType?.toJson();
      if (accountType == null) {
        _setError(AppLocalizations.of(context)!.pleaseSelectAccountType);
        return;
      }

      // Save account type to storage
      await StorageManager.setString(StorageKeys.accountTypeKey, accountType);

      // Validate location for service providers
      if (accountType == AppConfig.service) {
        if (_selectedCountry == null || _selectedCity == null) {
          _setError(AppLocalizations.of(context)!.locationRequired);
          return;
        }
      }

      // Get device token
      final deviceToken = await TokenManager.instance.getDeviceToken();

      // Create registration request
      final request = RegisterRequest(
        image: _selectedImage,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        type: accountType,
        deviceToken: deviceToken,
        country: accountType == AppConfig.service ? _selectedCountry : null,
        city: accountType == AppConfig.service ? _selectedCity : null,
      );

      // Attempt registration
      final response = await AuthApi.register(request);

      if (response.success) {
        _setLoading(false);
        await NavigationService.navigateToAndReplace(AppRoutes.otpScreen);
      } else {
        _setError(response.error ?? 'Registration failed');
      }
    } catch (e) {
      _handleError('Registration error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Verify OTP and complete authentication
  /// Enhanced OTP verification
  Future<void> checkOtp(BuildContext context) async {
    debugPrint('AuthProvider: Verifying OTP');

    try {
      _setLoading(true);
      _clearErrors();

      if (_otpCode == null) {
        _setError('OTP code is required');
        return;
      }

      final request = CheckRequest(
        email: _emailController.text.trim(),
        otp: _otpCode!,
      );

      final response = await AuthApi.checkOtp(request);

      if (response.success && response.data != null) {
        _authData = response.data;
        await _saveAuthData();

        // Get user info to determine user type
        final userInfoResponse = await BothApi.getUserInfo();

        if (userInfoResponse.success && userInfoResponse.data != null) {
          final userData = userInfoResponse.data!;
          final userType = userData.type ?? AppConfig.customer;

          // Save user type to storage
          await StorageManager.setString(StorageKeys.accountTypeKey, userType);

          _clearFormData();

          // Navigate and initialize the appropriate provider
          if (userType == AppConfig.service) {
            await _navigateAndInitializeWorker(context, userData);
          } else {
            await _navigateAndInitializeUser(context, userData);
          }
        } else {
          throw Exception(
              'Failed to get user information after OTP verification');
        }
      } else {
        _setError(response.error ?? 'OTP verification failed');
      }
    } catch (e) {
      _handleError('OTP verification error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Enhanced logout with proper cleanup
  Future<void> logout(BuildContext context) async {
    debugPrint('AuthProvider: Starting logout process');

    try {
      _setLoading(true);
      _clearErrors();

      // Clear chat data BEFORE clearing auth data
      await _clearChatData(context);

      // Clear authentication data
      await _clearAuthData();

      // Clear form data
      _clearFormData();
    } catch (e) {
      _handleError('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ================================
  // OTP METHODS
  // ================================

  /// Send OTP code via email
  Future<void> sendOtp({bool isForPasswordReset = false}) async {
    debugPrint(
        'AuthProvider: Sending OTP${isForPasswordReset ? ' for password reset' : ''}');

    try {
      final email = isForPasswordReset
          ? _forgotPasswordEmailController.text.trim()
          : _emailController.text.trim();

      if (email.isEmpty) {
        _setError('Email is required');
        return;
      }

      final response = await AuthApi.sendOtp(email: email);

      if (response.success) {
        startTimer();

        final targetRoute =
            isForPasswordReset ? AppRoutes.resetPassword : AppRoutes.otpScreen;

        await NavigationService.navigateTo(targetRoute);
      } else {
        _setError(response.error ?? 'Failed to send OTP');
      }
    } catch (e) {
      _handleError('Send OTP error: $e');
    }
  }

  /// Resend OTP for password reset
  Future<void> resendOtpForPasswordReset() async {
    debugPrint('AuthProvider: Resending OTP for password reset');

    try {
      final response = await AuthApi.sendOtp(
        email: _forgotPasswordEmailController.text.trim(),
      );

      if (response.success) {
        startTimer();
      } else {
        _setError(response.error ?? 'Failed to resend OTP');
      }
    } catch (e) {
      _handleError('Resend OTP error: $e');
    }
  }

  Future<void> _sendOtpForUnverifiedAccount() async {
    debugPrint('AuthProvider: Sending OTP for unverified account');

    try {
      final email = _emailController.text.trim();

      if (email.isEmpty) {
        throw Exception('Email is required for OTP verification');
      }

      final response = await AuthApi.sendOtp(email: email);

      if (response.success) {
        // Start the timer for OTP
        startTimer();
        debugPrint('AuthProvider: OTP sent successfully to $email');
      } else {
        throw Exception(response.error ?? 'Failed to send OTP');
      }
    } catch (e) {
      debugPrint('AuthProvider: Error sending OTP for unverified account: $e');
      rethrow; // Re-throw to be handled by the calling method
    }
  }

  /// Set OTP code from user input
  void setOtpCode(String otpCode) {
    _otpCode = otpCode;
    notifyListeners();
  }

  // ================================
  // TIMER METHODS
  // ================================

  /// Start OTP countdown timer
  void startTimer() {
    _timer?.cancel();
    _seconds = 60;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        _seconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _timer = null;
        notifyListeners();
      }
    });
  }

  /// Ensure timer is running when needed
  void ensureTimerIsRunning() {
    if ((_timer == null || !_timer!.isActive) && _seconds > 0) {
      startTimer();
    }
  }

  // ================================
  // UI STATE METHODS
  // ================================

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // ================================
  // FORM VALIDATION METHODS
  // ================================

  String? validateFullName(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.fullNameRequired;
    }
    return null;
  }

  String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.emailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    return null;
  }

  String? validatePhone(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.phoneRequired;
    }
    if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
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

  // ================================
  // LOCATION METHODS
  // ================================

  void setCountry(String? country) {
    _selectedCountry = country;
    _selectedCity = null; // Reset city when country changes
    notifyListeners();
  }

  void setCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  // ================================
  // REGISTRATION TYPE METHODS
  // ================================

  void setRegistrationAccountType(AccountType type) {
    _selectedRegistrationAccountType = type;

    // Clear location data when switching to customer
    if (type == AccountType.customer) {
      _selectedCountry = null;
      _selectedCity = null;
    }

    notifyListeners();
  }

  // ================================
  // IMAGE HANDLING METHODS
  // ================================

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
        notifyListeners();
      }
    }
  }

  // ================================
  // PRIVATE HELPER METHODS
  // ================================

  /// Verify and sync user type with server
  Future<void> _verifyAndSyncUserType() async {
    try {
      final userInfoResponse = await BothApi.getUserInfo();

      if (userInfoResponse.success && userInfoResponse.data != null) {
        final serverUserType = userInfoResponse.data!.type;
        final storedUserType =
            await StorageManager.getString(StorageKeys.accountTypeKey);

        // Update stored type if different from server
        if (serverUserType != storedUserType) {
          debugPrint(
              'AuthProvider: Syncing user type - Server: $serverUserType, Stored: $storedUserType');
          await StorageManager.setString(
              StorageKeys.accountTypeKey, serverUserType ?? AppConfig.customer);
        }
      }
    } catch (e) {
      debugPrint(
          'AuthProvider: Error verifying user type during auto-login: $e');
    }
  }

  /// Clear chat data during logout
  Future<void> _clearChatData(BuildContext context) async {
    try {
      if (!context.mounted) return;

      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.disconnect();

      // Wait for cleanup to complete
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('AuthProvider: Chat disconnected and cleared on logout');
    } catch (e) {
      debugPrint('AuthProvider: Chat cleanup failed: $e');
    }
  }

  /// Clear all authentication data
  Future<void> _clearAuthData() async {
    await StorageManager.remove(StorageKeys.tokenKey);
    await StorageManager.remove(StorageKeys.accountTypeKey);
    await StorageManager.remove(StorageKeys.refreshTokenKey);
    await TokenManager.instance.clearAuthToken();

    _authData = null;
    notifyListeners();
  }

  /// Save authentication data securely
  Future<void> _saveAuthData() async {
    if (_authData == null) {
      throw Exception('No authentication data to save');
    }

    try {
      await TokenManager.instance.setAuthToken(_authData!);
    } catch (e) {
      throw Exception('Failed to save authentication data: $e');
    }
  }

  /// Clear all form data
  void _clearFormData() {
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    _selectedImage = null;
    _otpCode = null;
    _selectedCountry = null;
    _selectedCity = null;
    _selectedRegistrationAccountType = null;

    _fullNameController.clear();
    _emailController.clear();
    _forgotPasswordEmailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _phoneController.clear();

    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? message) {
    _error = message;
    _imageError = null;
    notifyListeners();
  }

  /// Clear all errors
  void _clearErrors() {
    _error = null;
    _imageError = null;
    notifyListeners();
  }

  /// Handle errors with consistent logging
  void _handleError(dynamic error) {
    final errorMessage = error.toString();
    debugPrint('AuthProvider: $errorMessage');
    _setError(errorMessage);
  }
}

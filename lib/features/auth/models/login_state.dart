import 'package:flutter/foundation.dart';

@immutable
class LoginState {
  final bool isLoading;
  final String? error;
  final bool obscurePassword;
  final bool isEmailValid;
  final bool isPasswordValid;

  const LoginState({
    this.isLoading = false,
    this.error,
    this.obscurePassword = true,
    this.isEmailValid = true,
    this.isPasswordValid = true,
  });

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? obscurePassword,
    bool? isEmailValid,
    bool? isPasswordValid,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Intentionally not using ??
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
    );
  }
}

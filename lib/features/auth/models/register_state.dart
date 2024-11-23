import 'dart:io';
import 'package:flutter/foundation.dart';

@immutable
class RegisterState {
  final bool isLoading;
  final String? error;
  final String? imageError;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isFullNameValid;
  final bool isEmailValid;
  final bool isPhoneValid;
  final bool isPasswordValid;
  final bool isConfirmPasswordValid;
  final File? selectedImage;

  const RegisterState({
    this.isLoading = false,
    this.error,
    this.imageError,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.isFullNameValid = true,
    this.isEmailValid = true,
    this.isPhoneValid = true,
    this.isPasswordValid = true,
    this.isConfirmPasswordValid = true,
    this.selectedImage,
  });

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    String? imageError,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? isFullNameValid,
    bool? isEmailValid,
    bool? isPhoneValid,
    bool? isPasswordValid,
    bool? isConfirmPasswordValid,
    File? selectedImage,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Intentionally not using ??
      imageError: imageError, // Intentionally not using ??
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      isFullNameValid: isFullNameValid ?? this.isFullNameValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isConfirmPasswordValid:
          isConfirmPasswordValid ?? this.isConfirmPasswordValid,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

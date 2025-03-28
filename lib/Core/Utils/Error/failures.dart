import '../../presentation/resources/app_strings.dart';

abstract class Failure implements Exception {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = AppStrings.networkError, super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = AppStrings.authError, super.code});
}

class ValidationFailure extends Failure {
  final Map<String, String> errors;

  const ValidationFailure({
    required super.message,
    required this.errors,
    super.code,
  });

  // Helper method to get first error message
  String get firstError => errors.values.first;

  // Helper method to check if a field has error
  bool hasError(String field) => errors.containsKey(field);

  // Helper method to get error for a field
  String? getError(String field) => errors[field];
}

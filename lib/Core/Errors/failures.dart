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
  const NetworkFailure({required super.message, super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  final Map<String, String> errors;

  const ValidationFailure({
    required super.message,
    required this.errors,
    super.code,
  });
}

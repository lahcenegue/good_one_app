// import 'package:flutter/widgets.dart';

// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// abstract class Failure implements Exception {
//   final BuildContext context;
//   final String message;
//   final String? code;

//   const Failure({
//     required this.context,
//     required this.message,
//     this.code,
//   });

//   @override
//   String toString() => message;
// }

// class NetworkFailure extends Failure {
//   NetworkFailure({required super.context, String? message, super.code})
//       : super(
//           message: message ?? AppLocalizations.of(context)!.networkError,
//         );
// }

// class AuthFailure extends Failure {
//   AuthFailure({required super.context, String? message, super.code})
//       : super(
//           message: message ?? AppLocalizations.of(context)!.authError,
//         );
// }

// class ValidationFailure extends Failure {
//   final Map<String, String> errors;

//   const ValidationFailure({
//     required super.message,
//     required this.errors,
//     super.code,
//     required super.context,
//   });

//   // Helper method to get first error message
//   String get firstError => errors.values.first;

//   // Helper method to check if a field has error
//   bool hasError(String field) => errors.containsKey(field);

//   // Helper method to get error for a field
//   String? getError(String field) => errors[field];
// }

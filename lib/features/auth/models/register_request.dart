import 'dart:io';

class RegisterRequest {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String type;
  final File image;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.type,
    required this.image,
  });

  Map<String, String> toFields() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'type': type,
    };
  }

  Map<String, File> toFiles() {
    return {
      'picture': image,
    };
  }
}

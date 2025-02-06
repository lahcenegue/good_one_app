import 'dart:io';

class RegisterRequest {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String type;
  final File image;
  final String deviceToken;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.type,
    required this.image,
    required this.deviceToken,
  });

  Map<String, String> toFields() {
    return {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'type': type,
      'device_token': deviceToken,
    };
  }

  Map<String, File> toFiles() {
    return {
      'picture': image,
    };
  }
}

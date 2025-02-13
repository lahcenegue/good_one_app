import 'dart:io';

class RegisterRequest {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String? city;
  final String? country;
  final String type;
  final File image;
  final String deviceToken;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    this.city,
    this.country,
    required this.type,
    required this.image,
    required this.deviceToken,
  });

  Map<String, String> toFields() {
    final fields = {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'type': type,
      'device_token': deviceToken,
    };

    if (city != null) fields['city'] = city!;
    if (country != null) fields['country'] = country!;

    return fields;
  }

  Map<String, File> toFiles() {
    return {
      'picture': image,
    };
  }
}

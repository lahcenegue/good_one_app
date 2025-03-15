import 'dart:io';

class AccountEditRequest {
  final String? fullName;
  final String? email;
  final int? phone;
  final String? password;
  final String? city;
  final String? country;
  final File? image;

  AccountEditRequest({
    this.fullName,
    this.email,
    this.phone,
    this.password,
    this.city,
    this.country,
    this.image,
  });

  Map<String, String> toFields() {
    final Map<String, String> fields = {};
    if (fullName != null) fields['full_name'] = fullName!;
    if (email != null) fields['email'] = email!;
    if (phone != null) fields['phone'] = phone!.toString();
    if (password != null) fields['password'] = password!;
    if (city != null) fields['city'] = city!;
    if (country != null) fields['country'] = country!;

    return fields;
  }

  Map<String, File> toFiles() {
    if (image == null) {
      return {};
    } else {
      return {
        'picture': image!,
      };
    }
  }
}

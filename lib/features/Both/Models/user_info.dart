class UserInfo {
  final int? id;
  final String? email;
  final int? phone;
  final String? type;
  final String? fullName;
  final String? picture;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final int? active;
  final bool? securityCheck;
  final bool? verifiedLicense;
  final String? country;
  final String? city;

  UserInfo({
    required this.id,
    required this.email,
    required this.phone,
    required this.type,
    required this.fullName,
    required this.picture,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
    required this.securityCheck,
    required this.verifiedLicense,
    required this.country,
    required this.city,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int?,
      email: json['email'] as String?,
      phone: json['phone'] as int?,
      type: json['type'] as String?,
      fullName: json['full_name'] as String?,
      picture: json['picture'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      active: json['active'] as int?,
      securityCheck:
          json['security_check'] != null ? json['security_check'] == 1 : null,
      verifiedLicense: json['verified_liscence'] != null
          ? json['verified_liscence'] == 1
          : null,
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'email': email,
  //     'phone': phone,
  //     'type': type,
  //     'full_name': fullName,
  //     'picture': picture,
  //     'email_verified_at': emailVerifiedAt,
  //     'created_at': createdAt,
  //     'updated_at': updatedAt,
  //     'active': active,
  //     'security_check': securityCheck != null ? (securityCheck! ? 1 : 0) : null,
  //     'verified_liscence':
  //         verifiedLicense != null ? (verifiedLicense! ? 1 : 0) : null,
  //   };
  // }
}

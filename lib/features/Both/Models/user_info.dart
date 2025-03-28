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
  final bool? securityCheck;
  final String? country;
  final String? city;
  final dynamic active;

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
      securityCheck:
          json['security_check'] != null ? json['security_check'] == 1 : null,
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      active: json['active'] is bool
          ? json['active']
          : (json['active'] is int ? json['active'] == 1 : null),
    );
  }
}

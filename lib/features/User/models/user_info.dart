class UserInfo {
  final int? id;
  final String? email;
  final int? phone;
  final String? type;
  final String? fullName;
  final String? picture;
  final String? location;
  final double? costPerHour;
  final String? service;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final int? category;
  final int? active;
  final int? yearsOfExperience;
  final String? about;
  final bool? securityCheck;
  final bool? verifiedLicense;

  UserInfo({
    required this.id,
    required this.email,
    required this.phone,
    required this.type,
    required this.fullName,
    required this.picture,
    required this.location,
    required this.costPerHour,
    required this.service,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.active,
    required this.yearsOfExperience,
    required this.about,
    required this.securityCheck,
    required this.verifiedLicense,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int?,
      email: json['email'] as String?,
      phone: json['phone'] as int?,
      type: json['type'] as String?,
      fullName: json['full_name'] as String?,
      picture: json['picture'] as String?,
      location: json['location'] as String?,
      costPerHour: json['cost_per_hour'] != null
          ? (json['cost_per_hour'] as num).toDouble()
          : null,
      service: json['service'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      category: json['category'] as int?,
      active: json['active'] as int?,
      yearsOfExperience: json['years_of_experience'] as int?,
      about: json['about'] as String?,
      securityCheck:
          json['security_check'] != null ? json['security_check'] == 1 : null,
      verifiedLicense: json['verified_liscence'] != null
          ? json['verified_liscence'] == 1
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'type': type,
      'full_name': fullName,
      'picture': picture,
      'location': location,
      'cost_per_hour': costPerHour,
      'service': service,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'category': category,
      'active': active,
      'years_of_experience': yearsOfExperience,
      'about': about,
      'security_check': securityCheck != null ? (securityCheck! ? 1 : 0) : null,
      'verified_liscence':
          verifiedLicense != null ? (verifiedLicense! ? 1 : 0) : null,
    };
  }
}

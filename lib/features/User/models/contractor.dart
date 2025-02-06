import 'gallery_image.dart';

class Contractor {
  final int id;
  final String email;
  final int phone;
  final String type;
  final String fullName;
  final String picture;
  final String location;
  final double costPerHour;
  final String service;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int category;
  final int active;
  final int yearsOfExperience;
  final String about;
  final bool securityCheck;
  final bool verifiedLicense;
  final List<GalleryImage> gallery;
  final bool isFavorite;

  const Contractor({
    required this.id,
    required this.email,
    required this.phone,
    required this.type,
    required this.fullName,
    required this.picture,
    required this.location,
    required this.costPerHour,
    required this.service,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.active,
    required this.yearsOfExperience,
    required this.about,
    required this.securityCheck,
    required this.verifiedLicense,
    required this.gallery,
    this.isFavorite = false,
  });

  factory Contractor.fromJson(Map<String, dynamic> json) {
    return Contractor(
      id: json['id'] ?? 0,
      email: json['email'] as String? ?? '',
      phone: (json['phone'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      picture: json['picture'] as String? ?? '',
      location: json['location'] as String? ?? '',
      costPerHour: (json['cost_per_hour'] as num?)?.toDouble() ?? 0.0,
      service: json['service'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      category: json['category'] ?? 0,
      active: json['active'] as int? ?? 0,
      yearsOfExperience: json['years_of_experience'] as int? ?? 0,
      about: json['about'] as String? ?? '',
      securityCheck: json['security_check'] == 1,
      verifiedLicense: json['verified_liscence'] == 1,
      gallery: (json['gallary'] as List<dynamic>?)
              ?.map((e) => GalleryImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category,
      'active': active,
      'years_of_experience': yearsOfExperience,
      'about': about,
      'security_check': securityCheck ? 1 : 0,
      'verified_liscence': verifiedLicense ? 1 : 0,
      'gallary': gallery.map((e) => e.toJson()).toList(),
      'is_favorite': isFavorite,
    };
  }

  Contractor copyWith({
    int? id,
    String? email,
    int? phone,
    String? type,
    String? fullName,
    String? picture,
    String? location,
    double? costPerHour,
    String? service,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? category,
    int? active,
    int? yearsOfExperience,
    String? about,
    bool? securityCheck,
    bool? verifiedLicense,
    List<GalleryImage>? gallery,
    bool? isFavorite,
  }) {
    return Contractor(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      fullName: fullName ?? this.fullName,
      picture: picture ?? this.picture,
      location: location ?? this.location,
      costPerHour: costPerHour ?? this.costPerHour,
      service: service ?? this.service,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      active: active ?? this.active,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      about: about ?? this.about,
      securityCheck: securityCheck ?? this.securityCheck,
      verifiedLicense: verifiedLicense ?? this.verifiedLicense,
      gallery: gallery ?? this.gallery,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() {
    return 'Contractor(id: $id, fullName: $fullName, service: $service)';
  }

  // Helpful getters
  bool get isActive => active == 1;
  String get experienceText => '$yearsOfExperience years';
  String get hourlyRate => '\$${costPerHour.toStringAsFixed(2)}/hr';
}

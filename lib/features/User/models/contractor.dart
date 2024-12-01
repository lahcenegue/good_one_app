class GalleryImage {
  final int id;
  final String image;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  GalleryImage({
    required this.id,
    required this.image,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'] as int,
      image: json['image'] as String,
      userId: json['user_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

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
  bool isFavorite;

  Contractor({
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
      id: json['id'] as int,
      email: json['email'] as String,
      phone: json['phone'] as int,
      type: json['type'] as String,
      fullName: json['full_name'] as String,
      picture: json['picture'] as String,
      location: json['location'] as String,
      costPerHour: (json['cost_per_hour'] as num).toDouble(),
      service: json['service'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['category'] as int,
      active: json['active'] as int,
      yearsOfExperience: json['years_of_experience'] as int,
      about: json['about'] as String,
      securityCheck: json['security_check'] == 1,
      verifiedLicense: json['verified_liscence'] == 1,
      gallery: (json['gallary'] as List<dynamic>)
          .map((e) => GalleryImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

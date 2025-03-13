import 'dart:convert';

class Contractor {
  final int? serviceId;
  final int? contractorId;
  final String? email;
  final num? phone;
  final String? fullName;
  final String? picture;
  final String? location;
  final int? costPerHour;
  final String? service;
  final int? yearsOfExperience;
  final String? about;
  final int? securityCheck;
  final int? verifiedLicense;
  final Rating? rating; // No longer required
  final List<RatingDetail>? ratings; // No longer required
  final int? orders; // No longer required
  final List<String>? gallery; // No longer required
  final String? city;
  final String? country;
  final Subcategory? subcategory; // No longer required
  final bool? isFavorite;

  const Contractor({
    this.serviceId,
    this.contractorId,
    this.email,
    this.phone,
    this.fullName,
    this.picture,
    this.location,
    this.costPerHour,
    this.service,
    this.yearsOfExperience,
    this.about,
    this.securityCheck,
    this.verifiedLicense,
    this.rating,
    this.ratings,
    this.orders,
    this.gallery,
    this.city,
    this.country,
    this.subcategory,
    this.isFavorite = false,
  });

  factory Contractor.fromJson(Map<String, dynamic> json) {
    return Contractor(
      serviceId: json['id'] as int?,
      contractorId: json['contractor_id'] as int?,
      email: json['email'] as String?,
      phone: json['phone'],
      fullName: json['full_name'] as String?,
      picture: json['picture'] as String?,
      location: json['location'] as String?,
      costPerHour: json['cost_per_hour'] as int?,
      service: json['service'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      about: json['about'] as String?,
      securityCheck: json['security_check'] as int?,
      verifiedLicense: json['verified_liscence'] as int?,
      rating: json['rating'] != null
          ? Rating.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
      ratings: (json['ratings'] as List<dynamic>?)
          ?.map((item) => RatingDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
      orders: json['orders'] as int?,
      gallery:
          (json['gallary'] as List<dynamic>?)?.map((e) => e as String).toList(),
      city: json['city'] as String?,
      country: json['country'] as String?,
      subcategory: json['subcategory'] != null
          ? Subcategory.fromJson(json['subcategory'] as Map<String, dynamic>)
          : null,
    );
  }
}

// Rating model
class Rating {
  final double rating;
  final int timesRated;

  const Rating({required this.rating, required this.timesRated});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      timesRated: json['times_rated'] as int? ?? 0, // Updated field name
    );
  }
}

// RatingDetail model
class RatingDetail {
  final int rate;
  final String message;
  final String? createdAt;
  final Reviewer reviewer; // Renamed from 'User'

  const RatingDetail({
    this.rate = 0,
    this.message = '',
    this.createdAt,
    this.reviewer = const Reviewer(id: 0, fullName: '', picture: ''),
  });

  factory RatingDetail.fromJson(Map<String, dynamic> json) {
    return RatingDetail(
      rate: json['rate'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      reviewer: json['user'] != null
          ? Reviewer.fromJson(json['user'] as Map<String, dynamic>)
          : const Reviewer(id: 0, fullName: '', picture: ''),
    );
  }
}

// Reviewer model (renamed from User)
class Reviewer {
  final int id;
  final String fullName;
  final String picture;

  const Reviewer({this.id = 0, this.fullName = '', this.picture = ''});

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      picture: json['picture'] as String? ?? '',
    );
  }
}

// Subcategory model
class Subcategory {
  final int id;
  final String name;
  final Category category;

  const Subcategory({
    required this.id,
    required this.name,
    required this.category,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
    );
  }
}

// Category model
class Category {
  final int id;
  final String name;
  final String image;

  const Category({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }
}

// Parser function
List<Contractor> parseWorkers(String responseBody) {
  final parsed = json.decode(responseBody) as List<dynamic>;
  return parsed
      .map((json) => Contractor.fromJson(json as Map<String, dynamic>))
      .toList();
}

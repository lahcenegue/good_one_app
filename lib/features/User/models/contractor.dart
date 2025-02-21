import 'dart:convert';

class Contractor {
  final int id;
  final String? email;
  final dynamic
      phone; // Changed to dynamic to handle both string and numeric values
  final String? fullName;
  final String? picture;
  final String? location;
  final int? costPerHour;
  final String? service;
  final int? yearsOfExperience;
  final String? about;
  final int? securityCheck;
  final int? verifiedLiscence;
  final Rating rating;
  final List<RatingDetail> ratings;
  final int orders;
  final List<String> gallery;
  final String? city;
  final String? country;
  final dynamic subcategory;
  final bool isFavorite;

  const Contractor({
    required this.id,
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
    this.verifiedLiscence,
    required this.rating,
    required this.ratings,
    required this.orders,
    required this.gallery,
    this.city,
    this.country,
    this.subcategory,
    this.isFavorite = false,
  });

  factory Contractor.fromJson(Map<String, dynamic> json) {
    return Contractor(
      id: json['id'] ?? 0,
      email: json['email'],
      phone: json['phone'], // Accept as-is, handle conversion in UI
      fullName: json['full_name'],
      picture: json['picture'],
      location: json['location'],
      costPerHour: json['cost_per_hour'],
      service: json['service'],
      yearsOfExperience: json['years_of_experience'],
      about: json['about'],
      securityCheck: json['security_check'],
      verifiedLiscence: json['verified_liscence'],
      rating: json['rating'] != null
          ? Rating.fromJson(json['rating'])
          : Rating(rating: 0, timesRated: 0),
      ratings: json['ratings'] != null
          ? (json['ratings'] as List)
              .map((item) => RatingDetail.fromJson(item))
              .toList()
          : [],
      orders: json['orders'] ?? 0,
      gallery:
          json['gallary'] != null ? List<String>.from(json['gallary']) : [],
      city: json['city'],
      country: json['country'],
      subcategory: json['subcategory'],
    );
  }
}

class Rating {
  final int rating;
  final int timesRated;

  Rating({required this.rating, required this.timesRated});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: json['rating'] ?? 0,
      timesRated: json['times_rated'] ?? 0,
    );
  }
}

class RatingDetail {
  final int rate;
  final String message;
  final String? createdAt;
  final User user;

  RatingDetail({
    required this.rate,
    required this.message,
    this.createdAt,
    required this.user,
  });

  factory RatingDetail.fromJson(Map<String, dynamic> json) {
    return RatingDetail(
      rate: json['rate'] ?? 0,
      message: json['message'] ?? '',
      createdAt: json['created_at'],
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User(id: 0, fullName: '', picture: ''),
    );
  }
}

class User {
  final int id;
  final String fullName;
  final String picture;

  User({required this.id, required this.fullName, required this.picture});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      picture: json['picture'],
    );
  }
}

List<Contractor> parseWorkers(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Contractor>((json) => Contractor.fromJson(json)).toList();
}

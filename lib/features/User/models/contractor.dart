import 'dart:convert';

class Contractor {
  final int id;
  final String email;
  final String phone;
  final String type;
  final String fullName;
  final String picture;
  final String location;
  final int costPerHour;
  final String service;
  final int yearsOfExperience;
  final String about;
  final int securityCheck;
  final int verifiedLiscence;
  final Rating rating;
  final List<RatingDetail> ratings;
  final int orders;
  final List<String> gallery;
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
    required this.yearsOfExperience,
    required this.about,
    required this.securityCheck,
    required this.verifiedLiscence,
    required this.rating,
    required this.ratings,
    required this.orders,
    required this.gallery,
    this.isFavorite = false,
  });

  factory Contractor.fromJson(Map<String, dynamic> json) {
    return Contractor(
      id: json['id'],
      email: json['email'],
      phone: json['phone'].toString(),
      type: json['type'],
      fullName: json['full_name'],
      picture: json['picture'],
      location: json['location'],
      costPerHour: json['cost_per_hour'],
      service: json['service'],
      yearsOfExperience: json['years_of_experience'],
      about: json['about'],
      securityCheck: json['security_check'],
      verifiedLiscence: json['verified_liscence'],
      rating: Rating.fromJson(json['rating']),
      ratings: (json['ratings'] as List)
          .map((item) => RatingDetail.fromJson(item))
          .toList(),
      orders: json['orders'],
      gallery: List<String>.from(json['gallary']),
    );
  }

  // Contractor copyWith({
  //   int? id,
  //   String? email,
  //   int? phone,
  //   String? type,
  //   String? fullName,
  //   String? picture,
  //   String? location,
  //   double? costPerHour,
  //   String? service,
  //   DateTime? emailVerifiedAt,
  //   DateTime? createdAt,
  //   DateTime? updatedAt,
  //   int? category,
  //   int? active,
  //   int? yearsOfExperience,
  //   String? about,
  //   bool? securityCheck,
  //   bool? verifiedLicense,
  //   List<GalleryImage>? gallery,
  //   int? orders,
  //   RatingSummary? ratings,
  //   List<Rating>? rating,
  //   bool? isFavorite,
  // }) {
  //   return Contractor(
  //     id: id ?? this.id,
  //     email: email ?? this.email,
  //     phone: phone ?? this.phone,
  //     type: type ?? this.type,
  //     fullName: fullName ?? this.fullName,
  //     picture: picture ?? this.picture,
  //     location: location ?? this.location,
  //     costPerHour: costPerHour ?? this.costPerHour,
  //     service: service ?? this.service,
  //     emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
  //     createdAt: createdAt ?? this.createdAt,
  //     updatedAt: updatedAt ?? this.updatedAt,
  //     category: category ?? this.category,
  //     active: active ?? this.active,
  //     yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
  //     about: about ?? this.about,
  //     securityCheck: securityCheck ?? this.securityCheck,
  //     verifiedLicense: verifiedLicense ?? this.verifiedLicense,
  //     gallery: gallery ?? this.gallery,
  //     orders: orders ?? this.orders,
  //     ratings: ratings ?? this.ratings,
  //     rating: rating ?? this.rating,
  //     isFavorite: isFavorite ?? this.isFavorite,
  //   );
  // }

  // @override
  // String toString() {
  //   return 'Contractor(id: $id, fullName: $fullName, service: $service, rating: ${ratings.rating})';
  // }

  // Helpful getters
  // bool get isActive => active == 1;
  // String get experienceText => '$yearsOfExperience years';
  // String get hourlyRate => '\$${costPerHour.toStringAsFixed(2)}/hr';
  // bool get isVerified => emailVerifiedAt != null;
  // String get ratingText => '${rating.toStringAsFixed(1)} ($timesRated)';
}

class Rating {
  final int rating;
  final int timesRated;

  Rating({required this.rating, required this.timesRated});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: json['rating'],
      timesRated: json['times_rated'],
    );
  }
}

class RatingDetail {
  final int rate;
  final String message;
  final User user;

  RatingDetail({
    required this.rate,
    required this.message,
    required this.user,
  });

  factory RatingDetail.fromJson(Map<String, dynamic> json) {
    return RatingDetail(
      rate: json['rate'],
      message: json['message'],
      user: User.fromJson(json['user']),
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

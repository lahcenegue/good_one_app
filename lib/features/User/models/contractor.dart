class Contractor {
  int? id;
  int? contractorId;
  int? subcategoryId;
  String? city;
  String? country;
  String? email;
  int? phone;
  String? fullName;
  String? picture;
  double? costPerHour;
  double? costPerDay;
  double? fixedPrice;
  String? pricingType; // 'hourly', 'daily', 'fixed'
  DisplayPrice? displayPrice;
  String? service;
  int? yearsOfExperience;
  String? about;
  int? securityCheck;
  int? verifiedLicense;
  Rating? rating;
  List<RatingDetail>? ratings;
  int? orders;
  List<String>? gallery;
  Subcategory? subcategory;

  Contractor({
    this.id,
    this.contractorId,
    this.subcategoryId,
    this.city,
    this.country,
    this.email,
    this.phone,
    this.fullName,
    this.picture,
    this.costPerHour,
    this.costPerDay,
    this.fixedPrice,
    this.pricingType,
    this.displayPrice,
    this.service,
    this.yearsOfExperience,
    this.about,
    this.securityCheck,
    this.verifiedLicense,
    this.rating,
    this.ratings,
    this.orders,
    this.gallery,
    this.subcategory,
  });

  factory Contractor.fromJson(Map<String, dynamic> json) {
    return Contractor(
      id: json['id'],
      contractorId: json['contractor_id'],
      subcategoryId: json['subcategory_id'],
      city: json['city'],
      country: json['country'],
      email: json['email'],
      phone: json['phone'],
      fullName: json['full_name'],
      picture: json['picture'],

      // Legacy fields - safely convert to double
      costPerHour: _safeToDouble(json['cost_per_hour']),
      costPerDay: _safeToDouble(json['cost_per_day']),
      fixedPrice: _safeToDouble(json['fixed_price']),

      // New pricing structure
      pricingType: json['pricing_type']?.toString(),
      displayPrice: json['display_price'] != null
          ? DisplayPrice.fromJson(json['display_price'])
          : null,

      service: json['service'],
      yearsOfExperience: json['years_of_experience'],
      about: json['about'],
      securityCheck: json['security_check'],
      verifiedLicense: json['verified_liscence'],
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
      ratings: json['ratings'] != null
          ? (json['ratings'] as List)
              .map((rating) => RatingDetail.fromJson(rating))
              .toList()
          : [],
      orders: json['orders'] ?? 0,
      gallery:
          json['gallary'] != null ? List<String>.from(json['gallary']) : [],
      subcategory: json['subcategory'] != null
          ? Subcategory.fromJson(json['subcategory'])
          : null,
    );
  }

  // Helper method to safely convert values to double
  static double? _safeToDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractor_id': contractorId,
      'subcategory_id': subcategoryId,
      'city': city,
      'country': country,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'picture': picture,
      'cost_per_hour': costPerHour,
      'cost_per_day': costPerDay,
      'fixed_price': fixedPrice,
      'pricing_type': pricingType,
      'display_price': displayPrice?.toJson(),
      'service': service,
      'years_of_experience': yearsOfExperience,
      'about': about,
      'security_check': securityCheck,
      'verified_liscence': verifiedLicense,
      'rating': rating?.toJson(),
      'ratings': ratings?.map((rating) => rating.toJson()).toList(),
      'orders': orders,
      'gallary': gallery,
      'subcategory': subcategory?.toJson(),
    };
  }

  // CRITICAL: This method should NEVER return null or empty string
  // Every service must be displayable regardless of pricing type
  String getPriceDisplayText() {
    // First priority: Use new display_price if available
    if (displayPrice != null && displayPrice!.displayText.isNotEmpty) {
      return displayPrice!.displayText;
    }

    // Second priority: Build from pricing_type and individual prices
    if (pricingType != null) {
      switch (pricingType!.toLowerCase()) {
        case 'hourly':
          if (costPerHour != null && costPerHour! > 0) {
            return '\$${costPerHour!.toStringAsFixed(2)}/hour';
          }
          break;
        case 'daily':
          if (costPerDay != null && costPerDay! > 0) {
            return '\$${costPerDay!.toStringAsFixed(2)}/day';
          }
          break;
        case 'fixed':
          if (fixedPrice != null && fixedPrice! > 0) {
            return '\$${fixedPrice!.toStringAsFixed(2)} (Fixed)';
          }
          break;
      }
    }

    // Third priority: Legacy fallback - check all pricing fields
    if (costPerHour != null && costPerHour! > 0) {
      return '\$${costPerHour!.toStringAsFixed(2)}/hour';
    }
    if (costPerDay != null && costPerDay! > 0) {
      return '\$${costPerDay!.toStringAsFixed(2)}/day';
    }
    if (fixedPrice != null && fixedPrice! > 0) {
      return '\$${fixedPrice!.toStringAsFixed(2)} (Fixed)';
    }

    // Final fallback: NEVER return empty - always show something
    return 'Contact for Price';
  }

  // Helper method to get the primary price value for sorting
  double? getPrimaryPrice() {
    // Use display_price if available
    if (displayPrice != null && displayPrice!.price > 0) {
      return displayPrice!.price;
    }

    // Use pricing_type to determine which price to return
    if (pricingType != null) {
      switch (pricingType!.toLowerCase()) {
        case 'hourly':
          return costPerHour;
        case 'daily':
          return costPerDay;
        case 'fixed':
          return fixedPrice;
      }
    }

    // Legacy fallback - return first available price
    return costPerHour ?? costPerDay ?? fixedPrice;
  }

  // Method to check if service has valid pricing (for filtering, not hiding)
  bool hasValidPricing() {
    return getPrimaryPrice() != null && getPrimaryPrice()! > 0;
  }

  // Method to get pricing type for display and filtering
  String getEffectivePricingType() {
    // Use new pricing type if available
    if (pricingType != null && pricingType!.isNotEmpty) {
      return pricingType!.toLowerCase();
    }

    // Infer from available pricing fields
    if (costPerHour != null && costPerHour! > 0) return 'hourly';
    if (costPerDay != null && costPerDay! > 0) return 'daily';
    if (fixedPrice != null && fixedPrice! > 0) return 'fixed';

    return 'contact'; // For services without standard pricing
  }
}

class DisplayPrice {
  double price;
  String type; // 'hourly', 'daily', 'fixed'
  String displayText;

  DisplayPrice({
    required this.price,
    required this.type,
    required this.displayText,
  });

  factory DisplayPrice.fromJson(Map<String, dynamic> json) {
    return DisplayPrice(
      price: Contractor._safeToDouble(json['price']) ?? 0.0,
      type: json['type']?.toString() ?? 'unknown',
      displayText: json['display_text']?.toString() ?? 'Price on request',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'type': type,
      'display_text': displayText,
    };
  }
}

// Rating model
class Rating {
  double rating;
  int timesRated;

  Rating({required this.rating, required this.timesRated});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: Contractor._safeToDouble(json['rating']) ?? 0.0,
      timesRated: json['times_rated'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'times_rated': timesRated,
    };
  }
}

// RatingDetail model
class RatingDetail {
  String message;
  int rate;
  String createdAt;
  Reviewer reviewer;

  RatingDetail({
    required this.message,
    required this.rate,
    required this.createdAt,
    required this.reviewer,
  });

  factory RatingDetail.fromJson(Map<String, dynamic> json) {
    return RatingDetail(
      message: json['message']?.toString() ?? '',
      rate: json['rate'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      reviewer: Reviewer.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'rate': rate,
      'created_at': createdAt,
      'user': reviewer.toJson(),
    };
  }
}

// Reviewer model (renamed from User)
class Reviewer {
  int id;
  String fullName;
  String? picture;

  Reviewer({
    required this.id,
    required this.fullName,
    this.picture,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      id: json['id'] ?? 0,
      fullName: json['full_name']?.toString() ?? 'Anonymous',
      picture: json['picture']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'picture': picture,
    };
  }
}

// Subcategory model
class Subcategory {
  int id;
  String name;
  Category? category;

  Subcategory({
    required this.id,
    required this.name,
    this.category,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category?.toJson(),
    };
  }
}

// Category model
class Category {
  int id;
  String name;
  String? image;

  Category({
    required this.id,
    required this.name,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }
}

// Parser function
// List<Contractor> parseWorkers(String responseBody) {
//   final parsed = json.decode(responseBody) as List<dynamic>;
//   return parsed
//       .map((json) => Contractor.fromJson(json as Map<String, dynamic>))
//       .toList();
// }

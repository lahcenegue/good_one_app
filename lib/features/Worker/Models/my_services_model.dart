class MyServicesModel {
  final int id;
  final double? costPerHour;
  final double? costPerDay;
  final double? fixedPrice;
  final String? pricingType;
  final String service;
  final int yearsOfExperience;
  final String about;
  final int active;
  final List<String> gallary;
  final Subcategory subcategory;
  final int? hasCertificate;

  MyServicesModel({
    required this.id,
    required this.costPerHour,
    this.costPerDay,
    this.fixedPrice,
    this.pricingType,
    required this.service,
    required this.yearsOfExperience,
    required this.about,
    required this.active,
    required this.gallary,
    required this.subcategory,
    this.hasCertificate,
  });

  factory MyServicesModel.fromJson(Map<String, dynamic> json) {
    return MyServicesModel(
      id: json['id'] as int,
      costPerHour: json['cost_per_hour'] != null
          ? (json['cost_per_hour'] as num).toDouble()
          : null,
      costPerDay: json['cost_per_day'] != null
          ? (json['cost_per_day'] as num).toDouble()
          : null,
      fixedPrice: json['fixed_price'] != null
          ? (json['fixed_price'] as num).toDouble()
          : null,
      pricingType: json['pricing_type'] as String?,
      service: json['service'] as String,
      yearsOfExperience: json['years_of_experience'] as int,
      about: json['about'] as String,
      active: json['active'] as int,
      gallary: List<String>.from(json['gallary'] as List<dynamic>),
      subcategory:
          Subcategory.fromJson(json['subcategory'] as Map<String, dynamic>),
      hasCertificate: json['verified_liscence'] as int?,
    );
  }

  // Helper method to get the current price and type
  String getPriceDisplay() {
    switch (pricingType) {
      case 'hourly':
        return '\$${costPerHour?.toStringAsFixed(2) ?? '0'}/hr';
      case 'daily':
        return '\$${costPerDay?.toStringAsFixed(2) ?? '0'}/day';
      case 'fixed':
        return '\$${fixedPrice?.toStringAsFixed(2) ?? '0'} (Fixed)';
      default:
        return '\$${costPerHour?.toStringAsFixed(2) ?? '0'}/hr';
    }
  }

  // Helper method to get current price value
  double? getCurrentPrice() {
    switch (pricingType) {
      case 'hourly':
        return costPerHour;
      case 'daily':
        return costPerDay;
      case 'fixed':
        return fixedPrice;
      default:
        return costPerHour;
    }
  }
}

class Subcategory {
  final int subCategoryid;
  final String name;
  final Category category;

  Subcategory({
    required this.subCategoryid,
    required this.name,
    required this.category,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      subCategoryid: json['id'] as int,
      name: json['name'] as String,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String image;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
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

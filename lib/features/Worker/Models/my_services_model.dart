class MyServicesModel {
  final int id;

  final double costPerHour;
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
      costPerHour: (json['cost_per_hour'] as num).toDouble(),
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

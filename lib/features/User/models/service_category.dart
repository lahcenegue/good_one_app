class ServiceCategory {
  final int id;
  final String name;
  final String image;

  final List<SubCategoryItem> subcategories;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.subcategories,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    var subcategoryListFromJson = json['subcategory'] as List<dynamic>?;
    List<SubCategoryItem> parsedSubcategories = [];
    if (subcategoryListFromJson != null) {
      parsedSubcategories = subcategoryListFromJson
          .map((i) => SubCategoryItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return ServiceCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      subcategories: parsedSubcategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'subcategory': subcategories.map((s) => s.toJson()).toList(),
    };
  }
}

class SubCategoryItem {
  final int id;
  final String name;

  SubCategoryItem({required this.id, required this.name});

  factory SubCategoryItem.fromJson(Map<String, dynamic> json) {
    return SubCategoryItem(
      id: json['id'] as int,
      name: json['name'] as String? ??
          'Unnamed Subcategory', // Handle potential null name
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

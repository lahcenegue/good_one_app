import 'package:good_one_app/Features/Worker/Models/subcategory_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String image;
  final List<SubcategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      subcategories: (json['subcategory'] as List<dynamic>)
          .map((sub) => SubcategoryModel.fromJson(sub as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() => name;
}

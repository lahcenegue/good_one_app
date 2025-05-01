import 'package:good_one_app/Features/Worker/Models/subcategory_model.dart';

class CategoryModel {
  final int id;
  final String name;
  final String image;
  final bool? hasLiscence;
  final List<SubcategoryModel> subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.hasLiscence,
    required this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      hasLiscence: json.containsKey('has_liscence_in_category')
          ? json['has_liscence_in_category'] as bool?
          : null,
      subcategories: (json['subcategory'] as List<dynamic>)
          .map((sub) => SubcategoryModel.fromJson(sub as Map<String, dynamic>))
          .toList(),
    );
  }

//   String toDebugString() {
//     return '''
// Category:
//   ID: $id
//   Name: $name
//   Image: $image
//   Has License: ${hasLiscence ?? 'null'}
//   Subcategories: [
//     ${subcategories.map((sub) => sub.toString()).join(',\n    ')}
//   ]
// ''';
//   }

  @override
  String toString() => name;
}

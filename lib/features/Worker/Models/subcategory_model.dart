class SubcategoryModel {
  final int id;
  final String name;

  SubcategoryModel({
    required this.id,
    required this.name,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => name;
}

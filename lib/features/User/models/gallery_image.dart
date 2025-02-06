class GalleryImage {
  final int id;
  final String image;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GalleryImage({
    required this.id,
    required this.image,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      id: json['id'] as int? ?? 0,
      image: json['image'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  GalleryImage copyWith({
    int? id,
    String? image,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GalleryImage(
      id: id ?? this.id,
      image: image ?? this.image,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'GalleryImage(id: $id, image: $image)';
}

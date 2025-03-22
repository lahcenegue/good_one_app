import 'dart:io';

class AddImageModel {
  final String? image;
  final String? serviceId;
  final int? id;

  AddImageModel({
    this.image,
    this.serviceId,
    this.id,
  });

  factory AddImageModel.fromJson(Map<String, dynamic> json) {
    return AddImageModel(
      image: json['image'] as String?,
      serviceId: json['service_id'] as String?,
      id: json['id'] as int?,
    );
  }
}

class AddImageRequest {
  final int? serviceId;
  final File? image;

  AddImageRequest({
    required this.serviceId,
    required this.image,
  });

  Map<String, String> toFields() {
    return {
      'service_id': serviceId!.toString(),
    };
  }

  Map<String, File> toFiles() {
    return {
      'image': image!,
    };
  }
}

import 'dart:io';

class CreateServiceModel {
  final int? serviceId;

  CreateServiceModel({
    required this.serviceId,
  });

  factory CreateServiceModel.fromJson(Map<String, dynamic> json) {
    return CreateServiceModel(serviceId: json['id']);
  }
}

class CreateServiceRequest {
  final String? category;
  final int? categoryId;
  final int? subCategoryId;
  final double? price;
  final String? description;
  final int? experience;
  final File? license;
  final int? serviceId;

  CreateServiceRequest({
    this.category,
    this.categoryId,
    this.subCategoryId,
    this.price,
    this.description,
    this.experience,
    this.license,
    this.serviceId,
  });

  Map<String, String> toFields() {
    final Map<String, String> fields = {};
    if (category != null) {
      fields['service'] = category!;
    }
    if (categoryId != null) {
      fields['category_id'] = categoryId!.toString();
    }
    if (subCategoryId != null) {
      fields['subcategory_id'] = subCategoryId!.toString();
    }
    if (price != null) {
      fields['cost_per_hour'] = price!.toString();
    }
    if (description != null) {
      fields['about'] = description!;
    }
    if (experience != null) {
      fields['years_of_experience'] = experience!.toString();
    }
    if (serviceId != null) {
      fields['service_id'] = serviceId!.toString();
    }

    return fields;
  }

  Map<String, File> toFiles() {
    if (license == null) {
      return {};
    } else {
      return {
        'license': license!,
      };
    }
  }
}

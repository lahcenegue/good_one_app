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
  final String? pricingType;
  final double? price;
  final String? description;
  final int? experience;
  final File? license;
  final int? serviceId;
  final int? active;

  CreateServiceRequest({
    this.category,
    this.categoryId,
    this.subCategoryId,
    this.pricingType,
    this.price,
    this.description,
    this.experience,
    this.license,
    this.serviceId,
    this.active,
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
    if (pricingType != null) {
      fields['pricing_type'] = pricingType!;
    }
    if (price != null && pricingType != null) {
      switch (pricingType!) {
        case 'hourly':
          fields['cost_per_hour'] = price!.toString();
          break;
        case 'daily':
          fields['cost_per_day'] = price!.toString();
          break;
        case 'fixed':
          fields['fixed_price'] = price!.toString();
          break;
      }
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
    if (active != null) {
      fields['active'] = active!.toString();
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

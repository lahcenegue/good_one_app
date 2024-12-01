import '../../../Core/Apis/api_service.dart';
import '../../../Core/Constants/app_links.dart';
import '../models/contractor.dart';
import '../models/service_category.dart';

class UserApi {
  static Future<ApiResponse<List<ServiceCategory>>> getCategories() async {
    return ApiService.get<List<ServiceCategory>>(
      url: AppLinks.categories,
      fromJson: (dynamic response) {
        if (response is List) {
          return response
              .map((item) =>
                  ServiceCategory.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Invalid response format');
      },
    );
  }

  static Future<ApiResponse<List<Contractor>>> getContractors() async {
    return ApiService.get<List<Contractor>>(
      url: AppLinks.contractors,
      fromJson: (dynamic response) {
        if (response is List) {
          return response
              .map((item) => Contractor.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Invalid response format');
      },
    );
  }
}

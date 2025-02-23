import 'package:good_one_app/Features/User/models/booking.dart';

import '../../../Core/infrastructure/api/api_response.dart';
import '../../../Core/infrastructure/api/api_service.dart';
import '../../../Core/infrastructure/api/api_endpoints.dart';
import '../models/contractor.dart';
import '../models/service_category.dart';
import '../models/user_info.dart';

class UserApi {
  static final _api = ApiService.instance;

  static Future<ApiResponse<UserInfo>> getUserInfo({String? token}) async {
    return _api.post<UserInfo>(
      url: ApiEndpoints.userProfile,
      body: {}, // Empty body since we're just authenticating with the token
      fromJson: (dynamic response) {
        if (response is Map<String, dynamic>) {
          return UserInfo.fromJson(response);
        }
        throw Exception('Invalid response format');
      },
      token: token,
    );
  }

  static Future<ApiResponse<List<ServiceCategory>>> getCategories() async {
    return _api.get<List<ServiceCategory>>(
      url: ApiEndpoints.categories,
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

  static Future<ApiResponse<List<Contractor>>> getBestContractors() async {
    return _api.get<List<Contractor>>(
      url: ApiEndpoints.bestcontractors,
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

  static Future<ApiResponse<List<Contractor>>> getContractorsByService(
      {required int? id}) async {
    return _api.get<List<Contractor>>(
      url: '${ApiEndpoints.contractorsByService}/$id',
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

  static Future<ApiResponse<List<Booking>>> getBookings({String? token}) async {
    return _api.get<List<Booking>>(
      url: ApiEndpoints.bookings,
      fromJson: (dynamic response) {
        if (response is List) {
          return response
              .map((item) => Booking.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Invalid response format');
      },
      token: token,
    );
  }
}

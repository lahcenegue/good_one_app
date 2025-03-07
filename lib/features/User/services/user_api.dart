import 'dart:convert';

import 'package:good_one_app/Features/User/models/booking.dart';
import 'package:http/http.dart' as http;

import '../../../Core/infrastructure/api/api_response.dart';
import '../../../Core/infrastructure/api/api_service.dart';
import '../../../Core/infrastructure/api/api_endpoints.dart';
import '../../../Core/presentation/resources/app_strings.dart';
import '../models/contractor.dart';
import '../models/coupom_model.dart';
import '../models/order_model.dart';
import '../models/service_category.dart';
import '../models/user_info.dart';

class UserApi {
  static final _api = ApiService.instance;

  static Future<ApiResponse<UserInfo>> getUserInfo({String? token}) async {
    return _api.post<UserInfo>(
      url: ApiEndpoints.me,
      body: {},
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
      url: ApiEndpoints.userOrders,
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

  static Future<ApiResponse<CouponModel>> checkCoupon(
      {String? token, required String coupon}) async {
    return _api.post<CouponModel>(
      url: ApiEndpoints.couponsCheck,
      body: {'coupon': coupon},
      fromJson: (dynamic response) {
        print('UserApi.checkCoupon fromJson input: $response');
        if (response is Map<String, dynamic>) {
          return CouponModel.fromJson(response);
        }
        throw Exception('Invalid coupon response format');
      },
      token: token,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    final headers = {
      'Authorization': 'Bearer ${AppStrings.stripeSecretKey}',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final body = {
      'amount': amount,
      'currency': currency,
      'payment_method_types[]': 'card',
    };

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.paymentApiUrl),
        headers: headers,
        body: body,
      );

      final decodedBody = jsonDecode(response.body);
      print('Payment Intent Response: $decodedBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(decodedBody);
      } else {
        return ApiResponse.error(decodedBody['error']?['message'] ??
            'Failed to create payment intent');
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      return ApiResponse.error('Failed to create payment intent: $e');
    }
  }

  static Future<ApiResponse<Order>> createServiceOrder(
      {String? token, required OrderRequest orderRequest}) async {
    return _api.post<Order>(
      url: ApiEndpoints.serviceOrder,
      body: orderRequest.toJson(),
      fromJson: (json) => Order.fromJson(json),
      token: token,
    );
  }
}

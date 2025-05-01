import 'dart:convert';
import 'package:good_one_app/Core/Config/app_config.dart';
import 'package:http/http.dart' as http;

import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_endpoints.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_response.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_service.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Features/User/Models/booking.dart';
import 'package:good_one_app/Features/User/Models/contractor.dart';
import 'package:good_one_app/Features/User/Models/order_model.dart';
import 'package:good_one_app/Features/User/Models/rate_model.dart';
import 'package:good_one_app/Features/User/Models/service_category.dart';
import 'package:good_one_app/Features/User/Models/coupon_model.dart';

class UserApi {
  static final _api = ApiService.instance;

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

  static Future<ApiResponse<List<Booking>>> getBookings() async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
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
      {required String coupon}) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    return _api.post<CouponModel>(
      url: ApiEndpoints.couponsCheck,
      body: {'coupon': coupon},
      fromJson: (dynamic response) {
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
      'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final body = {
      'amount': amount,
      'currency': currency,
      //'automatic_payment_methods[enabled]': 'true',
      'payment_method_types[]': 'card',
    };

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.paymentApiUrl),
        headers: headers,
        body: body,
      );

      final decodedBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(decodedBody);
      } else {
        return ApiResponse.error(decodedBody['error']?['message'] ??
            'Failed to create payment intent');
      }
    } catch (e) {
      return ApiResponse.error('Failed to create payment intent: $e');
    }
  }

  static Future<ApiResponse<Order>> createOrder(
      OrderRequest orderRequest) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    return _api.post<Order>(
      url: ApiEndpoints.createOrder,
      body: orderRequest.toJson(),
      fromJson: (json) => Order.fromJson(json),
      token: token,
    );
  }

  static Future<ApiResponse<Order>> receiveOrder(
      OrderEditRequest orderRequest) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    return _api.post<Order>(
      url: ApiEndpoints.receiveOrder,
      body: orderRequest.toJson(),
      fromJson: (json) => Order.fromJson(json),
      token: token,
    );
  }

  static Future<ApiResponse<Order>> cancelOrder(
      OrderEditRequest orderEdirRequest) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    return _api.post<Order>(
      url: ApiEndpoints.cancelOrder,
      body: orderEdirRequest.toJson(),
      fromJson: (json) => Order.fromJson(json),
      token: token,
    );
  }

  static Future<ApiResponse<Order>> updateOrder(
      OrderEditRequest orderEditRequest) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    return _api.post<Order>(
      url: ApiEndpoints.updateOrder,
      body: orderEditRequest.toJson(),
      fromJson: (json) => Order.fromJson(json),
      token: token,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> rateService(
      RateServiceRequest rateRequest) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    return _api.post<Map<String, dynamic>>(
      url: ApiEndpoints.rateService,
      body: rateRequest.toJson(),
      fromJson: (json) => json as Map<String, dynamic>,
      token: token,
    );
  }
}

import 'package:good_one_app/Core/Infrastructure/Api/api_endpoints.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_response.dart';
import 'package:good_one_app/Core/Infrastructure/Api/api_service.dart';
import 'package:good_one_app/Core/Infrastructure/Storage/storage_manager.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';

import 'package:good_one_app/Features/Both/Models/account_edit_request.dart';
import 'package:good_one_app/Features/Both/Models/notification_model.dart';
import 'package:good_one_app/Features/Both/Models/tax_model.dart';
import 'package:good_one_app/Features/Both/Models/user_info.dart';

class BothApi {
  static final _api = ApiService.instance;

  static Future<ApiResponse<UserInfo>> getUserInfo() async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
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

  static Future<ApiResponse<UserInfo>> editAccount(
      AccountEditRequest request) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);

    return _api.postMultipart<UserInfo>(
      url: ApiEndpoints.accountEdit,
      fields: request.toFields(),
      files: request.toFiles(),
      fromJson: (dynamic response) {
        if (response is Map<String, dynamic>) {
          return UserInfo.fromJson(response);
        }
        throw Exception('Invalid response format');
      },
      token: token,
    );
  }

  static Future<ApiResponse<List<NotificationModel>>>
      fetchNotifications() async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    return _api.get<List<NotificationModel>>(
      url: ApiEndpoints.notifications,
      fromJson: (dynamic response) {
        if (response is List) {
          final parsed = response
              .map((item) =>
                  NotificationModel.fromJson(item as Map<String, dynamic>))
              .toList();

          return parsed;
        }
        throw Exception('Invalid response format');
      },
      token: token,
    );
  }

  static Future<ApiResponse<TaxModel>> fetchTaxes(String region) async {
    return _api.get<TaxModel>(
      url: '${ApiEndpoints.taxes}?region=$region',
      fromJson: (dynamic response) {
        if (response is Map<String, dynamic>) {
          return TaxModel.fromJson(response);
        }
        throw Exception('Invalid response format');
      },
    );
  }
}

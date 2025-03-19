import 'package:good_one_app/Core/Infrastructure/storage/storage_manager.dart';
import 'package:good_one_app/Core/Utils/storage_keys.dart';
import 'package:good_one_app/Core/infrastructure/api/api_endpoints.dart';
import 'package:good_one_app/Core/infrastructure/api/api_response.dart';
import 'package:good_one_app/Core/infrastructure/api/api_service.dart';
import 'package:good_one_app/Features/Worker/Models/add_image_model.dart';
import 'package:good_one_app/Features/Worker/Models/category_model.dart';
import 'package:good_one_app/Features/Worker/Models/create_service_model.dart';
import 'package:good_one_app/Features/Worker/Models/my_order_model.dart';
import 'package:good_one_app/Features/Worker/Models/my_services_model.dart';

class WorkerApi {
  static final _api = ApiService.instance;

  static Future<ApiResponse<List<CategoryModel>>> fetchCategories() async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    try {
      final response = await _api.get<List<CategoryModel>>(
        url: ApiEndpoints.categories,
        fromJson: (dynamic json) {
          if (json is List) {
            return json
                .map((item) =>
                    CategoryModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          throw Exception('Invalid response format');
        },
        token: token,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Failed to fetch categories: $e');
    }
  }

  static Future<ApiResponse<List<MyServicesModel>>> fetchMyServices() async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    try {
      final response = await _api.get<List<MyServicesModel>>(
        url: ApiEndpoints.getMyService,
        fromJson: (dynamic json) {
          if (json is List) {
            return json
                .map((item) =>
                    MyServicesModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          throw Exception('Invalid response format');
        },
        token: token,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('Failed to fetch my service: $e');
    }
  }

  /// Adds an image to the gallery.
  Future<ApiResponse<AddImageModel>> addGalleryImage(
      AddImageRequest addImage) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);

    return await _api.postMultipart<AddImageModel>(
      url: ApiEndpoints.addImage,
      fields: addImage.toFields(),
      files: addImage.toFiles(),
      fromJson: (dynamic json) {
        if (json is Map<String, dynamic>) {
          return AddImageModel.fromJson(json);
        }
        throw Exception('Invalid add image');
      },
      token: token,
    );
  }

  /// Removes an image from the gallery.
  Future<ApiResponse<bool>> removeGalleryImage(int imageId) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    try {
      final response = await _api.post<bool>(
        url: ApiEndpoints.removeImage,
        body: {'id': imageId},
        fromJson: (dynamic json) {
          if (json is int) {
            return true;
          }
          throw Exception('Invalid remove image');
        },
        token: token,
      );
      if (response.data == true) {
        return ApiResponse.success(true);
      }
      return ApiResponse.error('Failed to delete image: Invalid response');
    } catch (e) {
      return ApiResponse.error('Failed to remove image: $e');
    }
  }

  static Future<ApiResponse<CreateServiceModel>> createNewService(
      CreateServiceRequest request) async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);

    return _api.postMultipart(
      url: ApiEndpoints.createNewService,
      fields: request.toFields(),
      files: request.toFiles(),
      fromJson: (dynamic json) {
        if (json is Map<String, dynamic>) {
          return CreateServiceModel.fromJson(json);
        }
        throw Exception('feiled to create a service');
      },
      token: token,
    );
  }

  static Future<ApiResponse<Map<String, List<MyOrderModel>>>>
      fetchOrders() async {
    final token = await StorageManager.getString(StorageKeys.tokenKey);
    try {
      final response = await _api.get<Map<String, List<MyOrderModel>>>(
        url: ApiEndpoints.serviceOrders,
        fromJson: (dynamic json) {
          print(
              'fetchOrders fromJson input: $json (type: ${json.runtimeType})');
          // Ensure json is a Map
          if (json is Map) {
            // Cast to Map<String, dynamic> to ensure keys are strings
            final map = json.cast<String, dynamic>();
            return map.map((key, value) {
              if (value is List) {
                return MapEntry(
                  key,
                  value.map((item) {
                    if (item is Map<String, dynamic>) {
                      return MyOrderModel.fromJson(item);
                    }
                    throw Exception(
                        'Invalid order format in list for date: $key, item: $item (type: ${item.runtimeType})');
                  }).toList(),
                );
              }
              throw Exception(
                  'Invalid orders format for date: $key, value: $value (type: ${value.runtimeType})');
            });
          }
          throw Exception(
              'Invalid response format: Expected a map of dates to orders, got: $json (type: ${json.runtimeType})');
        },
        token: token,
      );
      return response;
    } catch (e) {
      print('fetchOrders error: $e');
      return ApiResponse.error('Failed to fetch orders: $e');
    }
  }
}

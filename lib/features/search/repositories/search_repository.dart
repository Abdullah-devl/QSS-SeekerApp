import 'package:dio/dio.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../home/services/models/service_model.dart';

/// 📂 اسم الملف: search_repository.dart
/// 📝 الوصف: المستودع المسؤول عن معالجة طلبات البحث من السيرفر.

class SearchRepository {
  final ApiService _apiService;

  SearchRepository(this._apiService);

  /// 🔍 البحث المتقدم عن الخدمات
  Future<List<ServiceModel>> searchServices({
    String? query,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? isVerified,
    double? lat,
    double? lng,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};

      if (query != null && query.isNotEmpty) queryParameters['query'] = query;
      if (categoryId != null) queryParameters['category_id'] = categoryId;
      if (minPrice != null) queryParameters['min_price'] = minPrice;
      if (maxPrice != null) queryParameters['max_price'] = maxPrice;
      if (isVerified == true) queryParameters['is_verified'] = 1;
      if (lat != null) queryParameters['lat'] = lat;
      if (lng != null) queryParameters['lng'] = lng;

      final Response response = await _apiService.get(
        ApiEndpoints.searchServices,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        // نتوقع قائمة من الخدمات مباشرة أو داخل مفتاح 'data'
        final dynamic data = response.data;
        List<dynamic> list = [];

        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('data')) {
          list = data['data'];
        }

        return list.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }
}

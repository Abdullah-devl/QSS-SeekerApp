import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/core/network/api_endpoints.dart';
import 'package:seeker/features/home/services/models/service_model.dart';

class FavoriteRemoteDataSource {
  final ApiService _apiService;

  FavoriteRemoteDataSource(this._apiService);

  /// 📜 جلب قائمة الخدمات المفضلة
  Future<List<ServiceModel>> getFavorites() async {
    final response = await _apiService.get(ApiEndpoints.favorites);
    if (response.statusCode == 200) {
      // السيرفر يرجع البيانات في حقل 'favorites' بناءً على الكونسول
      final List data =
          response.data['favorites'] ?? response.data['data'] ?? [];
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load favorites');
  }

  /// ❤️ إضافة أو حذف الخدمة من المفضلة
  Future<bool> toggleFavorite(int serviceId) async {
    final response = await _apiService.post(
      ApiEndpoints.toggleFavorite,
      data: {'service_id': serviceId},
    );
    // عادة السيرفر يرجع حالة النجاح أو رسالة
    return response.statusCode == 200 || response.statusCode == 201;
  }
}

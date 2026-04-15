import 'package:seeker/features/favorites/data_sources/favorite_remote_data_source.dart';
import 'package:seeker/features/home/services/models/service_model.dart';

class FavoriteRepository {
  final FavoriteRemoteDataSource _remoteDataSource;

  FavoriteRepository(this._remoteDataSource);

  /// جلب المفضلة من السيرفر
  Future<List<ServiceModel>> getFavorites() async {
    try {
      return await _remoteDataSource.getFavorites();
    } catch (e) {
      rethrow;
    }
  }

  /// تبديل حالة المفضلة (إضافة/حذف)
  Future<bool> toggleFavorite(int serviceId) async {
    try {
      return await _remoteDataSource.toggleFavorite(serviceId);
    } catch (e) {
      rethrow;
    }
  }
}

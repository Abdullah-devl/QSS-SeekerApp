import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/core/network/api_endpoints.dart';
import '../models/advertisement_model.dart';

/// 📂 اسم الملف: advertisement_repository.dart
/// 📝 الوصف: مسؤول عن جلب بيانات الإعلانات وتتبع التفاعلات (المشاهدات والنقرات).

class AdvertisementRepository {
  final ApiService _apiService;

  AdvertisementRepository(this._apiService);

  /// 🚀 جلب الإعلانات النشطة بناءً على نوع المستخدم أو القسم.
  Future<List<AdvertisementModel>> fetchAdvertisements(String userType, {int? categoryId}) async {
    try {
      final Map<String, dynamic> params = {'user_type': userType};
      if (categoryId != null) {
        params['category_id'] = categoryId;
      }

      final Response response = await _apiService.get(
        ApiEndpoints.advertisements,
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        // 🔍 طباعة البيانات الخام للتأكد من المسميات
        debugPrint('🌐 [API Advertisements Raw Data]: $data');

        List<dynamic> list = [];

        if (data is List) {
          list = data;
        } else if (data is Map && data.containsKey('data')) {
          list = data['data'];
        }

        return list.map((json) => AdvertisementModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 👁️ إرسال طلب تتبع المشاهدة (Impression).
  /// يتم في الخلفية لضمان عدم تأثر تجربة المستخدم.
  Future<void> trackView(int adId) async {
    try {
      await _apiService.post(ApiEndpoints.trackAdView(adId), data: {});
    } catch (e) {
      // تفشل بصمت في الخلفية
    }
  }

  /// 🖱️ إرسال طلب تتبع النقرة.
  Future<void> trackClick(int adId) async {
    try {
      await _apiService.post(ApiEndpoints.trackAdClick(adId), data: {});
    } catch (e) {
      // تفشل بصمت في الخلفية
    }
  }
}

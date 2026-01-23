import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';

/// 📂 اسم الملف: home_repository.dart
/// 📝 الوصف: المستودع (Repository) الخاص بالصفحة الرئيسية.
/// مسؤول عن جلب البيانات من السيرفر (التصنيفات، الخدمات الشائعة) وتحويلها إلى موديلات.

class HomeRepository {
  final ApiService _apiService; // خدمة الاتصال بالـ API

  HomeRepository(this._apiService);

  // ===========================================================================
  // 📦 جلب التصنيفات (Categories)
  // ===========================================================================

  /// يقوم بجلب قائمة التصنيفات من السيرفر.
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final Response response = await _apiService.get(ApiEndpoints.categories);

      if (response.statusCode == 200) {
        developer.log(
          '📦 Raw Categories Data: ${response.data}',
          name: 'HomeRepository',
        );

        // التعامل مع هيكلية البيانات المختلفة المحتملة من السيرفر
        final dynamic data = response.data;
        List<dynamic> list = [];

        // 1. إذا كانت البيانات قائمة مباشرة
        if (data is List) {
          list = data;
        }
        // 2. إذا كانت داخل مفتاح 'data'
        else if (data is Map && data.containsKey('data')) {
          list = data['data'];
        }
        // 3. إذا كانت داخل مفتاح 'categories'
        else if (data is Map && data.containsKey('categories')) {
          list = data['categories'];
        }

        // تحويل القائمة إلى كائنات CategoryModel
        return list.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        developer.log(
          '❌ Failed to load categories: Status ${response.statusCode}',
          name: 'HomeRepository',
        );
        // في حال الفشل نرجع قائمة فارغة
        return [];
      }
    } catch (e) {
      developer.log(
        '❌ Error fetching categories: $e',
        name: 'HomeRepository',
        error: e,
      );
      // في حال حدوث استثناء نرجع قائمة فارغة لعدم تعطيل الواجهة
      return [];
    }
  }

  // ===========================================================================
  // 🔥 جلب الخدمات الأكثر طلباً (Popular Services)
  // ===========================================================================

  /// يقوم بجلب قائمة الخدمات الشائعة.
  Future<List<ServiceModel>> fetchPopularServices() async {
    try {
      final Response response = await _apiService.get(
        ApiEndpoints.popularServices,
      );
      if (response.statusCode == 200) {
        // نتوقع أن تكون البيانات داخل مفتاح 'data'
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      // تفشل بصمت وترجع قائمة فارغة
      return [];
    }
  }
}

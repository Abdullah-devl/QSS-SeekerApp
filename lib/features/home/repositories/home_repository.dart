// import 'dart:developer';

// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:seeker/features/home/models/category_model.dart';
// import 'package:seeker/features/home/models/service_model.dart';
// import 'package:seeker/features/home/repositories/home_local_data_source.dart';
// import 'package:seeker/features/home/repositories/home_remote_data_source.dart';

// class HomeRepository {
//   final HomeRemoteDataSource remote;
//   final HomeLocalDataSource local;
//   final Connectivity connectivity;

//   HomeRepository(this.remote, this.local, this.connectivity);

//   Future<List<Category>> getCategories() async {
//     if (await connectivity.hasInternet()) {
//       final data = await remote.getCategories();
//       await local.saveCategories(data);
//       return data;
//     } else {
//       return local.getCategories();
//     }
//   }

//   Future<List<Service>> getTopServices() async {
//     if (await connectivity.hasInternet()) {
//       final data = await remote.getTopServices();
//       await local.saveTopServices(data);
//       return data;
//     } else {
//       return local.getTopServices();
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/category_model.dart';

import '../models/service_model.dart';
import '../models/category_details_model.dart';
import '../../../../core/errors/api_error_handler.dart'; // ✅ الاستيراد الجديد

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

  // ===========================================================================
  // 📂 جلب تفاصيل التصنيف (Category Details)
  // ===========================================================================

  /// يقوم بجلب تفاصيل التصنيف (تصنيفات فرعية، خدمات، موصى بهم).
  // Future<CategoryDetailsModel> fetchCategoryDetails(int categoryId) async {
  //   try {
  //     final Response response = await _apiService.get(
  //       ApiEndpoints.categoryDetails(categoryId),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       // نتوقع أن تكون البيانات إما مباشرة أو داخل مفتاح 'data'
  //       final Map<String, dynamic> jsonResponse =
  //           (data is Map && data.containsKey('data')) ? data['data'] : data;

  //       return CategoryDetailsModel.fromJson(jsonResponse);
  //     } else {
  //       return CategoryDetailsModel(); // إرجاع كائن فارغ عند الفشل
  //     }
  //   } catch (e) {
  //     // print('❌ fetchCategoryDetails ERROR: $e');
  //     // 🛑 استخدام معالج الأخطاء المركزي
  //     throw ApiErrorHandler.handle(e);
  //   }
  // }
  Future<CategoryDetailsModel> fetchCategoryDetails(int categoryId) async {
    final Response response = await _apiService.get(
      ApiEndpoints.categoryDetails(categoryId),
    );

    // print('✅ URL: ${response.requestOptions.uri}');
    // print('✅ STATUS: ${response.statusCode}');
    // print('✅ RAW: ${response.data}');

    if (response.statusCode == 200) {
      final data = response.data;

      final Map<String, dynamic> jsonResponse =
          (data is Map && data.containsKey('data')) ? data['data'] : data;

      print('✅ PARSED: $jsonResponse');

      return CategoryDetailsModel.fromJson(jsonResponse);
    }

    throw Exception(
      'Request failed: ${response.statusCode} - ${response.data}',
    );
  }
}

// ===========================================================================
// 🔍 جلب تفاصيل خدمة معينة (مع خدماتها الفرعية)
// ===========================================================================
Future<ServiceModel> fetchServiceById(int serviceId) async {
  try {
    // 🚀 استدعاء الرابط: GET /services/{id}
    var _apiService;
    final Response response = await _apiService.get('/services/$serviceId');

    if (response.statusCode == 200) {
      // استخراج البيانات (سواء كانت داخل 'data' أو مباشرة)
      final data = response.data;
      final Map<String, dynamic> jsonResponse =
          (data is Map && data.containsKey('data')) ? data['data'] : data;

      // 🪄 المودل الخاص بك (ServiceModel) سيقوم تلقائياً بقراءة الخدمات الفرعية بفضل تعديلنا السابق!
      return ServiceModel.fromJson(jsonResponse);
    } else {
      throw Exception('فشل في تحميل الخدمة');
    }
  } catch (e) {
    throw Exception('خطأ في الاتصال: $e');
  }
}

import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/profile_model.dart';
import '../models/work_model.dart';
import 'dart:developer' as developer;

/// 📂 اسم الملف: profile_repository.dart
/// 📝 الوصف: المستودع (Repository) الخاص بصفحة الملف الشخصي.
/// مسؤول عن جلب بيانات المستخدم أو المزود من السيرفر.
class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  /// 👤 جلب بيانات الملف الشخصي (النبذة، معرض الأعمال) لمستخدم معين.
  Future<ProfileModel> fetchUserProfile(int userId) async {
    try {
      final Response response = await _apiService.get(ApiEndpoints.userProfile(userId));

      if (response.statusCode == 200) {
        final data = response.data;
        final Map<String, dynamic> jsonResponse =
            (data is Map && data.containsKey('data')) ? data['data'] : data;

        return ProfileModel.fromJson(jsonResponse);
      } else {
        throw Exception('فشل في تحميل الملف الشخصي');
      }
    } on DioException catch (e) {
      developer.log('❌ ProfileRepository: Dio Error: $e');
      throw Exception('خطأ في الاتصال بالخادم: ${e.message}');
    } catch (e) {
      developer.log('❌ ProfileRepository: Unexpected Error: $e');
      throw Exception('خطأ غير متوقع: $e');
    }
  }

  /// 📸 جلب معرض الأعمال السابقة لمزود معين بناءً على معرفه.
  Future<List<WorkModel>> fetchProviderWorks(int userId) async {
    try {
      final Response response = await _apiService.get(ApiEndpoints.previousWorks(userId));
      
      // 🚀 طباعة الرد القادم من أجل التشخيص
      developer.log('📸 [ProfileRepository] Raw Previous Works Data: ${response.data}');

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        
        // 🚀 معالجة ذكية لشكل الرد القادم من السيرفر
        List<dynamic> list = [];
        
        if (responseData is List) {
          list = responseData;
        } else if (responseData is Map) {
          // إذا كانت البيانات مغلفة في 'data'
          final dynamic dataField = responseData['data'];
          if (dataField is List) {
            list = dataField;
          } else if (dataField is Map && dataField.containsKey('data') && dataField['data'] is List) {
            // حالة الـ Pagination (بيانات داخل بيانات)
            list = dataField['data'];
          } else if (responseData.containsKey('works') && responseData['works'] is List) {
             list = responseData['works'];
          } else if (responseData.containsKey('previousWorks') && responseData['previousWorks'] is List) {
             list = responseData['previousWorks'];
          }
        }

        return list.map((json) => WorkModel.fromJson(Map<String, dynamic>.from(json))).toList();
      } else {
        throw Exception('فشل في تحميل الأعمال السابقة لمقدم الخدمة');
      }
    } catch (e) {
      developer.log('❌ ProfileRepository: fetchProviderWorks Error: $e');
      throw e;
    }
  }

  /// 📸 جلب معرض الأعمال السابقة لمزود معين.
  Future<List<WorkModel>> getPreviousWorks() async {
    try {
      // 💡 يتم استخدام endpoint معرض الأعمال المناسب (أو نفس الـ profile إذا كانت الأعمال داخله)
      // لكن بناءً على طلب المستخدم، سنفترض وجود نقطة نهاية خاصة للمعرض أو نأخذها من الـ Profile
      // هنا سنستخدم تجريبياً endpoint افتراضي أو نعدل حسب الحاجة
      final Response response = await _apiService.get('${ApiEndpoints.baseUrl}/user-works');

      if (response.statusCode == 200) {
        final List data = (response.data is Map && response.data.containsKey('data')) 
            ? response.data['data'] 
            : response.data;
        return data.map((json) => WorkModel.fromJson(json)).toList();
      } else {
        throw Exception('فشل في تحميل الأعمال السابقة');
      }
    } catch (e) {
      developer.log('❌ ProfileRepository: GetWorks Error: $e');
      throw e;
    }
  }

  /// 🗑️ حذف عمل سابق من معرض الأعمال.
  Future<void> deleteWork(int workId) async {
    try {
      final Response response = await _apiService.delete('/user-profile/works/$workId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('فشل في حذف العمل');
      }
    } catch (e) {
      developer.log('❌ ProfileRepository: Delete Error: $e');
      throw e;
    }
  }
}

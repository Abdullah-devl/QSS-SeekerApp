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
      developer.log('📡 [ProfileRepo] fetchUserProfile Response: ${response.data}');

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

  /// 👤 جلب بيانات الملف الشخصي للمستخدم الحالي.
  Future<ProfileModel> fetchMyProfile() async {
    try {
      final Response response = await _apiService.get(ApiEndpoints.myProfile);
      developer.log('📡 [ProfileRepo] fetchMyProfile Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final Map<String, dynamic> jsonResponse =
            (data is Map && data.containsKey('data')) ? data['data'] : data;

        return ProfileModel.fromJson(jsonResponse);
      } else {
        throw Exception('فشل في تحميل ملفك الشخصي');
      }
    } on DioException catch (e) {
      developer.log('❌ ProfileRepository: fetchMyProfile Dio Error: $e');
      throw Exception('خطأ في الاتصال بالخادم: ${e.message}');
    } catch (e) {
      developer.log('❌ ProfileRepository: fetchMyProfile Unexpected Error: $e');
      throw Exception('خطأ غير متوقع في جلب بياناتك: $e');
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
          } else if (responseData.containsKey('previous_works') && responseData['previous_works'] is List) {
             list = responseData['previous_works'];
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

  /// 👤 تحديث بيانات الملف الشخصي.
  Future<void> updateProfile({
    required int profileId,
    required String name,
    required String bio,
    String? avatarPath,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // 📝 استخدام FormData لدعم رفع الصور وتمرير البيانات المعقدة
      // ملاحظة: نستخدم POST مع _method=PUT لأن PHP لا يستقبل FormData في طلب PUT الحقيقي
      final Map<String, dynamic> data = {
        '_method': 'PUT',
        'name': name,
        'bio': bio,
      };

      if (avatarPath != null && avatarPath.isNotEmpty) {
        data['image'] = await MultipartFile.fromFile(
          avatarPath,
          filename: avatarPath.split('/').last,
        );
      }

      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final formData = FormData.fromMap(data);

      final Response response = await _apiService.post(
        ApiEndpoints.updateProfile(profileId),
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('فشل في تحديث الملف الشخصي');
      }
    } catch (e) {
      developer.log('❌ ProfileRepository: updateProfile Error: $e');
      throw e;
    }
  }

  /// 📞 إضافة رقم هاتف جديد.
  Future<void> addPhone({
    required String phone,
    String? type,
    String countryCode = '',
  }) async {
    try {
      final response = await _apiService.post(ApiEndpoints.profilePhones, data: {
        'phone': phone,
        'country_code': countryCode,
        'type': type ?? 'mobile', // تم التعديل من phone إلى mobile
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('فشل في إضافة الرقم');
      }
    } catch (e) {
      developer.log('❌ ProfileRepository: addPhone Error: $e');
      throw e;
    }
  }

  /// 📞 تحديث رقم هاتف موجود.
  Future<void> updatePhone({
    required int phoneId,
    required String phone,
    String? type,
    String countryCode = '',
  }) async {
    try {
      final response = await _apiService.put(ApiEndpoints.profilePhone(phoneId), data: {
        'phone': phone,
        'country_code': countryCode,
        'type': type ?? 'mobile', // تم التعديل من phone إلى mobile
      });

      if (response.statusCode != 200) {
        throw Exception('فشل في تحديث الرقم');
      }
    } catch (e) {
      developer.log('❌ ProfileRepository: updatePhone Error: $e');
      throw e;
    }
  }

  /// 📞 حذف رقم هاتف.
  Future<void> deletePhone(int phoneId) async {
    try {
      final response = await _apiService.delete(ApiEndpoints.profilePhone(phoneId));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('فشل في حذف الرقم');
      }
    } catch (e) {
      developer.log('❌ ProfileRepository: deletePhone Error: $e');
      throw e;
    }
  }
}

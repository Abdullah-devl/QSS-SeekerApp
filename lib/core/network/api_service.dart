import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'api_endpoints.dart';
import '../storage/token_storage.dart';

/// 📂 اسم الملف: api_service.dart
/// 📝 الوصف: يحتوي هذا الملف على كلاس `ApiService` المسؤول عن إدارة جميع طلبات الشبكة (HTTP Requests).
/// يستخدم مكتبة `Dio` لتنفيذ الطلبات ويدعم إضافة الـ Token تلقائياً والتعامل مع الأخطاء.

class ApiService {
  /// 🛠️ كائن Dio: هو المكتبة المستخدمة لإجراء الاتصالات بالإنترنت.
  final Dio _dio;

  /// 🗄️ كائن TokenStorage: يستخدم للوصول إلى الـ Token المخزن محلياً.
  final TokenStorage _tokenStorage;

  /// 🏗️ البناء (Constructor):
  /// يقوم بتهيئة كائن Dio مع الإعدادات الأساسية (BaseOptions) وإضافة الـ Interceptors.
  ApiService(this._tokenStorage)
    : _dio = Dio(
        BaseOptions(
          /// 🔗 الرابط الأساسي: يتم جلبه من كلاس ApiEndpoints.
          baseUrl: ApiEndpoints.baseUrl,

          /// ⏳ مدة انتظار الاتصال (Connection Timeout): 15 ثانية.
          connectTimeout: const Duration(seconds: 15),

          /// ⏳ مدة انتظار استقبال البيانات (Receive Timeout): 15 ثانية.
          receiveTimeout: const Duration(seconds: 15),

          /// 📋 الهيدرز (Headers) الافتراضية لكل الطلبات.
          headers: {
            // 'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    // 🕵️ إضافة Interceptors (اعتراض الطلبات والاستجابات)
    // تسمح لنا بتعديل الطلب قبل إرساله أو معالجة الاستجابة فور وصولها.
    _dio.interceptors.add(
      InterceptorsWrapper(
        // 📤 عند إرسال الطلب (On Request)
        onRequest: (options, handler) async {
          // 🔑 التحقق من وجود Token وإضافته إلى الهيدر (Authorization).
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            // 📝 طباعة جزء من الـ Token في الـ Console للتأكد.
            developer.log(
              '🔑 Attached Token: Bearer ...${token.substring(token.length - 5)}',
              name: 'ApiService',
            );
          }

          // 🚀 طباعة الرابط الذي يتم إرسال الطلب إليه.
          developer.log(
            '🚀 Sending request to: ${options.uri}',
            name: 'ApiService',
          );
          return handler.next(options); // ✅ متابعة إرسال الطلب
        },

        // 📥 عند استقبال الرد (On Response)
        onResponse: (response, handler) {
          // ✅ طباعة تأكيد وصول الرد بنجاح.
          developer.log(
            '✅ Response received from: ${response.requestOptions.uri}',
            name: 'ApiService',
          );
          return handler.next(response); // ✅ تمرير الرد للكود الذي طلبه
        },

        // ❌ عند حدوث خطأ (On Error)
        onError: (DioException e, handler) {
          developer.log('❌ Error: ${e.message}', name: 'ApiService', error: e);

          // ⚠️ التحقق مما إذا كان الخطأ بسبب انتهاء الصلاحية (401 Unauthorized).
          if (e.response?.statusCode == 401) {
            developer.log(
              '⚠️ Unauthorized! Token might be expired.',
              name: 'ApiService',
            );
          }
          // ⚠️ طباعة تفاصيل أخطاء التحقق (422 Validation Error)
          if (e.response?.statusCode == 422) {
            developer.log(
              '⚠️ Validation Error: ${e.response?.data}',
              name: 'ApiService',
              error: e.response?.data,
            );
          }
          return handler.next(
            e,
          ); // ⚠️ تمرير الخطأ ليتم معالجته في المكان المناسب
        },
      ),
    );
  }

  // ===========================================================================
  // 📡 دوال الطلبات الأساسية (HTTP Methods)
  // ===========================================================================

  /// 🔹 دالة GET: لجلب البيانات من السيرفر.
  /// [endpoint]: المسار الفرعي للرابط (مثلاً `/home`).
  /// [queryParameters]: المعاملات الإضافية في الرابط (مثلاً `?page=1`).
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow; // ⚠️ إعادة رمي الخطأ ليعالجه الـ Repository أو الـ ViewModel
    }
  }

  /// 🔹 دالة POST: لإرسال بيانات جديدة إلى السيرفر (مثل تسجيل الدخول).
  /// [endpoint]: المسار الفرعي.
  /// [data]: البيانات المراد إرسالها (عادة تكون Map أو Json).
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: options, //هاذا من اجل الصور
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 دالة PUT: لتحديث بيانات موجودة مسبقاً.
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// 🔹 دالة DELETE: لحذف بيانات من السيرفر.
  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

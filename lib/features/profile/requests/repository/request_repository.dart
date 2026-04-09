import 'package:dio/dio.dart';
import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/core/network/api_endpoints.dart';
import 'dart:developer' as developer;

/// 📂 اسم الملف: request_repository.dart
/// 📝 الوصف: المستودع المسؤول عن إرسال الطلبات (المخصصة واللقاءات الجسدية).
class RequestRepository {
  final ApiService _apiService;

  RequestRepository(this._apiService);

  /// 🛠️ إرسال طلب مخصص.
  /// [providerId]: معرف مقدم الخدمة.
  /// [message]: تفاصيل المشكلة/الطلب.
  /// [latitude] & [longitude]: الموقع الجغرافي (اختياري).
  Future<bool> sendCustomRequest({
    required int providerId,
    required String message,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final requestBody = {
        'provider_id': providerId,
        'message': message,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      // 📝 سجل طلب مخصص مفصل للتشخيص
      developer.log('🚀 Sending Custom Request Data: $requestBody', name: 'RequestRepository');

      final response = await _apiService.post(
        ApiEndpoints.customRequest,
        data: requestBody,
      );

      developer.log('✅ Custom Request Response: ${response.data}======', name: 'RequestRepository');
      return response.statusCode == 200 || response.statusCode == 201;

    } on DioException catch (e) {
      String errorMessage = 'فشل في إرسال الطلب المخصص';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      developer.log('❌ Error sending custom request: $errorMessage', name: 'RequestRepository');
      throw Exception(errorMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'RequestRepository');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// 🤝 إرسال طلب لقاء جسدي (حضور).
  /// [providerId]: معرف مقدم الخدمة.
  /// [latitude] & [longitude]: الموقع الجغرافي (ضروري).
  Future<bool> sendMeetingRequest({
    required int providerId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final requestBody = {
        'provider_id': providerId,
        'latitude': latitude,
        'longitude': longitude,
      };

      developer.log('🚀 Sending Meeting Request Data: $requestBody', name: 'RequestRepository');

      final response = await _apiService.post(
        ApiEndpoints.meetingRequest,
        data: requestBody,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      String errorMessage = 'فشل في إرسال طلب الحضور';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      developer.log('❌ Error sending meeting request: $errorMessage', name: 'RequestRepository');
      throw Exception(errorMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'RequestRepository');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  /// 📝 إنشاء طلب خدمة عادي (POST /api/requests).
  /// [serviceId]: المعرف الأساسي للخدمة.
  /// [message]: ملاحظات إضافية.
  /// [latitude] & [longitude]: الموقع الجغرافي.
  /// [supServices]: قائمة الخدمات الفرعية بتنسيق [{"id": 1, "quantity": 2}, ...].
  Future<bool> createServiceRequest({
    required int serviceId,
    String? message,
    double? latitude,
    double? longitude,
    List<Map<String, dynamic>>? supServices,
  }) async {
    try {
      final requestBody = {
        'service_id': serviceId,
        if (message != null) 'message': message,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (supServices != null && supServices.isNotEmpty) 'sup_services': supServices,
      };

      developer.log('🚀 Creating Service Request: $requestBody', name: 'RequestRepository');

      final response = await _apiService.post(
        ApiEndpoints.createRequest,
        data: requestBody,
      );

      developer.log('✅ Service Request Response: ${response.data}', name: 'RequestRepository');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      String errorMessage = 'فشل في إنشاء طلب الخدمة';
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      developer.log('❌ Error creating service request: $errorMessage', name: 'RequestRepository');
      throw Exception(errorMessage);
    } catch (e) {
      developer.log('❌ Unexpected error: $e', name: 'RequestRepository');
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }
}

import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
// import '../models/system_complaint_model.dart';
import 'dart:developer' as developer;

class SettingsRepository {
  final ApiService _apiService;

  SettingsRepository(this._apiService);

  /// جلب بيانات السياسة بناءً على الدور (seeker / provider).
  Future<Map<String, dynamic>> getPolicy(String role) async {
    try {
      final response = await _apiService.get(ApiEndpoints.policy(role));
      developer.log('📡 [SettingsRepo] getPolicy Response: ${response.data}');

      if (response.statusCode == 200 && response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('فشل جلب سياسة الخصوصية');
    } catch (e) {
      developer.log('❌ [SettingsRepo] getPolicy Error: $e');
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('حدث خطأ أثناء تحميل البيانات');
    }
  }

  /// الموافقة على السياسة (PATCH).
  Future<void> agreeToPolicy(String role) async {
    try {
      final response = await _apiService.patch(ApiEndpoints.policy(role));
      developer.log('📡 [SettingsRepo] agreeToPolicy Response: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('فشل في إرسال الموافقة');
      }
    } catch (e) {
      developer.log('❌ [SettingsRepo] agreeToPolicy Error: $e');
      if (e is DioException && e.response?.data != null) {
        throw Exception(e.response?.data['message'] ?? 'حدث خطأ في الشبكة');
      }
      throw Exception('فشل في الموافقة على السياسة');
    }
  }
}

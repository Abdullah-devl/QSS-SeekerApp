import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/system_complaint_model.dart';

class SettingsRepository {
  final ApiService _apiService;

  SettingsRepository(this._apiService);

  /// جلب بيانات السياسة بناءً على الدور (seeker / provider).
  Future<Map<String, dynamic>> getPolicy(String role) async {
    try {
      final response = await _apiService.get(ApiEndpoints.policy(role));

      if (response.statusCode == 200 && response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('فشل جلب سياسة الخصوصية');
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('حدث خطأ أثناء تحميل البيانات');
    }
  }

  /// جلب قائمة شكاوى النظام للمستخدم.
  Future<List<SystemComplaintModel>> getSystemComplaints(String source) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.systemComplaints,
        queryParameters: {'app_source': source},
      );

      if (response.statusCode == 200) {
        final rawData = response.data;
        List listData = [];
        
        if (rawData is Map) {
          // التعامل مع هيكل الـ API: {SystemComplaints: {data: [...]}}
          if (rawData.containsKey('SystemComplaints') && rawData['SystemComplaints'] is Map) {
            listData = rawData['SystemComplaints']['data'] ?? [];
          } else if (rawData.containsKey('data')) {
            listData = rawData['data'] ?? [];
          }
        } else if (rawData is List) {
          listData = rawData;
        }
        
        return listData.map((item) => SystemComplaintModel.fromJson(item)).toList();
      }
      throw Exception('فشل جلب قائمة الشكاوى');
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل الشكاوى');
    }
  }

  /// إرسال شكوى نظامية جديدة.
  Future<void> createSystemComplaint(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.systemComplaints,
        data: data,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('فشل إرسال الشكوى');
      }
    } catch (e) {
      if (e is DioException && e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map && responseData['errors'] != null) {
           // التعامل مع أخطاء التحقق
           String error = '';
           (responseData['errors'] as Map).forEach((key, value) {
             error += '${value[0]}\n';
           });
           throw Exception(error.trim());
        }
        throw Exception(responseData['message'] ?? 'فشل إرسال الشكوى');
      }
      throw Exception('حدث خطأ غير متوقع');
    }
  }
}

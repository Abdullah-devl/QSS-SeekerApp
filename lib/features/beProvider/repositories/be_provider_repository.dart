import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/provider_request_model.dart';

/// 📂 اسم الملف: be_provider_repository.dart
/// 📝 الوصف: مستودع البيانات الخاص بطلب الانضمام كمزود خدمة.
class BeProviderRepository {
  final ApiService _apiService;

  BeProviderRepository(this._apiService);

  /// 🚀 إرسال طلب الانضمام
  Future<String> submitRequest(ProviderRequestModel request) async {
    try {
      final formData = await request.toFormData();
      // ملاحظة: المسار '/provider-requests' يجب أن يضاف إلى ApiEndpoints إذا لم يكن موجوداً
      // أو نستخدمه مباشرة هنا بناءً على طلب المستخدم
      // const endpoint = ApiEndpoints.providerRequests;

      final response = await _apiService.post(
        ApiEndpoints.beProvider,
        data: await request.toFormData(),
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data['message'] ?? 'تم إرسال الطلب بنجاح';
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 422 || e.response?.statusCode == 403) {
          final data = e.response?.data;
          if (data is Map) {
            String errorMessage = data['message'] ?? 'حدث خطأ غير متوقع';
            if (data['errors'] != null && data['errors'] is Map) {
              final errors = data['errors'] as Map;
              final messages = <String>[];
              errors.forEach((key, value) {
                if (value is List) {
                  messages.addAll(value.map((e) => e.toString()));
                } else {
                  messages.add(value.toString());
                }
              });
              if (messages.isNotEmpty) errorMessage = messages.join('\n');
            }
            throw Exception(errorMessage);
          }
        }
      }
      rethrow;
    }
  }
}

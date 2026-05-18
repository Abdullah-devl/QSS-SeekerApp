import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../models/points_balance_model.dart';

/// 📂 اسم الملف: payment_repository.dart
/// 📝 الوصف: مستودع البيانات الخاص بعمليات الدفع والسداد (نقاط وسندات).

class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository(this._apiService);

  /// 💰 جلب رصيد النقاط الحالي
  Future<PointsBalanceModel> getPointsBalance() async {
    try {
      final response = await _apiService.get(ApiEndpoints.pointsBalance);
      final data = ApiErrorHandler.handleResponse(response);
      return PointsBalanceModel.fromJson(data);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// 🌟 السداد بالنقاط
  Future<void> payByPoints({
    required String requestId,
    required double transferredPoints,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.payByPoints(requestId),
        data: {
          'transferred_points': transferredPoints,
        },
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  /// 📄 السداد برفع سند (Multipart)
  Future<void> submitBond({
    required String requestId,
    required double amount,
    required File image,
    required String bondNumber,
  }) async {
    try {
      final formData = FormData.fromMap({
        'request_id': requestId,
        'amount': amount,
        'bond_number': bondNumber,
        'image_path': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final response = await _apiService.post(
        ApiEndpoints.requestBonds,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}

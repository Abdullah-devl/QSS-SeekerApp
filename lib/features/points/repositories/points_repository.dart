import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/core/network/api_endpoints.dart';
import '../models/points_package_model.dart';
import '../models/points_balance_model.dart';
import 'dart:developer' as developer;

class PointsRepository {
  final ApiService _apiService;

  PointsRepository(this._apiService);

  // 📥 جلب باقات النقاط المتاحة
  Future<List<PointsPackageModel>> getAvailablePackages() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.availablePointsPackages,
      );
      developer.log(
        '📡 [PointsRepo] getAvailablePackages Response: ${response.data}',
      );

      final rawData = response.data;
      List data = [];

      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data =
            rawData['packages'] ??
            rawData['data'] ??
            rawData['available_packages'] ??
            [];
      }

      return data
          .map(
            (json) =>
                PointsPackageModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    } catch (e) {
      developer.log('❌ [PointsRepo] getAvailablePackages Error: $e');
      rethrow;
    }
  }

  // 📜 جلب باقاتي (التي طلبها المستخدم وحالتها)
  Future<List<Map<String, dynamic>>> getMyPointsPackages() async {
    try {
      final response = await _apiService.get(ApiEndpoints.myPointsPackages);
      developer.log(
        '📡 [PointsRepo] getMyPointsPackages Response: ${response.data}',
      );

      final rawData = response.data;
      List data = [];

      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map) {
        data =
            rawData['packages'] ??
            rawData['data'] ??
            rawData['my_packages'] ??
            [];
      }

      return data.map((json) => Map<String, dynamic>.from(json)).toList();
    } catch (e) {
      developer.log('❌ [PointsRepo] getMyPointsPackages Error: $e');
      rethrow;
    }
  }

  // 📦 إرسال طلب اشتراك في باقة (شحن نقاط)
  Future<String> subscribeToPackage({
    required int packageId,
    required String bondNumber,
    required String bankName,
    required File bondImage,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'package_id': packageId.toString(),
        'bond_number': bondNumber,
        'bank_name': bankName,
        'bond_image': await MultipartFile.fromFile(
          bondImage.path,
          filename: bondImage.path.split(RegExp(r'[/\\]')).last,
        ),
      });

      final response = await _apiService.post(
        ApiEndpoints.subscribePointsPackage,
        data: formData,
      );
      developer.log(
        '📡 [PointsRepo] subscribeToPackage Response: ${response.data}',
      );
      return response.data['message'] ?? 'تم إرسال طلب الشحن بنجاح';
    } catch (e) {
      developer.log('❌ [PointsRepo] subscribeToPackage Error: $e');
      rethrow;
    }
  }

  /// 💰 جلب رصيد النقاط الفعلي
  Future<PointsBalanceModel> getPointsBalance() async {
    try {
      final response = await _apiService.get(ApiEndpoints.pointsBalance);
      developer.log(
        '📡 [PointsRepo] getPointsBalance Response: ${response.data}',
      );

      final data = response.data['data'] ?? response.data;
      return PointsBalanceModel.fromJson(data);
    } catch (e) {
      developer.log('❌ [PointsRepo] getPointsBalance Error: $e');
      rethrow;
    }
  }
}

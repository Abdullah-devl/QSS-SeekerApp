// مسار الملف: lib/features/orders/repositories/orders_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:seeker/core/errors/api_error_handler.dart';
import 'package:seeker/core/network/api_service.dart';
import '../../../core/network/api_endpoints.dart';
import '../Models/order_model.dart';

class OrdersRepository {
  final ApiService _apiService;

  // 🚀 اسم الصندوق الخاص بتخزين الطلبات في هايف
  static const String _boxName = 'orders_cache_box';

  OrdersRepository(this._apiService);

  // دالة جلب تفاصيل طلب واحد
  Future<OrderModel> getOrderDetail(String requestId) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.getOrderDetail(requestId),
      );
      final data = ApiErrorHandler.handleResponse(response);

      // السيرفر قد يرسل الطلب داخل مفتاح 'request' أو 'data' أو مباشرة
      final Map<String, dynamic> orderJson =
          data['request'] ?? data['data'] ?? data;

      return OrderModel.fromJson(orderJson);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // دالة جلب الطلبات (من السيرفر أو من هايف)
  Future<List<OrderModel>> getOrders() async {
    try {
      // 1. محاولة جلب البيانات الحديثة من السيرفر (خاصة بالمستفيد)
      final response = await _apiService.get(ApiEndpoints.getSeekerOrders);
      final data = ApiErrorHandler.handleResponse(response);

      // 🕵️ تشخيص البيانات القادمة من السيرفر
      debugPrint('🔍 [STORAGE] Raw Data from Server: $data');
      List responseList = []; // تهيئة القائمة بقيمة فارغة افتراضياً

      if (data is Map<String, dynamic>) {
        var rawData = data['requests'] ?? data['data'];
        if (rawData is List) {
          responseList = rawData;
        }
      } else if (data is List) {
        responseList = data;
      }
      // List responseList;
      // if (data is Map) {
      //   // السيرفر قد يرسل البيانات تحت مفتاح 'requests' أو 'data'
      //   responseList = data['requests'] ?? data['data'] ?? [];
      //   if (responseList is! List) responseList = [];
      // } else if (data is List) {
      //   responseList = data;
      // } else {
      //   responseList = [];
      // }

      // 2. 🚀 حفظ البيانات (الكاش) في هايف فور وصولها بنجاح
      var box = await Hive.openBox(_boxName);
      await box.put('cached_orders', responseList);

      return responseList.map((e) {
        final orderMap = Map<String, dynamic>.from(e);
        debugPrint(
          '🔍 [MODEL] Mapping Item ID: ${orderMap['id']} - Data: $orderMap',
        );
        return OrderModel.fromJson(orderMap);
      }).toList();
    } catch (e) {
      // 3. 🚀 التحقق من نوع الخطأ: إذا كان الخطأ Unauthorized (401)، لا نمسح الكاش بل نعيد رمي الخطأ
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint(
          '⚠️ [AUTH] Unauthorized detected in Repository. Skipping Hive fallback.',
        );
        throw ApiErrorHandler.handle(e);
      }

      // 4. 🚀 في حال فشل السيرفر (لا يوجد إنترنت أو السيرفر متوقف)، نقرأ من هايف
      try {
        var box = await Hive.openBox(_boxName);
        final cachedData = box.get('cached_orders');

        if (cachedData != null) {
          debugPrint(
            '⚠️ فشل الاتصال بالسيرفر.. تم جلب الطلبات من الكاش (Hive)',
          );
          final List mapData = List.from(cachedData);
          return mapData
              .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (hiveError) {
        debugPrint('❌ خطأ في قراءة الكاش: $hiveError');
      }

      // إذا فشل السيرفر ولا يوجد كاش مسبق، نعرض رسالة الخطأ للمستخدم
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 تحديث حالة الطلب (PATCH /api/requests/{id}/status)
  Future<void> updateOrderStatus(String requestId, String status) async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.updateStatus(requestId),
        data: {'status': status},
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 إضافة مبلغ مدفوع (POST /api/requests/{id}/addAmountToMoneyPaid)
  Future<void> addPaidAmount(String requestId, double amount) async {
    try {
      final url = ApiEndpoints.addAmount(requestId);
      debugPrint('🚀 [NETWORK] Calling AddPayment API...');
      debugPrint('📍 URL: $url');
      debugPrint('📦 DATA: {"added_amount": $amount}');
      debugPrint('🆔 Request ID used in URL: $requestId');

      final response = await _apiService.post(
        url,
        data: {'added_amount': amount},
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 إضافة تقييم للطلب (POST /api/reviews)
  Future<void> submitReview({
    required String requestId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.reviews,
        data: {'request_id': requestId, 'rating': rating, 'comment': comment},
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  // 🚀 إرسال شكوى على الطلب (POST /api/request-complaints)
  Future<void> submitComplaint({
    required String requestId,
    required String title,
    required String type,
    required String content,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.requestComplaints,
        data: {
          'request_id': requestId,
          'title': title,
          'type': type,
          'content': content,
        },
      );
      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}

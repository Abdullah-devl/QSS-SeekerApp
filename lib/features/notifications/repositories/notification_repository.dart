// lib/features/notifications/repositories/notification_repository.dart

import 'package:seeker/core/network/api_service.dart';
import 'package:seeker/core/network/api_endpoints.dart';
import '../models/notification_model.dart';
import 'dart:developer' as developer;

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  /// 🔑 إرسال توكن FCM للسيرفر
  Future<void> storeToken(String token) async {
    final fullUrl = ApiEndpoints.storeToken;
    print('📡 [NOTIFICATION REPO]: Attempting to store token at: $fullUrl');
    try {
      final response = await _apiService.post(fullUrl, data: {
        'token': token, // ✅ تم التعديل حسب التوثيق
      });
      print('✅ [NOTIFICATION REPO]: Success! Status: ${response.statusCode}');
      developer.log('✅ NotificationRepository: Token stored. Status: ${response.statusCode}');
    } catch (e) {
      print('❌ [NOTIFICATION REPO]: Failed to store token at: $fullUrl');
      print('❌ Error details: $e');
      developer.log('❌ NotificationRepository: Error storing token: $e');
    }
  }

  /// 🚪 حذف توكن FCM من السيرفر عند تسجيل الخروج
  Future<void> removeToken(String token) async {
    final fullUrl = "${ApiEndpoints.baseUrl}/remove-token";
    print('📡 [NOTIFICATION REPO]: Attempting to remove token at: $fullUrl');
    try {
      final response = await _apiService.post(fullUrl, data: {
        'token': token,
      });
      print('✅ [NOTIFICATION REPO]: Token removed successfully. Status: ${response.statusCode}');
    } catch (e) {
      print('❌ [NOTIFICATION REPO]: Failed to remove token: $e');
    }
  }

  /// 📜 جلب قائمة الإشعارات
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _apiService.get(ApiEndpoints.notifications);
      if (response.statusCode == 200) {
        final List data = (response.data is Map && response.data.containsKey('data')) 
            ? response.data['data'] 
            : response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      developer.log('❌ NotificationRepository: Error fetching notifications: $e');
      return [];
    }
  }

  /// ✅ تمييز إشعار كمقروء
  Future<void> markAsRead(String id) async {
    try {
      await _apiService.post(ApiEndpoints.markNotificationRead(id));
    } catch (e) {
      developer.log('❌ NotificationRepository: Error marking as read: $e');
    }
  }

  /// ✅ تمييز الكل كمقروء
  Future<void> markAllAsRead() async {
    try {
      await _apiService.post(ApiEndpoints.markAllNotificationsRead);
    } catch (e) {
      developer.log('❌ NotificationRepository: Error marking all as read: $e');
    }
  }
}

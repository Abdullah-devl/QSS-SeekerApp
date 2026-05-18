import 'package:flutter/material.dart';
import 'package:seeker/core/storage/token_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:seeker/core/services/notification_service.dart';

/// 📂 اسم الملف: settings_view_model.dart
/// 📝 الوصف: نموذج العرض لإدارة حالة صفحة الإعدادات.
/// يقوم بإدارة حالة الإشعارات وتحميل بيانات المستخدم.

class SettingsViewModel extends ChangeNotifier {
  final TokenStorage _tokenStorage;

  SettingsViewModel(this._tokenStorage);

  // ---------------------------------------------------------------------------
  // 📊 الحالة (State)
  // ---------------------------------------------------------------------------

  bool _notificationsEnabled = true;
  Locale _locale = const Locale('ar'); // اللغة الافتراضية

  String _userName = 'guest';
  String _userEmail = 'visitor@example.com';
  String _userPhone = '';
  String _userAddress = '';

  bool get notificationsEnabled => _notificationsEnabled;
  Locale get locale => _locale;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get userAddress => _userAddress;

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// 🔄 تحميل بيانات المستخدم من التخزين المحلي
  Future<void> loadUserData() async {
    final data = await _tokenStorage.getUserData();
    _userName = data['name'] ?? 'guest';
    _userEmail = data['email'] ?? 'visitor@example.com';
    _userPhone = data['phone'] ?? '';
    _userAddress = data['address'] ?? '';

    // تحميل اللغة المحفوظة
    final savedLang = await _tokenStorage.getLanguage();
    if (savedLang != null) {
      _locale = Locale(savedLang);
    }

    // تحميل حالة الإشعارات المحفوظة
    _notificationsEnabled = await _tokenStorage.getNotificationsEnabled();

    notifyListeners();
  }

  /// 🌍 تغيير اللغة
  Future<void> changeLanguage(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners(); // ⚡ تحديث فوري للواجهة
    await _tokenStorage.saveLanguage(locale.languageCode);
  }

  /// 🔔 تبديل تفعيل الإشعارات وربطه بالصلاحيات الحقيقية
  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    await _tokenStorage.saveNotificationsEnabled(value);

    try {
      if (value) {
        // 🚀 طلب صلاحيات الإشعارات وتحديث توكن FCM بالسيرفر
        final NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          await NotificationService().updateTokenToServer();
        }
      } else {
        // 🛑 حذف توكن FCM من فيربييس والباك إند لمنع استلام أي إشعارات نهائياً
        await NotificationService().deleteTokenOnLogout();
      }
    } catch (e) {
      debugPrint('❌ [SettingsViewModel]: Error toggling notifications: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:seeker/core/storage/token_storage.dart';

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

  String _userName = 'زائر';
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
    _userName = data['name'] ?? 'زائر';
    _userEmail = data['email'] ?? 'visitor@example.com';
    _userPhone = data['phone'] ?? '';
    _userAddress = data['address'] ?? '';

    // تحميل اللغة المحفوظة
    final savedLang = await _tokenStorage.getLanguage();
    if (savedLang != null) {
      _locale = Locale(savedLang);
    }

    notifyListeners();
  }

  /// 🌍 تغيير اللغة
  Future<void> changeLanguage(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners(); // ⚡ تحديث فوري للواجهة
    await _tokenStorage.saveLanguage(locale.languageCode);
  }

  /// 🔔 تبديل تفعيل الإشعارات
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
}

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

  String _userName = 'زائر';
  String _userEmail = 'visitor@example.com';

  bool get notificationsEnabled => _notificationsEnabled;

  String get userName => _userName;
  String get userEmail => _userEmail;

  // ---------------------------------------------------------------------------
  // ⚙️ العمليات (Actions)
  // ---------------------------------------------------------------------------

  /// 🔄 تحميل بيانات المستخدم من التخزين المحلي
  Future<void> loadUserData() async {
    final data = await _tokenStorage.getUserData();
    _userName = data['name'] ?? 'زائر';
    _userEmail = data['email'] ?? 'visitor@example.com';
    notifyListeners();
  }

  /// 🔔 تبديل تفعيل الإشعارات
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
}

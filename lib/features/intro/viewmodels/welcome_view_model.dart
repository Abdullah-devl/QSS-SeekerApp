import 'package:flutter/material.dart';
import 'package:seeker/core/routes/app_routes.dart';

/// 🧠 اسم الملف: welcome_view_model.dart
/// 📝 الوصف: يدير منطق صفحة الترحيب (WelcomeView) والنصوص المعروضة فيها.

class WelcomeViewModel extends ChangeNotifier {
  // دالة فارغة (ربما كانت مخصصة لتغيير الثيم)
  chingTheme() {}

  /// 🔐 الانتقال لصفحة تسجيل الدخول.
  void login(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.login);
    // نستخدم pushNamed لكي يتمكن المستخدم من العودة لصفحة الترحيب إذا أراد
  }

  /// 🆕 الانتقال لصفحة إنشاء حساب جديد.
  void register(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.register);
  }
}

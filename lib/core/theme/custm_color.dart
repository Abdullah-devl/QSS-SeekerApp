import 'package:flutter/material.dart';

/// 📂 اسم الملف: custm_color.dart
/// 📝 الوصف: يحتوي هذا الكلاس على الألوان الثابتة المستخدمة في التطبيق.
/// بدلاً من كتابة كود اللون (Hex Code) في كل مكان، نستخدم هذا الكلاس لتوحيد الألوان وتسهيل تغييرها مستقبلاً.

class CustomColor {
  // ⛔ منع إنشاء كائن من هذا الكلاس لأنه يحتوي فقط على ثوابت (static).
  CustomColor._();

  // ===========================================================================
  // ☀️ ألوان الثيم الفاتح (Light Mode Colors)
  // ===========================================================================

  /// لون النصوص الرئيسي (فحمي داكن).
  static const Color lightText = Color(0xFF2D3436);

  /// لون النصوص الفرعية.
  static const Color lightTextSub = Color(0xFF636E72);

  /// لون الخلفية (أزرق سماوي ناعم جداً لراحة العين ولمسة Premium).
  static const Color lightBackground = Color(0xFFF1FAFF);

  /// اللون الأساسي (أزرق حيوي).
  static const Color lightPrimary = Color(0xFF1CB0F6);

  /// اللون الثانوي.
  static const Color lightSecondary = Color(0xFF74B9FF);

  /// لون التمييز.
  static const Color lightAccent = Color(0xFF1CB0F6);

  // ألوان الحالات (Status Colors)
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFA502);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF1CB0F6);

  // ===========================================================================
  // 🌙 ألوان الثيم الداكن (Dark Mode Colors) - تم اختيار درجات هادئة
  // ===========================================================================

  /// لون النصوص الرئيسي.
  static const Color darkText = Color(0xFFDFE6E9);

  /// لون النصوص الفرعية.
  static const Color darkTextSub = Color(0xFFB2BEC3);

  /// لون الخلفية.
  static const Color darkBackground = Color(0xFF0A0E10);

  /// اللون الأساسي (أزرق هادئ للوضع الداكن).
  static const Color darkPrimary = Color(0xFF189AD3);

  /// اللون الثانوي.
  static const Color darkSecondary = Color(0xFF0984E3);

  /// لون التمييز.
  static const Color darkAccent = Color(0xFF189AD3);

  // ألوان الحالات للوضع الداكن (بدرجات أقل حدة)
  static const Color darkSuccess = Color(0xFF27AE60);
  static const Color darkWarning = Color(0xFFE67E22);
  static const Color darkError = Color(0xFFD63031);
  static const Color darkInfo = Color(0xFF189AD3);
}

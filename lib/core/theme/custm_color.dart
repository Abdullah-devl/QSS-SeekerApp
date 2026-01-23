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

  /// لون النصوص الرئيسي في الوضع الفاتح (أسود داكن).
  static const Color lightText = Color(0xFF0A0E10);

  /// لون النصوص الفرعية أو الوصف (رمادي).
  static const Color lightTextSub = Color(0xFF5F6B7A);

  /// لون الخلفية في الوضع الفاتح (أبيض مائل للزرقة الخفيفة جداً).
  static const Color lightBackground = Color(0xFFF8FBFC);

  /// اللون الأساسي للتطبيق (أزرق متوسط).
  static const Color lightPrimary = Color(0xFF4F9CBF);

  /// اللون الثانوي (أزرق فاتح).
  static const Color lightSecondary = Color(0xFF92C9E3);

  /// لون التمييز (Accent Color).
  static const Color lightAccent = Color(0xFF67BDE4);

  // ===========================================================================
  // 🌙 ألوان الثيم الداكن (Dark Mode Colors)
  // ===========================================================================

  /// لون النصوص الرئيسي في الوضع الداكن (أبيض تقريباً).
  static const Color darkText = Color(0xFFEFF3F5);

  /// لون النصوص الفرعية (رمادي فاتح).
  static const Color darkTextSub = Color(0xFF9CA3AF);

  /// لون الخلفية في الوضع الداكن (أسود داكن جداً).
  static const Color darkBackground = Color(0xFF030607);

  /// اللون الأساسي في الوضع الداكن.
  static const Color darkPrimary = Color(0xFF408DB0);

  /// اللون الثانوي في الوضع الداكن.
  static const Color darkSecondary = Color(0xFF1C546D);

  /// لون التمييز في الوضع الداكن.
  static const Color darkAccent = Color(0xFF1B7098);
}

import 'package:flutter/material.dart';

/// 📂 اسم الملف: qs_colors.dart
/// 📝 الوصف: موديل (Model) بسيط لتجميع الألوان كحزمة واحدة.
/// يُستخدم لتمرير مجموعة الألوان المناسبة (فاتح أو داكن) إلى الـ UI بسهولة.

class QSColors {
  /// لون النص الرئيسي.
  final Color text;

  /// لون النص الفرعي (الوصف).
  final Color textSub;

  /// لون الخلفية.
  final Color background;

  /// اللون الأساسي (Primary).
  final Color primary;

  /// اللون الثانوي (Secondary).
  final Color secondary;

  /// لون التمييز (Accent).
  final Color accent;

  /// لون الخطأ (Error).
  final Color error;

  /// لون النجاح (Success).
  final Color success;

  /// لون التحذير (Warning).
  final Color warning;

  /// لون المعلومات (Info).
  final Color info;

  /// 🏗️ البناء (Constructor): يتطلب تمرير جميع الألوان.
  const QSColors({
    required this.text,
    required this.textSub,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
  });
}

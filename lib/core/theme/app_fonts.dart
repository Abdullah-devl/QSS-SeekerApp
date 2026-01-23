import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 📂 اسم الملف: app_fonts.dart
/// 📝 الوصف: مسؤول عن إدارة الخطوط في التطبيق.
/// نستخدم مكتبة Google Fonts لتوفير خطوط احترافية وسهلة الاستخدام.

class AppFonts {
  /// 🅰️ استرجاع نمط النص (TextStyle) بخط Cairo.
  /// خط Cairo هو الخط المعتمد للغة العربية في هذا التطبيق.
  static TextStyle get cairo => GoogleFonts.cairo();

  /// 🎨 تطبيق خط Cairo على كامل الـ TextTheme الخاص بالتطبيق.
  /// هذه الدالة مفيدة عند إعداد الثيم العام (ThemeData) لتوحيد الخط في كل الشاشات.
  static TextTheme applyCairo(TextTheme theme) {
    return GoogleFonts.cairoTextTheme(theme);
  }
}

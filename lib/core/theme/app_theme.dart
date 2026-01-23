import 'package:flutter/material.dart';
import 'custm_color.dart';
import 'app_fonts.dart';

/// 📂 اسم الملف: app_theme.dart
/// 📝 الوصف: يحتوي على تعريف الثيم (Light & Dark Theme) للتطبيق.
/// يربط بين الألوان، الخطوط، وتنسيقات العناصر المختلفة (مثل الأزرار والنصوص).

class AppTheme {
  // ===========================================================================
  // ☀️ الثيم الفاتح (Light Theme)
  // ===========================================================================
  static ThemeData lightTheme = ThemeData(
    // تحديد سطوع الثيم كـ فاتح
    brightness: Brightness.light,

    // لون خلفية الصفحات (Scaffold)
    scaffoldBackgroundColor: CustomColor.lightBackground,

    // تعريف نظام الألوان (Color Scheme)
    colorScheme: const ColorScheme.light(
      primary: CustomColor.lightPrimary, // اللون الأساسي
      secondary: CustomColor.lightSecondary, // اللون الثانوي

      surface: CustomColor.lightAccent, // لون العناصر السطحية (Cards, Dialogs)
      onPrimary: Colors.white, // لون النصوص/الأيقونات فوق اللون الأساسي
      onSurface: CustomColor.lightText, // لون النصوص فوق الأسطح
      error: Colors.red, // لون الخطأ
    ),

    // تخصيص الخطوط
    textTheme: AppFonts.applyCairo(
      const TextTheme(
        // عنوان كبير (للعناوين الرئيسية)
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: CustomColor.lightText,
        ),
        // نص عادي (للمحتوى)
        bodyMedium: TextStyle(fontSize: 16, color: CustomColor.lightText),
      ),
    ),

    // تخصيص شكل الأزرار المرتفعة (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColor.lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // ===========================================================================
  // 🌙 الثيم الداكن (Dark Theme)
  // ===========================================================================
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: CustomColor.darkBackground,

    colorScheme: const ColorScheme.dark(
      primary: CustomColor.darkPrimary,
      secondary: CustomColor.darkSecondary,

      surface: CustomColor.darkAccent,
      onPrimary: Colors.white,
      onSurface: CustomColor.darkText,
      error: Colors.red,
    ),

    textTheme: AppFonts.applyCairo(
      const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: CustomColor.darkText,
        ),
        bodyMedium: TextStyle(fontSize: 16, color: CustomColor.darkText),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CustomColor.darkPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
